## ----mss-loadpackages, results='hide', message=FALSE, warning=FALSE-------------
library(MARSS)
library(R2jags)
library(coda)
library(rstan)


## ----mss-noshowlegend, echo=FALSE, results='hide'-------------------------------
d <- MARSS::harborSealWA
legendnames <- (unlist(dimnames(d)[2]))[2:ncol(d)]
for (i in 1:length(legendnames)) cat(paste(i, legendnames[i], "\n", sep = " "))


## ----mss-fig1, fig=TRUE, echo=FALSE, fig.width=5, fig.height=5, fig.cap='(ref:mss-fig1)', warning=FALSE----
temp <- as.data.frame(MARSS::harborSealWA)
pdat <- reshape2::melt(temp, id.vars = "Year", variable.name = "region")
p <- ggplot(pdat, aes(x = Year, y = value, col = region)) +
  geom_point() +
  geom_line()
p + ggtitle("Puget Sound Harbor Seal Surveys")


## ----mss-Cs2-showdata-----------------------------------------------------------
data(harborSealWA, package = "MARSS")
print(harborSealWA[1:8, ], digits = 3)


## ----mss-Cs2-readindata---------------------------------------------------------
dat <- MARSS::harborSealWA
years <- dat[, "Year"]
dat <- dat[, !(colnames(dat) %in% c("Year", "HC"))]
dat <- t(dat) # transpose to have years across columns
colnames(dat) <- years
n <- nrow(dat) - 1


## ----mss-fit.0.model------------------------------------------------------------
mod.list.0 <- list(
  B = matrix(1),
  U = matrix("u"),
  Q = matrix("q"),
  Z = matrix(1, 4, 1),
  A = "scaling",
  R = "diagonal and unequal",
  x0 = matrix("mu"),
  tinitx = 0
)


## ----mss-fit.0.fit--------------------------------------------------------------
fit.0 <- MARSS(dat, model = mod.list.0)


## ----mss-model-resids, fig.show='hide'------------------------------------------
par(mfrow = c(2, 2))
resids <- MARSSresiduals(fit.0, type="tt1")
for (i in 1:4) {
  plot(resids$model.residuals[i, ], ylab = "model residuals", xlab = "")
  abline(h = 0)
  title(rownames(dat)[i])
}


## ----mss-model-resids-plot, echo=FALSE, fig=TRUE, fig.cap='(ref:mss-model-resids-plot)'----
par(mfrow = c(2, 2))
resids <- MARSSresiduals(fit.0, type="tt1")
for (i in 1:4) {
  plot(resids$model.residuals[i, ], ylab = "model residuals", xlab = "")
  abline(h = 0)
  title(rownames(dat)[i])
}


## ----mss-fit-1-model------------------------------------------------------------
mod.list.1 <- list(
  B = "identity",
  U = "equal",
  Q = "diagonal and equal",
  Z = "identity",
  A = "scaling",
  R = "diagonal and unequal",
  x0 = "unequal",
  tinitx = 0
)


## ----mss-fit.1.fit, results='hide'----------------------------------------------
fit.1 <- MARSS::MARSS(dat, model = mod.list.1)


## ----mss-fit-2-model------------------------------------------------------------
mod.list.2 <- mod.list.1
mod.list.2$Q <- "equalvarcov"


## ----mss-fit-1-fit, results='hide'----------------------------------------------
fit.2 <- MARSS::MARSS(dat, model = mod.list.2)


## ----mss-fits-aicc--------------------------------------------------------------
c(fit.0$AICc, fit.1$AICc, fit.2$AICc)


## ----mss-model-resids-2, echo=FALSE, fig=TRUE, fig.cap='(ref:mss-model-resids-2)'----
par(mfrow = c(2, 2))
resids <- MARSSresiduals(fit.2, type="tt1")
for (i in 1:4) {
  plot(resids$model.residuals[i, ], ylab = "model residuals", xlab = "")
  abline(h = 0)
  title(rownames(dat)[i])
}


## ----mss-fig2, fig.show='hide'--------------------------------------------------
par(mfrow = c(2, 2))
for (i in 1:4) {
  plot(years, fit.2$states[i, ], ylab = "log subpopulation estimate", xlab = "", type = "l")
  lines(years, fit.2$states[i, ] - 1.96 * fit.2$states.se[i, ], type = "l", lwd = 1, lty = 2, col = "red")
  lines(years, fit.2$states[i, ] + 1.96 * fit.2$states.se[i, ], type = "l", lwd = 1, lty = 2, col = "red")
  title(rownames(dat)[i])
}


## ----mss-fig2-plot, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:mss-fig2-plot)'----
par(mfrow = c(2, 2))
for (i in 1:4) {
  plot(years, fit.2$states[i, ], ylab = "log subpopulation estimate", xlab = "", type = "l")
  lines(years, fit.2$states[i, ] - 1.96 * fit.2$states.se[i, ], type = "l", lwd = 1, lty = 2, col = "red")
  lines(years, fit.2$states[i, ] + 1.96 * fit.2$states.se[i, ], type = "l", lwd = 1, lty = 2, col = "red")
  title(rownames(dat)[i])
}


## ----mss-Cs01-setup-data--------------------------------------------------------
dat <- MARSS::harborSeal
years <- dat[, "Year"]
good <- !(colnames(dat) %in% c("Year", "HoodCanal"))
sealData <- t(dat[, good])


## ----mss-Cs02-fig1, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:mss-Cs02-fig1)', warning=FALSE----
# par(mfrow=c(4,3),mar=c(2,2,2,2))
# years = MARSS::harborSeal[,"Year"]
# for(i in 2:dim(MARSS::harborSeal)[2]) {
#     plot(years, MARSS::harborSeal[,i], xlab="", ylab="", main=colnames(MARSS::harborSeal)[i])
# }

temp <- as.data.frame(MARSS::harborSeal)
pdat <- reshape2::melt(temp, id.vars = "Year", variable.name = "region")
p <- ggplot(pdat, aes(Year, value)) +
  geom_point()
p + facet_wrap(~region)


## ----mss-Zmodel, tidy=FALSE-----------------------------------------------------
Z.model <- matrix(0, 11, 3)
Z.model[c(1, 2, 9, 10), 1] <- 1 # which elements in col 1 are 1
Z.model[c(3:6, 11), 2] <- 1 # which elements in col 2 are 1
Z.model[7:8, 3] <- 1 # which elements in col 3 are 1


## ----mss-Zmodel1----------------------------------------------------------------
Z1 <- factor(c("pnw", "pnw", rep("ps", 4), "ca", "ca", "pnw", "pnw", "ps"))


## ----mss-model-list, tidy=FALSE-------------------------------------------------
mod.list <- list(
  B = "identity",
  U = "unequal",
  Q = "equalvarcov",
  Z = "placeholder",
  A = "scaling",
  R = "diagonal and equal",
  x0 = "unequal",
  tinitx = 0
)


## ----mss-set-up-Zs, tidy=FALSE--------------------------------------------------
Z.models <- list(
  H1 = factor(c("pnw", "pnw", rep("ps", 4), "ca", "ca", "pnw", "pnw", "ps")),
  H2 = factor(c(rep("coast", 2), rep("ps", 4), rep("coast", 4), "ps")),
  H3 = factor(c(rep("N", 6), "S", "S", "N", "S", "N")),
  H4 = factor(c("nc", "nc", "is", "is", "ps", "ps", "sc", "sc", "nc", "sc", "is")),
  H5 = factor(rep("pan", 11)),
  H6 = factor(1:11) # site
)
names(Z.models) <-
  c("stock", "coast+PS", "N+S", "NC+strait+PS+SC", "panmictic", "site")


## ----mss-Cs05-run-models, cache=TRUE--------------------------------------------
out.tab <- NULL
fits <- list()
for (i in 1:length(Z.models)) {
  mod.list$Z <- Z.models[[i]]
  fit <- MARSS::MARSS(sealData,
    model = mod.list,
    silent = TRUE, control = list(maxit = 1000)
  )
  out <- data.frame(
    H = names(Z.models)[i],
    logLik = fit$logLik, AICc = fit$AICc,
    num.param = fit$num.params,
    m = length(unique(Z.models[[i]])),
    num.iter = fit$numIter,
    converged = !fit$convergence
  )
  out.tab <- rbind(out.tab, out)
  fits <- c(fits, list(fit))
}


## ----mss-Cs06-sort-results------------------------------------------------------
min.AICc <- order(out.tab$AICc)
out.tab.1 <- out.tab[min.AICc,]


## ----mss-Cs07-add-delta-aicc----------------------------------------------------
out.tab.1 <- cbind(out.tab.1,
  delta.AICc = out.tab.1$AICc - out.tab.1$AICc[1]
)


## ----mss-Cs08-add-delta-aicc----------------------------------------------------
out.tab.1 <- cbind(out.tab.1,
  rel.like = exp(-1 * out.tab.1$delta.AICc / 2)
)


## ----mss-Cs09-aic-weight--------------------------------------------------------
out.tab.1 <- cbind(out.tab.1,
  AIC.weight = out.tab.1$rel.like / sum(out.tab.1$rel.like)
)


## ----mss-Cs10-print-table, echo=FALSE-------------------------------------------
out.tab.1$delta.AICc <- round(out.tab.1$delta.AICc, digits = 2)
out.tab.1$AIC.weight <- round(out.tab.1$AIC.weight, digits = 3)
print(out.tab.1[, c("H", "delta.AICc", "AIC.weight", "converged")], row.names = FALSE)


## ----mss-set-up-seal-data-jags--------------------------------------------------
data(harborSealWA, package = "MARSS")
sites <- c("SJF", "SJI", "EBays", "PSnd")
Y <- harborSealWA[, sites]
Y <- t(Y) # time across columns


## ----mss-jagsscript-------------------------------------------------------------
jagsscript <- cat("
model {  
   U ~ dnorm(0, 0.01);
   tauQ~dgamma(0.001,0.001);
   Q <- 1/tauQ;

   # Estimate the initial state vector of population abundances
   for(i in 1:nSites) {
      X[i,1] ~ dnorm(3,0.01); # vague normal prior 
   }

   # Autoregressive process for remaining years
   for(t in 2:nYears) {
      for(i in 1:nSites) {
         predX[i,t] <- X[i,t-1] + U;
         X[i,t] ~ dnorm(predX[i,t], tauQ);
      }
   }

   # Observation model
   # The Rs are different in each site
   for(i in 1:nSites) {
     tauR[i]~dgamma(0.001,0.001);
     R[i] <- 1/tauR[i];
   }
   for(t in 1:nYears) {
     for(i in 1:nSites) {
       Y[i,t] ~ dnorm(X[i,t],tauR[i]);
     }
   }
}  

",file="marss-jags.txt")


## ----mss-marss-jags, results='hide', message=FALSE, cache=TRUE------------------
jags.data <- list("Y" = Y, nSites = nrow(Y), nYears = ncol(Y)) # named list
jags.params <- c("X", "U", "Q", "R")
model.loc <- "marss-jags.txt" # name of the txt file
mod_1 <- jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3,
  n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)


## ----mss-plot-jags-states, fig.cap='(ref:NA)'-----------------------------------
#attach.jags attaches the jags.params to our workspace
attach.jags(mod_1)
means <- apply(X, c(2, 3), mean)
upperCI <- apply(X, c(2, 3), quantile, 0.975)
lowerCI <- apply(X, c(2, 3), quantile, 0.025)
par(mfrow = c(2, 2))
nYears <- ncol(Y)
for (i in 1:nrow(means)) {
  plot(means[i, ],
    lwd = 3, ylim = range(c(lowerCI[i, ], upperCI[i, ])),
    type = "n", main = colnames(Y)[i], ylab = "log abundance", xlab = "time step"
  )
  polygon(c(1:nYears, nYears:1, 1),
    c(upperCI[i, ], rev(lowerCI[i, ]), upperCI[i, 1]),
    col = "skyblue", lty = 0
  )
  lines(means[i, ], lwd = 3)
  title(rownames(Y)[i])
}
detach.jags()




## ----marss-stan-model-----------------------------------------------------------
scode <- "
data {
  int<lower=0> TT; // length of ts
  int<lower=0> N; // num of ts; rows of y
  int<lower=0> n_pos; // number of non-NA values in y
  int<lower=0> col_indx_pos[n_pos]; // col index of non-NA vals
  int<lower=0> row_indx_pos[n_pos]; // row index of non-NA vals
  vector[n_pos] y;
}
parameters {
  vector[N] x0; // initial states
  real u;
  vector[N] pro_dev[TT]; // refed as pro_dev[TT,N]
  real<lower=0> sd_q;
  real<lower=0> sd_r[N]; // obs variances are different
}
transformed parameters {
  vector[N] x[TT]; // refed as x[TT,N]
  for(i in 1:N){
    x[1,i] = x0[i] + u + pro_dev[1,i];
    for(t in 2:TT) {
      x[t,i] = x[t-1,i] + u + pro_dev[t,i];
    }
  }
}
model {
  sd_q ~ cauchy(0,5);
  for(i in 1:N){
    x0[i] ~ normal(y[i],10); // assume no missing y[1]
    sd_r[i] ~ cauchy(0,5);
    for(t in 1:TT){
    pro_dev[t,i] ~ normal(0, sd_q);
    }
  }
  u ~ normal(0,2);
  for(i in 1:n_pos){
    y[i] ~ normal(x[col_indx_pos[i], row_indx_pos[i]], sd_r[row_indx_pos[i]]);
  }
}
generated quantities {
  vector[n_pos] log_lik;
  for (n in 1:n_pos) log_lik[n] = normal_lpdf(y[n] | x[col_indx_pos[n], row_indx_pos[n]], sd_r[row_indx_pos[n]]);
}
"


## ----marss-stan-fit-model, message=FALSE, warning=FALSE, results='hide', cache=TRUE----
ypos <- Y[!is.na(Y)]
n_pos <- length(ypos) # number on non-NA ys
indx_pos <- which(!is.na(Y), arr.ind = TRUE) # index on the non-NAs
col_indx_pos <- as.vector(indx_pos[, "col"])
row_indx_pos <- as.vector(indx_pos[, "row"])
mod <- rstan::stan(
  model_code = scode,
  data = list(
    y = ypos, TT = ncol(Y), N = nrow(Y), n_pos = n_pos,
    col_indx_pos = col_indx_pos, row_indx_pos = row_indx_pos
  ),
  pars = c("sd_q", "x", "sd_r", "u", "x0"),
  chains = 3,
  iter = 1000,
  thin = 1
)


## ----marss-stan-extract, message=FALSE------------------------------------------
pars <- rstan::extract(mod)
means <- apply(pars$x, c(2,3), mean)
upperCI <- apply(pars$x, c(2,3), quantile, 0.975)
lowerCI <- apply(pars$x, c(2,3), quantile, 0.025)
colnames(means) <- colnames(upperCI) <- colnames(lowerCI) <- rownames(Y)


## ----marss-stan-plot, fig.cap="Estimated level and 95 percent credible intervals.", echo=FALSE----
temp <- as.data.frame(means)
pdat1 <- reshape2::melt(temp, variable.name = "region", value.name="mean")
temp <- as.data.frame(upperCI)
pdat2 <- reshape2::melt(temp, variable.name = "region", value.name="upperCI")
temp <- as.data.frame(lowerCI)
pdat3 <- reshape2::melt(temp, variable.name = "region", value.name="lowerCI")
pdat <- cbind(year=MARSS::harborSealWA[,"Year"],pdat1, high=pdat2[,2], low=pdat3[,2])
ggplot(pdat , aes(x = year , y = mean)) +
  facet_wrap(~region) +
  geom_line() +
  geom_ribbon(aes(x=year, ymin=low, ymax=high, group=region), alpha=0.2)+
  theme_bw()


## ----mss-problems-data----------------------------------------------------------
require(MARSS)
data(harborSealWA, package="MARSS")
dat <- t(harborSealWA[,2:6])


## ----mss-resids, eval=FALSE-----------------------------------------------------
## resids <- MARSSresiduals(fit, type="tt1")$model.residuals
## resids[is.na(dat)] <- NA


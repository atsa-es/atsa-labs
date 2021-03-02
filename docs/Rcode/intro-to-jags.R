## ----jags-loaddata, echo=TRUE, results='hide', eval=TRUE------------------------
data(airquality, package = "datasets")
Wind <- airquality$Wind # wind speed
Temp <- airquality$Temp # air temperature
N <- dim(airquality)[1] # number of data points


## ----jags-loadpackages, results='hide', message=FALSE, warnings=FALSE-----------
library(coda)
library(rjags)
library(R2jags)


## ----jags-lr1, results='hide', cache=TRUE---------------------------------------
# LINEAR REGRESSION with no covariates
# intercept only. The parameters are

model.loc <- "lm_intercept.txt" # name of the txt file
jagsscript <- cat("
model {  
   # priors on parameters
   u ~ dnorm(0, 0.01);
   inv.r ~ dgamma(0.001,0.001); # This is inverse gamma
   r <- 1/inv.r; # derived value
   for(i in 1:N) {
      X[i] <- u
      EY[i] <- X[i]; # derived value
      Y[i] ~ dnorm(EY[i], inv.r); 
   }
}  
", file = model.loc)



## ----jags-call-fun1, results='hide', cache=TRUE---------------------------------
jags.data <- list("Y" = Wind, "N" = N) 
jags.params <- c("r", "u") # parameters to be monitored
mod_lm_intercept <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3, n.burnin = 5000,
  n.thin = 1, n.iter = 10000, DIC = TRUE
)


## ----jags-lm1-mod---------------------------------------------------------------
mod_lm_intercept


## ----jags-lm1-attach, eval=FALSE------------------------------------------------
## R2jags::attach.jags(mod_lm_intercept)


## ----jags-lm1-attach2-----------------------------------------------------------
post.params <- mod_lm_intercept$BUGSoutput$sims.list


## ----jags-plot-lm1, echo=TRUE, eval=TRUE, fig.show='hide'-----------------------
# Now we can make plots of posterior values
par(mfrow = c(2, 1))
hist(post.params$u, 40, col = "grey", xlab = "u", main = "")
hist(post.params$r, 40, col = "grey", xlab = "r", main = "")


## ----jags-plot-hist-post, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-plot-hist-post)'----
par(mfrow = c(2, 1))
hist(post.params$u, 40, col = "grey", xlab = "u", main = "")
hist(post.params$r, 40, col = "grey", xlab = "r", main = "")


## ----jags-lm1-mcmclist-func, cache=TRUE-----------------------------------------
createMcmcList <- function(jagsmodel) {
  McmcArray <- as.array(jagsmodel$BUGSoutput$sims.array)
  McmcList <- vector("list", length = dim(McmcArray)[2])
  for (i in 1:length(McmcList)) McmcList[[i]] <- as.mcmc(McmcArray[, i, ])
  McmcList <- mcmc.list(McmcList)
  return(McmcList)
}


## ----jags-make-myList, fig.show='hide'------------------------------------------
myList <- createMcmcList(mod_lm_intercept)
summary(myList[[1]])
plot(myList[[1]])


## ----jags-plot-myList,fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-plot-myList)'----
plot(myList[[1]])


## ----jags-coda, results='hide', message=FALSE, warning=FALSE--------------------
library(coda)
gelmanDiags <- coda::gelman.diag(createMcmcList(mod_lm_intercept), multivariate = FALSE)
autocorDiags <- coda::autocorr.diag(createMcmcList(mod_lm_intercept))
gewekeDiags <- coda::geweke.diag(createMcmcList(mod_lm_intercept))
heidelDiags <- coda::heidel.diag(createMcmcList(mod_lm_intercept))


## ----jags-cov, results='hide', cache=TRUE---------------------------------------
# 1. LINEAR REGRESSION with covariates

model.loc <- ("lm_covariate.txt")
jagsscript <- cat("
model {  
   u ~ dnorm(0, 0.01); 
   C ~ dnorm(0,0.01);
   inv.r ~ dgamma(0.001,0.001); 
   r <- 1/inv.r; 
   
   for(i in 1:N) {
      X[i] <- u + C*c[i];
      EY[i] <- X[i]
      Y[i] ~ dnorm(EY[i], inv.r);
   }
}  
", file = model.loc)

jags.data <- list("Y" = Wind, "N" = N, "c" = Temp)
jags.params <- c("r", "EY", "u", "C")
mod_lm <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3, n.burnin = 5000,
  n.thin = 1, n.iter = 10000, DIC = TRUE
)



## ----jags-lm1ar-plot-func, results='hide'---------------------------------------
plotModelOutput <- function(jagsmodel, Y) {
  # attach the model
  EY <- jagsmodel$BUGSoutput$sims.list$EY
  x <- seq(1, length(Y))
  summaryPredictions <- cbind(
    apply(EY, 2, quantile, 0.025), apply(EY, 2, mean),
    apply(EY, 2, quantile, 0.975)
  )
  plot(Y,
    col = "white", ylim = c(min(c(Y, summaryPredictions)), max(c(Y, summaryPredictions))),
    xlab = "", ylab = "95% CIs of predictions and data", main = paste(
      "JAGS results:",
      jagsmodel$model.file
    )
  )
  polygon(c(x, rev(x)), c(summaryPredictions[, 1], rev(summaryPredictions[, 3])),
    col = "grey70", border = NA
  )
  lines(summaryPredictions[, 2])
  points(Y)
}


## ----jags-lm1ar-plot, results='hide', eval=FALSE, fig.show='hide'---------------
## plotModelOutput(mod_lm, Wind)


## ----jags-lm1ar-plot1, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-lm1ar-plot1)', cache=FALSE----
plotModelOutput(mod_lm, Wind)


## ----jags-rw, results='hide', cache=TRUE----------------------------------------
# RANDOM WALK with drift

model.loc <- ("rw_intercept.txt")
jagsscript <- cat("
model {  
   u ~ dnorm(0, 0.01); 
   inv.q ~ dgamma(0.001,0.001); 
   q <- 1/inv.q;

   X0 ~ dnorm(0, 0.001);
   X[1] ~ dnorm(X0 + u, inv.q);
   for(i in 2:N) {
      X[i] ~ dnorm(X[i-1] + u, inv.q);
   }
}  
", file = model.loc)



## ----jags-rw-fit, results='hide', cache=TRUE------------------------------------
jags.data <- list("X" = Wind, "N" = N)
jags.params <- c("q", "u")
mod_rw_intercept <- R2jags::jags(jags.data,
  parameters.to.save = jags.params, model.file = model.loc,
  n.chains = 3, n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)


## ----jags-ar1est, echo=TRUE, results='hide', cache=TRUE-------------------------
# AR(1) MODEL WITH AND ESTIMATED AR COEFFICIENT

model.loc <- ("ar1_intercept.txt")
jagsscript <- cat("
model {  
   u ~ dnorm(0, 0.01); 
   inv.q ~ dgamma(0.001,0.001); 
   q <- 1/inv.q; 
   b ~ dunif(-1,1);
   
   X0 ~ dnorm(0, inv.q * (1 - b * b));
   X[1] ~ dnorm(b * X0 + u, inv.q);
   for(i in 2:N) {
      X[i] ~ dnorm(b * X[i-1] + u, inv.q);
   }
}  
", file = model.loc)

jags.data <- list("X" = Wind, "N" = N)
jags.params <- c("q", "u", "b")
mod_ar1_intercept <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3, n.burnin = 5000, n.thin = 1,
  n.iter = 10000, DIC = TRUE
)



## ----jags-lm1ar2, results='hide', cache=TRUE------------------------------------
# LINEAR REGRESSION with autocorrelated errors
# no covariates, intercept only.

model.loc <- ("lm_intercept_ar1b.txt")
jagsscript <- cat("
model {  
   a ~ dnorm(0, 0.01); 
   inv.q ~ dgamma(0.001,0.001); 
   q <- 1/inv.q; 
   b ~ dunif(-1,1);
   
   X0 ~ dnorm(0, inv.q * (1 - b * b));
   # t=1
   EY[1] = a + b * X0;
   Y[1] ~ dnorm(EY[1], inv.q);
   X[1] <- Y[1] - a;
   for(i in 2:N) {
      EY[i] = a + b * X[i-1];
      Y[i] ~ dnorm(EY[1], inv.q);
      X[i] <- Y[i]-a;
   }
}  
", file = model.loc)

jags.data <- list("Y" = Wind, "N" = N)
jags.params <- c("q", "EY", "a", "b")
mod_ar1_intercept <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3, n.burnin = 5000, n.thin = 1,
  n.iter = 10000, DIC = TRUE
)



## ----jags-ss1, echo=TRUE, results='hide', cache=TRUE----------------------------
# 5. MAKE THE SS MODEL for a stochastic level model

model.loc <- ("ss_model.txt")
jagsscript <- cat("
model {  
   # priors on parameters
   u ~ dnorm(0, 0.01); 
   inv.q ~ dgamma(0.001,0.001); 
   q <- 1/inv.q;
   inv.r ~ dgamma(0.001,0.001);
   r <- 1/inv.r; 
   X0 ~ dnorm(Y1, 0.001);
   
   X[1] ~ dnorm(X0 + u, inv.q);
   EY[1] <- X[1];
   Y[1] ~ dnorm(EY[1], inv.r);
   for(i in 2:N) {
      X[i] ~ dnorm(X[i-1] + u, inv.q);
      EY[i] <- X[i];
      Y[i] ~ dnorm(EY[i], inv.r); 
   }
}  
", file = model.loc)


## ----jags-ss1-fit, echo=TRUE, results='hide', cache=TRUE------------------------
jags.data <- list("Y" = Wind, "N" = N, Y1 = Wind[1])
jags.params <- c("q", "r", "EY", "u")
mod_ss <- jags(jags.data,
  parameters.to.save = jags.params, model.file = model.loc, n.chains = 3,
  n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)




## ----jags-jagsscript-marss1-----------------------------------------------------
jagsscript <- cat("
model {  
   # Process model
   u ~ dnorm(0, 0.01); # one u
   inv.q~dgamma(0.001,0.001);
   q <- 1/inv.q; # one q

   ## Inital states at t=0
   X0 ~ dnorm(Y1,0.001); # vague normal prior 
   
   EX[1] <- X0 + u;
   X[1] ~ dnorm(EX[1], inv.q);
   for(t in 2:N) {
         EX[t] <- X[t-1] + u;
         X[t] ~ dnorm(EX[t], inv.q);
   }

   # Observation model
   # The Rs are different in each site
   for(i in 1:n) {
     inv.r[i]~dgamma(0.001,0.001);
     r[i] <- 1/inv.r[i];
   }
   # The first A is 0 and the others are estimated
   a[1] <- 0;
   for(i in 2:n) {
     a[i]~dnorm(0,0.001);
   }   
   for(t in 1:N) {
     for(i in 1:n) {
       EY[i,t] <- X[t]+a[i]
       Y[i,t] ~ dnorm(EY[i,t], inv.r[i]);
     }
   }
}  

",file="marss-jags1.txt")



## ----jags-marss1-fit, results='hide', message=FALSE, cache=TRUE-----------------
data(harborSealWA, package="MARSS")
dat <- t(harborSealWA[,2:3])
jags.data <- list("Y" = dat, n = nrow(dat), N = ncol(dat), Y1 = dat[1,1]) 
jags.params <- c("EY", "u", "q", "r")
model.loc <- "marss-jags1.txt" # name of the txt file
mod_marss1 <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3,
  n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)


## ----jags-marss1-hist-----------------------------------------------------------
post.params <- mod_marss1$BUGSoutput$sims.list
par(mfrow=c(2,2))
hist(log(post.params$q), main="log(q)", xlab="")
hist(post.params$u, main="u", xlab="")
hist(log(post.params$r[,1]), main="log(r_1)", xlab="")
hist(log(post.params$r[,2]), main="log(r_2)", xlab="")


## ----jags-marss1-plot-fun, warning=FALSE, message=FALSE-------------------------
make.ey.plot <- function(mod, dat){
   library(ggplot2)
EY <- mod$BUGSoutput$sims.list$EY
n <- nrow(dat); N <- ncol(dat)
df <- c()
for(i in 1:n){
tmp <- data.frame(n = paste0("Y",i),
                  x = 1:N, 
                  ey=apply(EY[,i,, drop=FALSE],3,median),
                  ey.low=apply(EY[,i,, drop=FALSE],3,quantile,probs=0.25),
                  ey.up=apply(EY[,i,, drop=FALSE],3,quantile,probs=0.75),
                  y=dat[i,]
                  )
df <- rbind(df, tmp)
}
ggplot(df, aes(x=x, y=ey)) + geom_line() +
   geom_ribbon(aes(ymin=ey.low, ymax=ey.up), alpha=0.25) +
   geom_point(data=df, aes(x=x, y=y)) +
   facet_wrap(~n) + theme_bw()
}


## ----jags-marss1-plot, warning=FALSE, message=FALSE-----------------------------
make.ey.plot(mod_marss1, dat)


## ----jags-jagsscript-marss2-----------------------------------------------------
jagsscript <- cat("
model {  
   # Process model
   inv.q~dgamma(0.001,0.001);
   q <- 1/inv.q; # one q

   ## Inital states at t=0
   for(i in 1:n) {
      u[i] ~ dnorm(0, 0.01); 
      X0[i] ~ dnorm(Y1[i],0.001); 
   }

   for(i in 1:n) {
     EX[i,1] <- X0[i] + u[i];
     X[i,1] ~ dnorm(EX[i,1], inv.q);
   }
   for(t in 2:N) {
      for(i in 1:n) {
         EX[i,t] <- X[i,t-1] + u[i];
         X[i,t] ~ dnorm(EX[i,t], inv.q);
      }
   }

   # Observation model
   # The Rs are different in each site
   for(i in 1:n) {
     inv.r[i]~dgamma(0.001,0.001);
     r[i] <- 1/inv.r[i];
   }
   for(t in 1:N) {
     for(i in 1:n) {
       EY[i,t] <- X[i,t]
       Y[i,t] ~ dnorm(EY[i,t], inv.r[i]);
     }
   }
}  

",file="marss-jags2.txt")



## ----jags-marss2-fit, results='hide', message=FALSE, cache=TRUE-----------------
data(harborSealWA, package="MARSS")
dat <- t(harborSealWA[,2:3])
jags.data <- list("Y" = dat, n = nrow(dat), N = ncol(dat), Y1 = dat[,1]) 
jags.params <- c("EY", "u", "q", "r")
model.loc <- "marss-jags2.txt" # name of the txt file
mod_marss1 <- R2jags::jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3,
  n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)


## ----jags-marss2-plot, warning=FALSE, message=FALSE-----------------------------
make.ey.plot(mod_marss1, dat)


## ----jags-ss1-pois, echo=TRUE, results='hide'-----------------------------------
# SS MODEL with Poisson errors

model.loc <- ("ss_model_pois.txt")
jagsscript <- cat("
model {  
   # priors on parameters
   u ~ dnorm(0, 0.01); 
   inv.q ~ dgamma(0.001,0.001); 
   q <- 1/inv.q;

   X0 ~ dnorm(0, 0.001);
   X[1] ~ dnorm(X0 + u, inv.q);
   log(EY[1]) <- X[1]
   Y[1] ~ dpois(EY[1])
   for(i in 2:N) {
      X[i] ~ dnorm(X[i-1] + u, inv.q);
      log(EY[i]) <- X[i]
      Y[i] ~ dpois(EY[i]); 
   }
}  
", file = model.loc)


## ----jags-ss1-fit-pois, echo=TRUE, results='hide'-------------------------------
data(wilddogs, package="MARSS")
jags.data <- list("Y" = wilddogs[,2], "N" = nrow(wilddogs))
jags.params <- c("q", "EY", "u")
mod_ss <- jags(jags.data,
  parameters.to.save = jags.params, model.file = model.loc, n.chains = 3,
  n.burnin = 5000, n.thin = 1, n.iter = 10000, DIC = TRUE
)




## ----jags-cov-forecast, results='hide', cache=TRUE------------------------------
jags.data <- list("Y" = c(Wind, NA, NA, NA), "N" = (N + 3))
jags.params <- c("q", "r", "EY", "u")
model.loc <- ("ss_model.txt")
mod_ss_forecast <- jags(jags.data,
  parameters.to.save = jags.params,
  model.file = model.loc, n.chains = 3, n.burnin = 5000, n.thin = 1,
  n.iter = 10000, DIC = TRUE
)


## ----jags-hwdata, echo=TRUE-----------------------------------------------------
Spawners <- c(2662, 1806, 1707, 1339, 1686, 2220, 3121, 5028, 9263, 4567, 1850, 3353, 2836, 3961, 4624, 3262, 3898, 3039, 5966, 5931, 7346, 4911, 3116, 3185, 5590, 2485, 2987, 3829, 4921, 2348, 1932, 3151, 2306, 1686, 4584, 2635, 2339, 1454, 3705, 1510, 1331, 942, 884, 666, 1521, 409, 2388, 1043, 3262, 2606, 4866, 1161, 3070, 3320)
Recruits <- c(12741, 15618, 23675, 37710, 62260, 32725, 8659, 28101, 17054, 29885, 33047, 20059, 35192, 11006, 48154, 35829, 46231, 32405, 20782, 21340, 58392, 21553, 27528, 28246, 35163, 15419, 16276, 32946, 11075, 16909, 22359, 8022, 16445, 2912, 17642, 2929, 7554, 3047, 3488, 577, 4511, 1478, 3283, 1633, 8536, 7019, 3947, 2789, 4606, 3545, 4421, 1289, 6416, 3647)
logRS <- log(Recruits / Spawners)


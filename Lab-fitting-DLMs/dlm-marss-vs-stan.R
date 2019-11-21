######################################
## MARSS ----------------
######################################
library(MARSS)

# load the data
data(SalmonSurvCUI, package="MARSS")
# get time indices
years <- SalmonSurvCUI[,1]
# number of years of data
TT <- length(years)
# get response variable: logit(survival)
dat <- matrix(SalmonSurvCUI[,2],nrow=1)

# get predictor variable
CUI <- SalmonSurvCUI[,3]
## z-score the CUI
CUI.z <- matrix((CUI - mean(CUI))/sqrt(var(CUI)), nrow=1)
# number of regr params (slope + intercept)
m <- dim(CUI.z)[1] + 1

## plot data
par(mfrow=c(m,1), mar=c(4,4,0.1,0), oma=c(0,0,2,0.5))
plot(years, dat, xlab="", ylab="Logit(s)", bty="n", xaxt="n", pch=16, col="darkgreen", type="b")
plot(years, CUI.z, xlab="", ylab="CUI", bty="n", xaxt="n", pch=16, col="blue", type="b")
axis(1,at=seq(1965,2005,5))
mtext("Year of ocean entry", 1, line=3)


## univariate DLM -------------
# for process eqn
B <- diag(m)                     ## 2x2; Identity
U <- matrix(0,nrow=m,ncol=1)     ## 2x1; both elements = 0
Q <- matrix(list(0),m,m)         ## 2x2; all 0 for now
diag(Q) <- c("q.alpha","q.beta") ## 2x2; diag = (q1,q2)

# for observation eqn
Z <- array(NA, c(1,m,TT))   ## NxMxT; empty for now
Z[1,1,] <- rep(1,TT)        ## Nx1; 1's for intercept
Z[1,2,] <- CUI.z            ## Nx1; predictor variable
A <- matrix(0)              ## 1x1; scalar = 0
R <- matrix("r")            ## 1x1; scalar = r

# only need starting values for regr parameters
inits.list <- list(x0=matrix(c(0, 0), nrow=m))
# list of model matrices & vectors
mod.list <- list(B=B, U=U, Q=Q, Z=Z, A=A, R=R)

# fit univariate DLM
dlm1 <- MARSS(dat, inits=inits.list, model=mod.list)


## PLOT STATES -----------------------------
ylabs <- c(expression(alpha[t]), expression(beta[t]))
colr <- c("darkgreen","blue")
par(mfrow=c(m,1), mar=c(4,4,0.1,0), oma=c(0,0,2,0.5))
for(i in 1:m) {
  mn <- dlm1$states[i,]
  se <- dlm1$states.se[i,]
  plot(years,mn,xlab="",ylab=ylabs[i],bty="n",xaxt="n",type="n",
  ylim=c(min(mn-2*se),max(mn+2*se)))
  lines(years, rep(0,TT), lty="dashed")
  lines(years, mn, col=colr[i], lwd=3)
  lines(years, mn+2*se, col=colr[i])
  lines(years, mn-2*se, col=colr[i])
}
axis(1,at=seq(1965,2005,5))
mtext("Year of ocean entry", 1, line=3)


## Generate forecast ----------------
# get list of Kalman filter output
kf.out <- MARSSkfss(dlm1)
## forecasts of regr parameters; 2xT matrix
eta <- kf.out$xtt1
## ts of E(forecasts)
fore.mean <- vector()
for(t in 1:TT) {
  fore.mean[t] <- Z[,,t] %*% eta[,t,drop=FALSE]
}

# variance of regr parameters; 1x2xT array
Phi <- kf.out$Vtt1
## obs variance; 1x1 matrix
R.est <- coef(dlm1, type="matrix")$R
## ts of Var(forecasts)
fore.var <- vector()
for(t in 1:TT) {
  tZ <- matrix(Z[,,t],m,1) ## transpose of Z
  fore.var[t] <- Z[,,t] %*% Phi[,,t] %*% tZ + R.est
}


## plot forecast ----------------------------
layout(matrix(1:2))
ylims=c(min(fore.mean-2*sqrt(fore.var)),max(fore.mean+2*sqrt(fore.var)))
plot(years, t(dat), type="p", pch=16, ylim=ylims,
     col="blue", xlab="", ylab="Logit(s)", xaxt="n")
lines(years, fore.mean, type="l", xaxt="n", ylab="", lwd=3)
lines(years, fore.mean+2*sqrt(fore.var))
lines(years, fore.mean-2*sqrt(fore.var))
axis(1,at=seq(1965,2005,5))
mtext("Year of ocean entry", 1, line=3)


invLogit = function(x) {1/(1+exp(-x))}
ff = invLogit(fore.mean)
fup = invLogit(fore.mean+2*sqrt(fore.var))
flo = invLogit(fore.mean-2*sqrt(fore.var))
ylims=c(min(flo),max(fup))
plot(years, invLogit(t(dat)), type="p", pch=16, ylim=ylims,
     col="blue", xlab="", ylab="Survival", xaxt="n")
lines(years, ff, type="l", xaxt="n", ylab="", lwd=3)
lines(years, fup)
lines(years, flo)
axis(1,at=seq(1965,2005,5))
mtext("Year of ocean entry", 1, line=3)


###########################################
# FIT STAN ---------------
###########################################
plot_F_Theta <- function(m) {
  pars = extract(m)
  fc <- apply(pars$F_Theta, 2, mean)
  fc_lb <- apply(pars$F_Theta, 2, quantile, 0.01)
  fc_ub <- rev(apply(pars$F_Theta, 2, quantile, 0.99))
  xx <- c(years, rev(years))
  plot(x = years, y = y, pch = 16, col="blue", ylim = c(-10,0))
  polygon(x = xx, y = c(fc_lb, fc_ub), col = scales::alpha('gray70', .5), border = NA)
  lines(x = years, y = fc, type="l", lwd = 2)
}

# load the data
data(SalmonSurvCUI, package="MARSS")
# get time indices
years <- SalmonSurvCUI[,1]

library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)
#
y <- SalmonSurvCUI[, 2]
FF <- cbind(1, scale(SalmonSurvCUI[,3]))
mcmc_list = list(n_iter = 6000, n_chain = 1, n_thin = 1, n_warmup = 2000,
  control = list(adapt_delta = .99, max_treedepth = 12))
data_list <- list("N" = length(y), "K" = dim(FF)[2], "F" = FF, "y" = y)


# DLM vectorized non centered model --------------
# model uses non-centered. seems to be efficient and have less divergence and no low ESS problems
mod1 <- rstan::stan(
  here::here("Lab-fitting-DLMS/dlm-vec.stan"),
  data = data_list,
  pars = c("F_Theta", "Theta", "Theta0", "tau", "L_Omega", "R", "L", "Q"),
  control = mcmc_list$control,
  cores = 1L,
  chains = mcmc_list$n_chain,
  warmup = mcmc_list$n_warmup,
  iter = mcmc_list$n_iter,
  thin = mcmc_list$n_thin)
plot_F_Theta(mod1)


# COMPARE MARSS vs danton DLM STAN ---------------------
layout(matrix(1:2))
xx <- c(years, rev(years))
ylims=c(min(fore.mean-2*sqrt(fore.var)),max(fore.mean+2*sqrt(fore.var)))
plot(years, t(dat), type="p", pch=16, ylim=ylims,
     col="blue", xlab="", ylab="Logit(s)", xaxt="n")
lines(years, fore.mean, type="l", xaxt="n", ylab="", lwd=3)
fore.b = c(fore.mean-2*sqrt(fore.var), rev(fore.mean+2*sqrt(fore.var)))
polygon(x = xx, y = fore.b, col = scales::alpha('gray', .5), border = NA)
axis(1,at=seq(1965,2005,5))
mtext("Year of ocean entry", 1, line=3)
#
plot_F_Theta(mod1)


# COMPARE atsar DLM vs mine -----------------------
library(atsar)
lmmod = lm(SalmonSurvCUI$logit.s ~ SalmonSurvCUI$CUI.apr)
mod0 = fit_stan(y = SalmonSurvCUI$logit.s,
               x = model.matrix(lmmod),
               model_name="dlm")

# plot ------------
pars = extract(mod0)
fc2 <- apply(pars$pred, 2, mean)
fc_lb2 <- apply(pars$pred, 2, quantile, 0.025)
fc_ub2 <- rev(apply(pars$pred, 2, quantile, 0.975))
layout(matrix(1:2))
plot(x = years, y = y, pch = 16, col="blue", ylim = c(-10,0))
polygon(x = xx, y = c(fc_lb2, fc_ub2), col = scales::alpha('gray', .5), border = NA)
lines(x = years, y = fc2, type="l")
#
pars = extract(mod1)
fc <- apply(pars$F_Theta, 2, mean)
fc_lb <- apply(pars$F_Theta, 2, quantile, 0.025)
fc_ub <- rev(apply(pars$F_Theta, 2, quantile, 0.975))
plot(x = years, y = y, pch = 16, col="blue", ylim = ylims)
polygon(x = xx, y = c(fc_lb, fc_ub), col = scales::alpha('gray', .5), border = NA)
lines(x = years, y = fc, type="l")


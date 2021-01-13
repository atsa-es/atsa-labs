## ----stan-setup, include=FALSE--------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, comment=NA, cache=TRUE, tidy.opts=list(width.cutoff=60), tidy=TRUE, fig.align='center', out.width='80%')


## ----stan-load, eval=FALSE------------------------------------------------------------
library(devtools)
devtools::install_github("nwfsc-timeseries/atsar")


## ----stan-loadpackages, results='hide', warning=FALSE, message=FALSE------------------
library(atsar)
library(rstan)
library(loo)


## ----stan-rstan-setup, warning=FALSE, message=FALSE, results='hide'-------------------
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


## ----stan-data------------------------------------------------------------------------
data(airquality, package="datasets")
Wind <- airquality$Wind # wind speed
Temp <- airquality$Temp # air temperature


## ----stan-lm--------------------------------------------------------------------------
x <- model.matrix(lm(Temp~1))


## ----stan-lr1, warning=FALSE, message=FALSE, results='hide', cache=TRUE---------------
lm_intercept <- atsar::fit_stan(y = as.numeric(Temp), x = rep(1, length(Temp)),
  model_name = "regression")


## ----stan-lm-sum, results='hide'------------------------------------------------------
lm_intercept
# this is huge
summary(lm_intercept)


## ----stan-extract-lm------------------------------------------------------------------
pars <- rstan::extract(lm_intercept)
names(pars)


## ----stan-hist------------------------------------------------------------------------
hist(pars$beta, 40, col="grey", xlab="Intercept", main="")
quantile(pars$beta, c(0.025,0.5,0.975))


## ----stan-fig-lm, fig.cap='Data and predicted values for the linear regression model.'----
plot(apply(pars$pred, 2, mean), main="Predicted values", lwd=2, 
  ylab="Wind", ylim= c(min(pars$pred), max(pars$pred)), type="l")
lines(apply(pars$pred, 2, quantile,0.025))
lines(apply(pars$pred, 2, quantile,0.975))
points(Wind, col="red")


## ----stan-lm2, cache=TRUE, results='hide'---------------------------------------------
lm_intercept <- atsar::fit_stan(y = Temp, x = rep(1, length(Temp)),
  model_name = "regression", 
  mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1))


## ----stan-fig-burnin, fig.cap='A time series of our posterior draws using one chain and no burn-in.'----
pars <- rstan::extract(lm_intercept)
plot(pars$beta)


## ----stan-lr-ar, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-------------
lm_intercept_cor <- atsar::fit_stan(y = Temp, x = rep(1, length(Temp)),
  model_name = "regression_cor", 
  mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1))


## ----stan-rw, cache=TRUE, message=FALSE, warning=FALSE, results='hide'----------------
rw <- atsar::fit_stan(y = Temp, est_drift = FALSE, model_name = "rw")


## ----stan-ar1-fit, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-----------
ar1 <- atsar::fit_stan(y = Temp, x = matrix(1, nrow = length(Temp), ncol = 1), 
  model_name = "ar", est_drift=FALSE, P = 1)


## ----stan-arrw, cache=TRUE, message=FALSE, warning=FALSE, results='hide'--------------
ss_ar <- atsar::fit_stan(y = Temp, est_drift=FALSE, model_name = "ss_ar")
ss_rw <- atsar::fit_stan(y = Temp, est_drift=FALSE, model_name = "ss_rw")


## ----stan-dfa-data--------------------------------------------------------------------
 library(MARSS)
 data(lakeWAplankton, package="MARSS")
 # we want lakeWAplanktonTrans, which has been transformed
 # so the 0s are replaced with NAs and the data z-scored
 dat <- lakeWAplanktonTrans
 # use only the 10 years from 1980-1989
 plankdat <- dat[dat[,"Year"]>=1980 & dat[,"Year"]<1990,]
 # create vector of phytoplankton group names
 phytoplankton <- c("Cryptomonas", "Diatoms", "Greens",
                   "Unicells", "Other.algae")
 # get only the phytoplankton
 dat.spp.1980 <- t(plankdat[,phytoplankton])
 # z-score the data since we subsetted time
 dat.spp.1980 <- dat.spp.1980-apply(dat.spp.1980,1,mean,na.rm=TRUE)
 dat.spp.1980 <- dat.spp.1980/sqrt(apply(dat.spp.1980,1,var,na.rm=TRUE))
 #check our z-score
 apply(dat.spp.1980,1,mean,na.rm=TRUE)
 apply(dat.spp.1980,1,var,na.rm=TRUE)


## ----stan-plot-dfa, fig=TRUE, fig.cap='Phytoplankton data.'---------------------------
#make into ts since easier to plot
dat.ts <- ts(t(dat.spp.1980),frequency=12, start=c(1980,1))
par(mfrow=c(3,2),mar=c(2,2,2,2))
for(i in 1:5) 
  plot(dat.ts[,i], type="b",
       main=colnames(dat.ts)[i],col="blue",pch=16)


## ----stan-dfa-3-trend, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-------
mod_3 <- atsar::fit_dfa(y = dat.spp.1980, num_trends=3)


## ----stan-dfa-rot---------------------------------------------------------------------
rot <- atsar::rotate_trends(mod_3)
names(rot)


## ----stan-dfa-plot-trends, fig=TRUE, fig.cap='Trends.'--------------------------------
matplot(t(rot$trends_mean),type="l",lwd=2,ylab="mean trend")


## ----stan-dfa-5-models, results='hide', cache=TRUE------------------------------------
mod_1 = atsar::fit_dfa(y = dat.spp.1980, num_trends=1)
mod_2 = atsar::fit_dfa(y = dat.spp.1980, num_trends=2)
mod_3 = atsar::fit_dfa(y = dat.spp.1980, num_trends=3)
mod_4 = atsar::fit_dfa(y = dat.spp.1980, num_trends=4)
mod_5 = atsar::fit_dfa(y = dat.spp.1980, num_trends=5)


## ----stan-looic, cache=TRUE, warning=FALSE--------------------------------------------
loo::loo(loo::extract_log_lik(mod_1))$looic


## ----stan-looic-table, cache=TRUE, warning=FALSE--------------------------------------
looics = c(
  loo::loo(loo::extract_log_lik(mod_1))$looic,
  loo::loo(loo::extract_log_lik(mod_2))$looic,
  loo::loo(loo::extract_log_lik(mod_3))$looic,
  loo::loo(loo::extract_log_lik(mod_4))$looic,
  loo::loo(loo::extract_log_lik(mod_5))$looic
  )
looic.table <- data.frame(trends=1:5, LOOIC=looics)
looic.table


## ----stan-harborseal-data-------------------------------------------------------------
data(harborSealWA, package="MARSS")
#the first column is year
matplot(harborSealWA[,1],harborSealWA[,-1],type="l",
        ylab="Log abundance", xlab="")


## ----stan-seal-fit, cache=TRUE, message=FALSE, warning=FALSE, results='hide'----------
seal.mod <- atsar::fit_dfa(y = t(harborSealWA[,-1]), num_trends = 1)


## ----stan-seal-trend, cache=TRUE------------------------------------------------------
pars <- rstan::extract(seal.mod)


## ----stan-plot-seal, fig = TRUE, fig.cap='Estimated states and 95 percent credible intervals.'----
pred_mean <- c(apply(pars$x, c(2,3), mean))
pred_lo <- c(apply(pars$x, c(2,3), quantile, 0.025))
pred_hi <- c(apply(pars$x, c(2,3), quantile, 0.975))

plot(pred_mean, type="l", lwd = 3, ylim = range(c(pred_mean, pred_lo, pred_hi)), main = "Trend")
lines(pred_lo)
lines(pred_hi)


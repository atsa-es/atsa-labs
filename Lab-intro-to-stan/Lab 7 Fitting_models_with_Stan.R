## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----load, warning=FALSE, message=FALSE, results='hide'------------------
library(rstan)
library(devtools)
devtools::install_github("nwfsc-timeseries/atsar")
library(STATS)
# for optimizing stan on your machine,
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

## ------------------------------------------------------------------------
data(airquality, package="datasets")
Wind = airquality$Wind # wind speed
Temp = airquality$Temp # air temperature

## ------------------------------------------------------------------------
x = model.matrix(lm(Temp~1))

## ---- warning=FALSE, message=FALSE, results='hide'-----------------------
lm_intercept = fit_stan(y = as.numeric(Temp), x = rep(1, length(Temp)),
  model_name = "regression")

## ---- eval=FALSE---------------------------------------------------------
## lm_intercept
## summary(lm_intercept)

## ------------------------------------------------------------------------
pars = extract(lm_intercept)
names(pars)

## ------------------------------------------------------------------------
hist(pars$beta, 40, col="grey", xlab="Intercept", main="")
quantile(pars$beta, c(0.025,0.5,0.975))

## ------------------------------------------------------------------------
plot(apply(pars$pred, 2, mean), main="Predicted values", lwd=2, 
  ylab="Wind", ylim= c(min(pars$pred), max(pars$pred)), type="l")
lines(apply(pars$pred, 2, quantile,0.025))
lines(apply(pars$pred, 2, quantile,0.975))
points(Wind, col="red")

## ----eval = FALSE--------------------------------------------------------
## lm_intercept = fit_stan(y = Temp, x = rep(1, length(Temp)),
##   model_name = "regression",
##   mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1))

## ----eval = FALSE--------------------------------------------------------
## lm_intercept_cor = fit_stan(y = Temp, x = rep(1, length(Temp)),
##   model_name = "regression_cor",
##   mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1))

## ---- eval = FALSE-------------------------------------------------------
## rw = fit_stan(y = Temp, est_drift = FALSE, model_name = "rw")

## ----eval = FALSE--------------------------------------------------------
## ar1 = fit_stan(y = Temp, x = matrix(1, nrow = length(Temp), ncol = 1),
##   model_name = "ar", est_drift=FALSE, P = 1)

## ----eval = FALSE--------------------------------------------------------
## ss_ar = fit_stan(y = Temp, est_drift=FALSE, model_name = "ss_ar")
## ss_rw = fit_stan(y = Temp, est_drift=FALSE, model_name = "ss_rw")


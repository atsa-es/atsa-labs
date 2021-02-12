## ----stan-setup, include=FALSE-----------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, comment = NA, cache = TRUE, tidy.opts = list(width.cutoff = 60), tidy = TRUE, fig.align = "center", out.width = "80%", warning=FALSE, message=FALSE)


## ----stan-load, eval=FALSE---------------------------------------------------------------------------------
## library(devtools)
## # Windows users will likely need to set this
## # Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = "true")
## devtools::install_github("nwfsc-timeseries/atsar")
## devtools::install_github("nwfsc-timeseries/tvvarss")
## devtools::install_github("fate-ewi/bayesdfa")


## ----stan-loadpackages, results='hide', warning=FALSE, message=FALSE---------------------------------------
library(atsar)
library(rstan)
library(loo)


## ----stan-rstan-setup, warning=FALSE, message=FALSE, results='hide'----------------------------------------
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


## ----stan-data---------------------------------------------------------------------------------------------
data(airquality, package = "datasets")
Wind <- airquality$Wind # wind speed
Temp <- airquality$Temp # air temperature


## ----stan-lm-----------------------------------------------------------------------------------------------
x <- model.matrix(lm(Temp ~ 1))


## ----stan-lr1, warning=FALSE, message=FALSE, results='hide', cache=TRUE------------------------------------
lm_intercept <- atsar::fit_stan(
  y = as.numeric(Temp), x = rep(1, length(Temp)),
  model_name = "regression"
)


## ----stan-lm-sum, results='hide'---------------------------------------------------------------------------
lm_intercept
# this is huge
summary(lm_intercept)


## ----stan-extract-lm---------------------------------------------------------------------------------------
pars <- rstan::extract(lm_intercept)
names(pars)


## ----stan-hist---------------------------------------------------------------------------------------------
hist(pars$beta, 40, col = "grey", xlab = "Intercept", main = "")
quantile(pars$beta, c(0.025, 0.5, 0.975))


## ----stan-fig-lm, fig.cap='Data and predicted values for the linear regression model.'---------------------
plot(apply(pars$pred, 2, mean),
  main = "Predicted values", lwd = 2,
  ylab = "Wind", ylim = c(min(pars$pred), max(pars$pred)), type = "l"
)
lines(apply(pars$pred, 2, quantile, 0.025))
lines(apply(pars$pred, 2, quantile, 0.975))
points(Wind, col = "red")


## ----stan-lm2, cache=TRUE, results='hide'------------------------------------------------------------------
lm_intercept <- atsar::fit_stan(
  y = Temp, x = rep(1, length(Temp)),
  model_name = "regression",
  mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1)
)


## ----stan-fig-burnin, fig.cap='A time series of our posterior draws using one chain and no burn-in.'-------
pars <- rstan::extract(lm_intercept)
plot(pars$beta)


## ----stan-lr-ar, cache=TRUE, message=FALSE, warning=FALSE, results='hide'----------------------------------
lm_intercept_cor <- atsar::fit_stan(
  y = Temp, x = rep(1, length(Temp)),
  model_name = "regression_cor",
  mcmc_list = list(n_mcmc = 1000, n_burn = 1, n_chain = 1, n_thin = 1)
)


## ----stan-rw, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-------------------------------------
rw <- atsar::fit_stan(y = Temp, est_drift = FALSE, model_name = "rw")


## ----stan-ar1-fit, cache=TRUE, message=FALSE, warning=FALSE, results='hide'--------------------------------
ar1 <- atsar::fit_stan(
  y = Temp, x = matrix(1, nrow = length(Temp), ncol = 1),
  model_name = "ar", est_drift = FALSE, P = 1
)


## ----stan-arrw, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-----------------------------------
ss_ar <- atsar::fit_stan(y = Temp, est_drift = FALSE, model_name = "ss_ar")
ss_rw <- atsar::fit_stan(y = Temp, est_drift = FALSE, model_name = "ss_rw")


## ----stan-dfa-data-----------------------------------------------------------------------------------------
library(MARSS)
data(lakeWAplankton, package = "MARSS")
# we want lakeWAplanktonTrans, which has been transformed
# so the 0s are replaced with NAs and the data z-scored
dat <- lakeWAplanktonTrans
# use only the 10 years from 1980-1989
plankdat <- dat[dat[, "Year"] >= 1980 & dat[, "Year"] < 1990, ]
# create vector of phytoplankton group names
phytoplankton <- c(
  "Cryptomonas", "Diatoms", "Greens",
  "Unicells", "Other.algae"
)
# get only the phytoplankton
dat.spp.1980 <- t(plankdat[, phytoplankton])
# z-score the data since we subsetted time
dat.spp.1980 <- MARSS::zscore(dat.spp.1980)
# check our z-score
apply(dat.spp.1980, 1, mean, na.rm = TRUE)
apply(dat.spp.1980, 1, var, na.rm = TRUE)


## ----stan-plot-dfa, fig=TRUE, fig.cap='Phytoplankton data.'------------------------------------------------
# make into ts since easier to plot
dat.ts <- ts(t(dat.spp.1980), frequency = 12, start = c(1980, 1))
par(mfrow = c(3, 2), mar = c(2, 2, 2, 2))
for (i in 1:5) {
  plot(dat.ts[, i],
    type = "b",
    main = colnames(dat.ts)[i], col = "blue", pch = 16
  )
}


## ----stan-dfa-3-trend, cache=TRUE, message=FALSE, warning=FALSE, results='hide'----------------------------
mod_3 <- bayesdfa::fit_dfa(y = dat.spp.1980, num_trends = 3, chains = 1, iter = 1000)


## ----stan-dfa-rot------------------------------------------------------------------------------------------
rot <- bayesdfa::rotate_trends(mod_3)
names(rot)


## ----stan-dfa-plot-trends, fig=TRUE, fig.cap='Trends.'-----------------------------------------------------
matplot(t(rot$trends_mean), type = "l", lwd = 2, ylab = "mean trend")


## ----stan-dfa-5-models, results='hide', cache=TRUE---------------------------------------------------------
mod_1 <- bayesdfa::fit_dfa(y = dat.spp.1980, num_trends = 1, iter = 1000, chains = 1)
mod_2 <- bayesdfa::fit_dfa(y = dat.spp.1980, num_trends = 2, iter = 1000, chains = 1)
mod_3 <- bayesdfa::fit_dfa(y = dat.spp.1980, num_trends = 3, iter = 1000, chains = 1)
mod_4 <- bayesdfa::fit_dfa(y = dat.spp.1980, num_trends = 4, iter = 1000, chains = 1)
# mod_5 = bayesdfa::fit_dfa(y = dat.spp.1980, num_trends=5)


## ----stan-looic, cache=TRUE, warning=FALSE-----------------------------------------------------------------
loo(mod_1)$estimates["looic", "Estimate"]


## ----stan-looic-table, cache=TRUE, warning=FALSE-----------------------------------------------------------
looics <- c(
  loo(mod_1)$estimates["looic", "Estimate"],
  loo(mod_2)$estimates["looic", "Estimate"],
  loo(mod_3)$estimates["looic", "Estimate"],
  loo(mod_4)$estimates["looic", "Estimate"]
)
looic.table <- data.frame(trends = 1:4, LOOIC = looics)
looic.table


## ----stan-harborseal-data----------------------------------------------------------------------------------
data(harborSealWA, package = "MARSS")
# the first column is year
matplot(harborSealWA[, 1], harborSealWA[, -1],
  type = "l",
  ylab = "Log abundance", xlab = ""
)


## ----stan-seal-fit, cache=TRUE, message=FALSE, warning=FALSE, results='hide'-------------------------------
seal.mod <- bayesdfa::fit_dfa(y = t(harborSealWA[, -1]), num_trends = 1, chains = 1, iter = 1000)


## ----stan-seal-trend, cache=TRUE---------------------------------------------------------------------------
pars <- rstan::extract(seal.mod$model)


## ----stan-plot-seal, fig = TRUE, fig.cap='Estimated states and 95 percent credible intervals.'-------------
pred_mean <- c(apply(pars$x, c(2, 3), mean))
pred_lo <- c(apply(pars$x, c(2, 3), quantile, 0.025))
pred_hi <- c(apply(pars$x, c(2, 3), quantile, 0.975))

plot(pred_mean, type = "l", lwd = 3, ylim = range(c(pred_mean, pred_lo, pred_hi)), main = "Trend")
lines(pred_lo)
lines(pred_hi)


## ----------------------------------------------------------------------------------------------------------
data(neon_barc, package="atsalibrary")


## ----------------------------------------------------------------------------------------------------------
data <- neon_barc
data$indx <- seq(1, nrow(data))
n_forecast <- 7
n_lag <- 1


## ----------------------------------------------------------------------------------------------------------
# As a first model, we'll just work with modeling oxygen
o2_dat <- dplyr::filter(data, !is.na(oxygen))

# split the test and training data
last_obs <- max(data$indx) - n_forecast
o2_train <- dplyr::filter(o2_dat, indx <= last_obs)
test <- dplyr::filter(data, indx > last_obs)

o2_x <- o2_train$indx
o2_y <- o2_train$oxygen
o2_sd <- o2_train$oxygen_sd
n_o2 <- nrow(o2_train)


## ----------------------------------------------------------------------------------------------------------
stan_data <- list(
  n = last_obs,
  n_o2 = n_o2,
  n_lag = n_lag,
  n_forecast = n_forecast,
  o2_x = o2_x,
  o2_y = o2_y,
  o2_sd = o2_sd
)


## ----eval=FALSE--------------------------------------------------------------------------------------------
## fit <- stan(file = "model_01.stan", data = stan_data)


## ----eval = FALSE------------------------------------------------------------------------------------------
## m <- stan_model(file = "model_01.stan")
## o2_model <- rstan::optimizing(m, data = stan_data, hessian = TRUE)


## ----eval = FALSE------------------------------------------------------------------------------------------
## data$pred <- o2_model$par[grep("pred", names(o2_model$par))]
## ggplot(data, aes(date, pred)) +
##   geom_line() +
##   geom_point(aes(date, oxygen), col = "red", alpha = 0.5)


## ----eval=FALSE--------------------------------------------------------------------------------------------
## create_stan_data <- function(data, last_obs, n_forecast, n_lag) {
##   o2_test <- dplyr::filter(
##     data,
##     indx %in% seq(last_obs + 1, (last_obs + n_forecast))
##   )
## 
##   o2_train <- dplyr::filter(
##     data,
##     indx <= last_obs, !is.na(oxygen)
##   )
##   o2_x <- o2_train$indx
##   o2_y <- o2_train$oxygen
##   o2_sd <- o2_train$oxygen_sd
##   n_o2 <- nrow(o2_train)
## 
##   stan_data <- list(
##     n = last_obs,
##     n_o2 = n_o2,
##     n_lag = n_lag,
##     n_forecast = n_forecast,
##     o2_x = o2_x,
##     o2_y = o2_y,
##     o2_sd = o2_sd
##   )
## 
##   return(list(
##     train = o2_train,
##     stan_data = stan_data,
##     test = o2_test
##   ))
## }


## ----eval=FALSE--------------------------------------------------------------------------------------------
## n_forecast <- 7
## n_lag <- 1
## rmse <- NA
## for (i in 500:(nrow(data) - n_lag)) {
##   dat_list <- create_stan_data(data, last_obs = i, n_forecast = n_forecast, n_lag = n_lag)
## 
##   # fit the model. opimizing can be sensitive to starting values, so let's try
##   best_map <- -1.0e100
##   for (j in 1:10) {
##     test_fit <- rstan::optimizing(m, data = dat_list$stan_data)
##     if (test_fit$value > best_map) {
##       fit <- test_fit
##       best_map <- test_fit$value
##     }
##   }
##   if (fit$return_code == 0) {
##     # extract forecasts
##     pred <- fit$par[grep("forecast", names(fit$par))]
## 
##     # evaluate predictions
##     rmse[i] <- sqrt(mean((dat_list$test$oxygen - pred)^2, na.rm = T))
##   }
## }


## ----eval=FALSE--------------------------------------------------------------------------------------------
## 
## create_stan_data <- function(data, last_obs, n_forecast, n_lag_o2, n_lag_temp) {
##   # create test data
##   o2_test <- dplyr::filter(data, indx %in% seq(last_obs + 1, (last_obs + n_forecast)))
##   temp_test <- dplyr::filter(data, indx %in% seq(last_obs + 1, (last_obs + n_forecast)))
## 
##   o2_train <- dplyr::filter(data, indx <= last_obs, !is.na(oxygen))
##   o2_x <- o2_train$indx
##   o2_y <- o2_train$oxygen
##   o2_sd <- o2_train$oxygen_sd
##   n_o2 <- nrow(o2_train)
## 
##   temp_train <- dplyr::filter(data, indx <= last_obs, !is.na(temperature))
##   temp_x <- temp_train$indx
##   temp_y <- temp_train$temperature
##   temp_sd <- temp_train$temperature_sd
##   n_temp <- nrow(temp_train)
## 
##   stan_data <- list(
##     n = last_obs,
##     n_lag_o2 = n_lag_o2,
##     n_lag_temp = n_lag_temp,
##     n_forecast = n_forecast,
##     n_o2 = n_o2,
##     o2_x = o2_x,
##     o2_y = o2_y,
##     o2_sd = o2_sd,
##     n_temp = n_temp,
##     temp_x = temp_x,
##     temp_y = temp_y,
##     temp_sd = temp_sd
##   )
## 
##   return(list(
##     o2_train = o2_train, temp_train = temp_train,
##     stan_data = stan_data,
##     o2_test = o2_test, temp_test = temp_test
##   ))
## }


## ----eval=FALSE--------------------------------------------------------------------------------------------
## m <- stan_model(file = "model_02.stan")


## ----eval=FALSE--------------------------------------------------------------------------------------------
## # Now we can try iterating over sets of data with a lag 1 model
## n_forecast <- 7
## n_lag <- 1
## rmse <- NA
## for (i in 500:(nrow(data) - n_lag)) {
##   dat_list <- create_stan_data(data,
##     last_obs = i, n_forecast = n_forecast, n_lag_o2 = n_lag,
##     n_lag_temp = n_lag
##   )
## 
##   # fit the model. opimizing can be sensitive to starting values, so let's try
##   best_map <- -1.0e100
##   for (j in 1:10) {
##     test_fit <- rstan::optimizing(m, data = dat_list$stan_data)
##     if (test_fit$value > best_map) {
##       fit <- test_fit
##       best_map <- test_fit$value
##     }
##   }
## 
##   # extract forecasts
##   o2_pred <- fit$par[grep("o2_forecast", names(fit$par))]
##   temp_pred <- fit$par[grep("temp_forecast", names(fit$par))]
## 
##   pred <- c(o2_pred, temp_pred)
##   obs <- c(dat_list$o2_test$oxygen, dat_list$temp_test$temperature)
##   # evaluate predictions
##   rmse[i] <- sqrt(mean((obs - pred)^2, na.rm = T))
##   print(rmse)
## }


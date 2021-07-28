## ----dlm-loadpackages, warning=FALSE, message=FALSE--------------------------------------------
library(MARSS)


## ----dlm-nile-fit------------------------------------------------------------------------------
## load Nile flow data
data(Nile, package = "datasets")

## define model list
mod_list <- list(B = "identity", U = "zero", Q = matrix("q"),
                 Z = "identity", A = matrix("a"), R = matrix("r"))

## fit the model with MARSS
fit <- MARSS(matrix(Nile, nrow = 1), mod_list)


## ----dlm-nile-fit-plot, echo=FALSE-------------------------------------------------------------
plot.ts(Nile, las = 1, lwd = 2,
        xlab = "Year", ylab = "Flow of the River Nile")
lines(seq(start(Nile)[1], end(Nile)[1]),
       lwd = 2, t(fit$states), col = "blue")
lines(seq(start(Nile)[1], end(Nile)[1]), t(fit$states + 2*fit$states.se),
       lwd = 2, lty = "dashed", col = "blue")
lines(seq(start(Nile)[1], end(Nile)[1]), t(fit$states - 2*fit$states.se),
       lwd = 2, lty = "dashed", col = "blue")


## ----read.in.data, eval=TRUE-------------------------------------------------------------------
## load the data
data(SalmonSurvCUI, package = "MARSS")
## get time indices
years <- SalmonSurvCUI[, 1]
## number of years of data
TT <- length(years)
## get response variable: logit(survival)
dat <- matrix(SalmonSurvCUI[,2], nrow = 1)


## ----z.score, eval=TRUE------------------------------------------------------------------------
## get predictor variable
CUI <- SalmonSurvCUI[,3]
## z-score the CUI
CUI_z <- matrix((CUI - mean(CUI)) / sqrt(var(CUI)), nrow = 1)
## number of regr params (slope + intercept)
m <- dim(CUI_z)[1] + 1


## ----dlm-plotdata, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=4, fig.width=6, fig.cap='(ref:plotdata)'----
par(mfrow = c(m, 1), mar = c(4, 4, 0.1, 0), oma = c(0, 0, 2, 0.5))
plot(years, dat, xlab = "", ylab = "Logit(s)",
     bty = "n", xaxt = "n", pch = 16, col = "darkgreen", type = "b")
plot(years, CUI_z, xlab = "", ylab = "CUI",
     bty = "n", xaxt = "n", pch = 16, col = "blue", type = "b")
axis(1, at = seq(1965, 2005, 5))
mtext("Year of ocean entry", 1, line = 3)


## ----univ.DLM.proc, eval=TRUE------------------------------------------------------------------
## for process eqn
B <- diag(m)                        ## 2x2; Identity
U <- matrix(0, nrow = m, ncol = 1)  ## 2x1; both elements = 0
Q <- matrix(list(0), m, m)          ## 2x2; all 0 for now
diag(Q) <- c("q.alpha", "q.beta")   ## 2x2; diag = (q1,q2)


## ----univ.DLM.obs, eval=TRUE-------------------------------------------------------------------
## for observation eqn
Z <- array(NA, c(1, m, TT))  ## NxMxT; empty for now
Z[1,1,] <- rep(1, TT)        ## Nx1; 1's for intercept
Z[1,2,] <- CUI_z             ## Nx1; predictor variable
A <- matrix(0)               ## 1x1; scalar = 0
R <- matrix("r")             ## 1x1; scalar = r


## ----univ.DLM.list, eval=TRUE------------------------------------------------------------------
## only need starting values for regr parameters
inits_list <- list(x0 = matrix(c(0, 0), nrow = m))

## list of model matrices & vectors
mod_list <- list(B = B, U = U, Q = Q, Z = Z, A = A, R = R)


## ----univ.DLM.fit, eval=TRUE-------------------------------------------------------------------
## fit univariate DLM
dlm_1 <- MARSS(dat, inits = inits_list, model = mod_list)


## ----dlm-plotdlm-1, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=4, fig.width=6, fig.cap='(ref:plotdlm-1)'----
ylabs <- c(expression(alpha[t]), expression(beta[t]))
colr <- c("darkgreen","blue")
par(mfrow = c(m, 1), mar = c(4, 4, 0.1, 0), oma = c(0, 0, 2, 0.5))
for(i in 1:m) {
  mn <- dlm_1$states[i,]
  se <- dlm_1$states.se[i,]
  plot(years, mn, xlab = "", ylab = ylabs[i], bty = "n", xaxt = "n", type = "n",
       ylim = c(min(mn-2*se), max(mn+2*se)))
  lines(years, rep(0,TT), lty = "dashed")
  lines(years, mn, col = colr[i], lwd = 3)
  lines(years, mn+2*se, col = colr[i])
  lines(years, mn-2*se, col = colr[i])
}
axis(1, at = seq(1965, 2005, 5))
mtext("Year of ocean entry", 1, line = 3)


## ----univ.DLM.fore_mean, eval=TRUE-------------------------------------------------------------
## get list of Kalman filter output
kf_out <- MARSSkfss(dlm_1)

## forecasts of regr parameters; 2xT matrix
eta <- kf_out$xtt1

## ts of E(forecasts)
fore_mean <- vector()
for(t in 1:TT) {
  fore_mean[t] <- Z[,,t] %*% eta[, t, drop = FALSE]
}


## ----univ.DLM.fore_var, eval=TRUE--------------------------------------------------------------
## variance of regr parameters; 1x2xT array
Phi <- kf_out$Vtt1

## obs variance; 1x1 matrix
R_est <- coef(dlm_1, type="matrix")$R

## ts of Var(forecasts)
fore_var <- vector()
for(t in 1:TT) {
  tZ <- matrix(Z[, , t], m, 1) ## transpose of Z
  fore_var[t] <- Z[, , t] %*% Phi[, , t] %*% tZ + R_est
}


## ----dlm-plotdlmForeLogit, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.width=6, fig.cap='(ref:plotdlmForeLogit)'----
par(mar = c(4, 4, 0.1, 0), oma = c(0, 0, 2, 0.5))
ylims=c(min(fore_mean - 2*sqrt(fore_var)), max(fore_mean+2*sqrt(fore_var)))
plot(years, t(dat), type = "p", pch = 16, ylim = ylims,
     col = "blue", xlab = "", ylab = "Logit(s)", xaxt = "n")
lines(years, fore_mean, type = "l", xaxt = "n", ylab = "", lwd = 3)
lines(years, fore_mean+2*sqrt(fore_var))
lines(years, fore_mean-2*sqrt(fore_var))
axis(1, at = seq(1965, 2005, 5))
mtext("Year of ocean entry", 1, line = 3)


## ----dlm-plotdlmForeRaw, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.width=6, fig.cap='(ref:plotdlmForeRaw)'----
invLogit <- function(x) {
  1 / ( 1 + exp(-x))
  }
ff <- invLogit(fore_mean)
fup <- invLogit(fore_mean+2*sqrt(fore_var))
flo <- invLogit(fore_mean-2*sqrt(fore_var))
par(mar = c(4, 4, 0.1, 0), oma = c(0, 0, 2, 0.5))
ylims <- c(min(flo), max(fup))
plot(years, invLogit(t(dat)), type = "p", pch = 16, ylim = ylims,
     col = "blue", xlab = "", ylab = "Survival", xaxt = "n")
lines(years, ff, type = "l", xaxt = "n", ylab = "", lwd = 3)
lines(years, fup)
lines(years, flo)
axis(1, at = seq(1965, 2005, 5))
mtext("Year of ocean entry", 1, line = 3)


## ----dlmInnov, eval=TRUE, echo=TRUE------------------------------------------------------------
## forecast errors
innov <- kf_out$Innov


## ----dlmQQplot, eval=FALSE, echo=TRUE----------------------------------------------------------
## ## Q-Q plot of innovations
## qqnorm(t(innov), main = "", pch = 16, col = "blue")
## ## add y=x line for easier interpretation
## qqline(t(innov))


## ----dlm-plotdlmQQ, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=2, fig.width=4, fig.cap='(ref:plotdlmQQ)'----
## use layout to get nicer plots
layout(matrix(c(0,1,1,1,0),1,5,byrow=TRUE))

## set up L plotting space
par(mar=c(4,4,1,0), oma=c(0,0,0,0.5))

## Q-Q plot of innovations
qqnorm(t(innov), main="", pch=16, col="blue")
qqline(t(innov))


## ----dlmInnovTtest, eval=TRUE, echo=TRUE-------------------------------------------------------
## p-value for t-test of H0: E(innov) = 0
t.test(t(innov), mu = 0)$p.value


## ----dlmACFplot, eval=FALSE, echo=TRUE---------------------------------------------------------
## ## plot ACF of innovations
## acf(t(innov), lag.max = 10)


## ----dlm-plotdlmACF, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=2, fig.width=4, fig.cap='(ref:plotdlmACF)'----
## use layout to get nicer plots
layout(matrix(c(0, 1, 1, 1, 0), 1, 5, byrow = TRUE))

## set up plotting space
par(mar = c(4, 4, 1, 0), oma = c(0, 0, 0, 0.5))

## ACF of innovations
acf(t(innov), lwd = 2, lag.max = 10)


## ----echo=FALSE--------------------------------------------------------------------------------
knitr::include_graphics("images/BB_sockeye_rivers_inset.png")
# ![](images/BB_sockeye_rivers_inset.png)


## ----dlm-load-atsa, eval=FALSE-----------------------------------------------------------------
## library(devtools)
## ## Windows users will likely need to set this
## ## Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = "true")
## devtools::install_github("nwfsc-timeseries/atsalibrary")


## ----dlm-read-data-----------------------------------------------------------------------------
data(KvichakSockeye, package="atsalibrary")
SR_data <- KvichakSockeye


## ----dlm-data-head-----------------------------------------------------------------------------
## head of data file
head(SR_data)


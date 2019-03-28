## ----tslab-loadpackages, warning=FALSE, message=FALSE, results='hide'----
library(stats)
library(MARSS)
library(forecast)
library(datasets)


## ----tslab-load-atsa, eval=FALSE-----------------------------------------
## library(devtools)
## devtools::install_github("nwfsc-timeseries/atsalibrary")


## ----tslab-load-data-----------------------------------------------------
data(NHTemp, package="atsalibrary")
Temp <- NHTemp
data(MLCO2, package="atsalibrary")
CO2 <- MLCO2
data(hourlyphyto, package="atsalibrary")
pDat <- hourlyphyto


## ----tslab-CO2ts, echo=TRUE, eval=TRUE-----------------------------------
## create a time series (ts) object from the CO2 data
co2 <- ts(data=CO2$ppm, frequency=12,
          start=c(CO2[1,"year"],CO2[1,"month"]))


## ----tslab-plotdataPar1, eval=FALSE, echo=TRUE---------------------------
## ## plot the ts
## plot.ts(co2, ylab=expression(paste("CO"[2]," (ppm)")))


## ----tslab-plotdata1, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotdata1)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(co2, ylab=expression(paste("CO"[2]," (ppm)")))


## ----tslab-Temp-data-ts--------------------------------------------------
temp.ts <- ts(data=Temp$Value, frequency=12, start=c(1880,1))


## ----tslab-alignData, echo=TRUE, eval=TRUE-------------------------------
## intersection (only overlapping times)
datI <- ts.intersect(co2,temp.ts)
## dimensions of common-time data
dim(datI)
## union (all times)
datU <- ts.union(co2,temp.ts)
## dimensions of all-time data
dim(datU)


## ----tslab-plotdataPar2, eval=FALSE, echo=TRUE, fig.show='hide'----------
## ## plot the ts
## plot(datI, main="", yax.flip=TRUE)


## ----tslab-plotdata2, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=5, fig.cap='(ref:tslab-plotdata2)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot(datI, main="", yax.flip=TRUE)


## ----tslab-makeFilter, eval=TRUE, echo=TRUE------------------------------
## weights for moving avg
fltr <- c(1/2,rep(1,times=11),1/2)/12


## ----tslab-plotTrendTSa, eval=FALSE, echo=TRUE---------------------------
## ## estimate of trend
## co2.trend <- filter(co2, filter=fltr, method="convo", sides=2)
## ## plot the trend
## plot.ts(co2.trend, ylab="Trend", cex=1)


## ----tslab-plotTrendTSb, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotTrendTSb)'----
## estimate of trend
co2.trend <- filter(co2, filter=fltr, method="convo", sides=2)
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(co2.trend, ylab="Trend", cex=1)


## ----tslab-getSeason, eval=TRUE, echo=TRUE-------------------------------
## seasonal effect over time
co2.1T <- co2 - co2.trend


## ----tslab-plotSeasTSa, eval=FALSE, echo=TRUE, fig.show='hide'-----------
## ## plot the monthly seasonal effects
## plot.ts(co2.1T, ylab="Seasonal effect", xlab="Month", cex=1)


## ----tslab-plotSeasTSb, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotSeasTSb)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(co2.1T, ylab="Seasonal effect plus errors", xlab="Month", cex=1)


## ----tslab-getSeasonTS, eval=TRUE, echo=TRUE-----------------------------
## length of ts
ll <- length(co2.1T)
## frequency (ie, 12)
ff <- frequency(co2.1T)
## number of periods (years); %/% is integer division
periods <- ll %/% ff
## index of cumulative month
index <- seq(1,ll,by=ff) - 1
## get mean by month
mm <- numeric(ff)
for(i in 1:ff) {
  mm[i] <- mean(co2.1T[index+i], na.rm=TRUE)
}
## subtract mean to make overall mean=0
mm <- mm - mean(mm)


## ----tslab-plotdataPar3, eval=FALSE, echo=TRUE, fig.show='hide'----------
## ## plot the monthly seasonal effects
## plot.ts(mm, ylab="Seasonal effect", xlab="Month", cex=1)


## ----tslab-plotSeasMean, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotSeasMean)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(mm, ylab="Seasonal effect", xlab="Month", cex=1)


## ----tslab-getSeasonMean, eval=TRUE, echo=TRUE---------------------------
## create ts object for season
co2.seas <- ts(rep(mm, periods+1)[seq(ll)],
               start=start(co2.1T), 
               frequency=ff)


## ----tslab-getError, eval=TRUE, echo=TRUE--------------------------------
## random errors over time
co2.err <- co2 - co2.trend - co2.seas


## ----tslab-plotdataPar4, eval=FALSE, echo=TRUE, fig.show='hide'----------
## ## plot the obs ts, trend & seasonal effect
## plot(cbind(co2,co2.trend,co2.seas,co2.err),main="",yax.flip=TRUE)


## ----tslab-plotTrSeas, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=6, fig.cap='(ref:tslab-plotTrSeas)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot(cbind(co2,co2.trend,co2.seas,co2.err), main="", yax.flip=TRUE)


## ----tslab-decompCO2, eval=TRUE, echo=TRUE-------------------------------
## decomposition of CO2 data
co2.decomp <- decompose(co2)


## ----tslab-plotDecompA, eval=FALSE, echo=TRUE, fig.show='hide'-----------
## ## plot the obs ts, trend & seasonal effect
## plot(co2.decomp, yax.flip=TRUE)


## ----tslab-plotDecompB, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=6, fig.cap='(ref:tslab-plotDecompB)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot(co2.decomp, yax.flip=TRUE)


## ----tslab-plotCO2diff2Echo, eval=FALSE, echo=TRUE, fig.show='hide'------
## ## twice-difference the CO2 data
## co2.D2 <- diff(co2, differences=2)
## ## plot the differenced data
## plot(co2.D2, ylab=expression(paste(nabla^2,"CO"[2])))


## ----tslab-plotCO2diff2eval, eval=TRUE, echo=FALSE-----------------------
## twice-difference the CO2 data
co2.D2 <- diff(co2, differences=2)


## ----tslab-plotCO2diff2, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotCO2diff2)'----
## set the margins & text size
par(mar=c(4,4.5,1,1), oma=c(0,0,0,0), cex=1)
## plot the differenced data
plot(co2.D2, ylab=expression(paste(nabla^2,"CO"[2])))


## ----tslab-plotCO2diff12Echo, eval=FALSE, echo=TRUE----------------------
## ## difference the differenced CO2 data
## co2.D2D12 <- diff(co2.D2, lag=12)
## ## plot the newly differenced data
## plot(co2.D2D12,
##      ylab=expression(paste(nabla,"(",nabla^2,"CO"[2],")")))


## ----tslab-plotCO2diff12eval, eval=TRUE, echo=FALSE----------------------
## difference the differenced CO2 data
co2.D2D12 <- diff(co2.D2, lag=12)


## ----tslab-plotCO2diff12, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotCO2diff12)'----
## set the margins & text size
par(mar=c(4,4.5,1,1), oma=c(0,0,0,0), cex=1)
## plot the newly differenced data
plot(co2.D2D12, ylab=expression(paste(nabla,"(",nabla^2,"CO"[2],")")))


## ----tslab-plotACFa, eval=FALSE, echo=TRUE-------------------------------
## ## correlogram of the CO2 data
## acf(co2, lag.max=36)


## ----tslab-plotACFb, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotACFb)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## correlogram of the CO2 data
acf(co2, lag.max=36)


## ----tslab-BetterPlotACF, eval=TRUE, echo=TRUE---------------------------
## better ACF plot
plot.acf <- function(ACFobj) {
  rr <- ACFobj$acf[-1]
  kk <- length(rr)
  nn <- ACFobj$n.used
  plot(seq(kk),rr,type="h",lwd=2,yaxs="i",xaxs="i",
       ylim=c(floor(min(rr)),1),xlim=c(0,kk+1),
       xlab="Lag",ylab="Correlation",las=1)
  abline(h=-1/nn+c(-2,2)/sqrt(nn),lty="dashed",col="blue")
  abline(h=0)
}


## ----tslab-betterACF, eval=FALSE, echo=TRUE------------------------------
## ## acf of the CO2 data
## co2.acf <- acf(co2, lag.max=36)
## ## correlogram of the CO2 data
## plot.acf(co2.acf)


## ----tslab-DoOurACF, eval=TRUE, echo=FALSE-------------------------------
## acf of the CO2 data
co2.acf <- acf(co2, lag.max=36)


## ----tslab-plotbetterACF, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotbetterACF)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## correlogram of the CO2 data
plot.acf(co2.acf)


## ----tslab-LinearACFecho, eval=FALSE, echo=TRUE--------------------------
## ## length of ts
## nn <- 100
## ## create straight line
## tt <- seq(nn)
## ## set up plot area
## par(mfrow=c(1,2))
## ## plot line
## plot.ts(tt, ylab=expression(italic(x[t])))
## ## get ACF
## line.acf <- acf(tt, plot=FALSE)
## ## plot ACF
## plot.acf(line.acf)


## ----tslab-LinearACF, eval=TRUE, echo=FALSE------------------------------
## length of ts
nn <- 100
## create straight line
tt <- seq(nn)
## get ACF
line.acf <- acf(tt)


## ----tslab-plotLinearACF, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotLinearACF)'----
## set the margins & text size
par(mfrow=c(1,2), mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot line
plot.ts(tt, ylab=expression(italic(x[t])))
## plot ACF
plot.acf(line.acf)


## ----tslab-SineACFecho, eval=FALSE, echo=TRUE----------------------------
## ## create sine wave
## tt <- sin(2*pi*seq(nn)/12)
## ## set up plot area
## par(mfrow=c(1,2))
## ## plot line
## plot.ts(tt, ylab=expression(italic(x[t])))
## ## get ACF
## sine.acf <- acf(tt, plot=FALSE)
## ## plot ACF
## plot.acf(sine.acf)


## ----tslab-SineACF, eval=TRUE, echo=FALSE--------------------------------
## create sine wave
tt <- sin(2*pi*seq(nn)/12)
## get ACF
sine.acf <- acf(tt, plot=FALSE)


## ----tslab-plotSineACF, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotSineACF)'----
## set the margins & text size
par(mfrow=c(1,2), mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot line
plot.ts(tt, ylab=expression(italic(x[t])))
## plot ACF
plot.acf(sine.acf)


## ----tslab-SiLineACFecho, eval=FALSE, echo=TRUE--------------------------
## ## create sine wave with trend
## tt <- sin(2*pi*seq(nn)/12) - seq(nn)/50
## ## set up plot area
## par(mfrow=c(1,2))
## ## plot line
## plot.ts(tt, ylab=expression(italic(x[t])))
## ## get ACF
## sili.acf <- acf(tt, plot=FALSE)
## ## plot ACF
## plot.acf(sili.acf)


## ----tslab-SiLiACF, eval=TRUE, echo=FALSE--------------------------------
## create sine wave with trend
tt <- sin(2*pi*seq(nn)/12) - seq(nn)/50
## get ACF
sili.acf <- acf(tt, plot=FALSE)


## ----tslab-plotSiLiACF, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotSiLiACF)'----
## set the margins & text size
par(mfrow=c(1,2), mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot line
plot.ts(tt, ylab=expression(italic(x[t])))
## plot ACF
plot.acf(sili.acf)


## ----tslab-plotPACFa, eval=FALSE, echo=TRUE------------------------------
## ## PACF of the CO2 data
## pacf(co2, lag.max=36)


## ----tslab-BetterPlotPACF, eval=TRUE, echo=TRUE--------------------------
## better PACF plot
plot.pacf <- function(PACFobj) {
  rr <- PACFobj$acf
  kk <- length(rr)
  nn <- PACFobj$n.used
  plot(seq(kk),rr,type="h",lwd=2,yaxs="i",xaxs="i",
       ylim=c(floor(min(rr)),1),xlim=c(0,kk+1),
       xlab="Lag",ylab="PACF",las=1)
  abline(h=-1/nn+c(-2,2)/sqrt(nn),lty="dashed",col="blue")
  abline(h=0)
}


## ----tslab-plotPACFb, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotPACFb)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## correlogram of the CO2 data
pacf(co2, lag.max=36)


## ----tslab-CO2PACFecho, eval=FALSE, echo=TRUE----------------------------
## ## PACF of the CO2 data
## co2.pacf <- pacf(co2)
## ## correlogram of the CO2 data
## plot.acf(co2.pacf)


## ----tslab-LynxSunspotCCF, eval=TRUE, echo=TRUE--------------------------
## get the matching years of sunspot data
suns <- ts.intersect(lynx,sunspot.year)[,"sunspot.year"]
## get the matching lynx data
lynx <- ts.intersect(lynx,sunspot.year)[,"lynx"]


## ----tslab-plotSunsLynxEcho, eval=FALSE, echo=TRUE-----------------------
## ## plot time series
## plot(cbind(suns,lynx), yax.flip=TRUE)


## ----tslab-plotSunsLynx, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=6, fig.cap='(ref:tslab-plotSunsLynx)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot(cbind(suns,lynx), main="", yax.flip=TRUE)


## ----tslab-plotCCFa, eval=FALSE, echo=TRUE-------------------------------
## ## CCF of sunspots and lynx
## ccf(suns, log(lynx), ylab="Cross-correlation")


## ----tslab-plotCCFb, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotCCFb)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## CCF of sunspots and lynx
ccf(suns, lynx, ylab="Cross-correlation")


## ----tslab-DWNsim, echo=TRUE, eval=TRUE----------------------------------
set.seed(123)
## random normal variates
GWN <- rnorm(n=100, mean=5, sd=0.2)
## random Poisson variates
PWN <- rpois(n=50, lambda=20)


## ----tslab-DWNsimPlotEcho, echo=TRUE, eval=FALSE-------------------------
## ## set up plot region
## par(mfrow=c(1,2))
## ## plot normal variates with mean
## plot.ts(GWN)
## abline(h=5, col="blue", lty="dashed")
## ## plot Poisson variates with mean
## plot.ts(PWN)
## abline(h=20, col="blue", lty="dashed")


## ----tslab-plotDWNsims, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotDWNsims)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1, mfrow=c(1,2))
## plot normal variates with mean
plot.ts(GWN)
abline(h=5, col="blue", lty="dashed")
## plot Poisson variates with mean
plot.ts(PWN)
abline(h=20, col="blue", lty="dashed")


## ----tslab-DWNacfEcho, echo=TRUE, eval=FALSE-----------------------------
## ## set up plot region
## par(mfrow=c(1,2))
## ## plot normal variates with mean
## acf(GWN, main="", lag.max=20)
## ## plot Poisson variates with mean
## acf(PWN, main="", lag.max=20)


## ----tslab-plotACFdwn, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotACFdwn)'----
## set the margins & text size
par(mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1, mfrow=c(1,2))
## plot normal variates with mean
acf(GWN, main="", lag.max=20)
## plot Poisson variates with mean
acf(PWN, main="", lag.max=20)


## ----tslab-RWsim, eval=TRUE, echo=TRUE-----------------------------------
## set random number seed
set.seed(123)
## length of time series
TT <- 100
## initialize {x_t} and {w_t}
xx <- ww <- rnorm(n=TT, mean=0, sd=1)
## compute values 2 thru TT
for(t in 2:TT) { xx[t] <- xx[t-1] + ww[t] }


## ----tslab-plotRWecho, eval=FALSE, echo=TRUE-----------------------------
## ## setup plot area
## par(mfrow=c(1,2))
## ## plot line
## plot.ts(xx, ylab=expression(italic(x[t])))
## ## plot ACF
## plot.acf(acf(xx, plot=FALSE))


## ----tslab-calcRWACF, eval=TRUE, echo=FALSE------------------------------
xx.acf <- acf(xx, plot=FALSE)


## ----tslab-plotRW, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotRW)'----
## setup plot area
par(mfrow=c(1,2), mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot line
plot.ts(xx, ylab=expression(italic(x[t])))
## plot ACF
plot.acf(xx.acf)


## ----tslab-RWsimAlt, eval=TRUE, echo=TRUE--------------------------------
## simulate RW
x2 <- cumsum(ww)


## ----tslab-plotRWsimEcho, eval=FALSE, echo=TRUE--------------------------
## ## setup plot area
## par(mfrow=c(1,2))
## ## plot 1st RW
## plot.ts(xx, ylab=expression(italic(x[t])))
## ## plot 2nd RW
## plot.ts(x2, ylab=expression(italic(x[t])))


## ----tslab-plotRWalt, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotRWalt)'----
## setup plot area
par(mfrow=c(1,2), mar=c(4,4,1,1), oma=c(0,0,0,0), cex=1)
## plot 1st RW
plot.ts(xx, ylab=expression(italic(x[t])))
## plot 2nd RW
plot.ts(x2, ylab=expression(italic(x[t])))


## ----tslab-simAR1, echo=TRUE, eval=TRUE----------------------------------
set.seed(456)
## list description for AR(1) model with small coef
AR.sm <- list(order=c(1,0,0), ar=0.1, sd=0.1)
## list description for AR(1) model with large coef
AR.lg <- list(order=c(1,0,0), ar=0.9, sd=0.1)
## simulate AR(1)
AR1.sm <- arima.sim(n=50, model=AR.sm)
AR1.lg <- arima.sim(n=50, model=AR.lg)


## ----tslab-plotAR1sims, eval=FALSE, echo=TRUE----------------------------
## ## setup plot region
## par(mfrow=c(1,2))
## ## get y-limits for common plots
## ylm <- c(min(AR1.sm,AR1.lg), max(AR1.sm,AR1.lg))
## ## plot the ts
## plot.ts(AR1.sm, ylim=ylm,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(phi," = 0.1")))
## plot.ts(AR1.lg, ylim=ylm,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(phi," = 0.9")))


## ----tslab-getPlotLims, eval=TRUE, echo=FALSE----------------------------
## get y-limits for common plots
ylm <- c(min(AR1.sm,AR1.lg), max(AR1.sm,AR1.lg))


## ----tslab-plotAR1contrast, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotAR1contrast)'----
## set the margins & text size
par(mfrow=c(1,2), mar=c(4,4,1.5,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(AR1.sm, ylim=ylm,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(phi," = 0.1")))
plot.ts(AR1.lg, ylim=ylm,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(phi," = 0.9")))


## ----tslab-simAR1opps, echo=TRUE, eval=TRUE------------------------------
set.seed(123)
## list description for AR(1) model with small coef
AR.pos <- list(order=c(1,0,0), ar=0.5, sd=0.1)
## list description for AR(1) model with large coef
AR.neg <- list(order=c(1,0,0), ar=-0.5, sd=0.1)
## simulate AR(1)
AR1.pos <- arima.sim(n=50, model=AR.pos)
AR1.neg <- arima.sim(n=50, model=AR.neg)


## ----tslab-plotAR1oppsEcho, eval=FALSE, echo=TRUE------------------------
## ## setup plot region
## par(mfrow=c(1,2))
## ## get y-limits for common plots
## ylm <- c(min(AR1.pos,AR1.neg), max(AR1.pos,AR1.neg))
## ## plot the ts
## plot.ts(AR1.pos, ylim=ylm,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(phi[1]," = 0.5")))
## plot.ts(AR1.neg,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(phi[1]," = -0.5")))


## ----tslab-getPlotLimsOpps, eval=TRUE, echo=FALSE------------------------
## get y-limits for common plots
ylm <- c(min(AR1.pos,AR1.neg), max(AR1.pos,AR1.neg))


## ----tslab-plotAR1opps, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotAR1opps)'----
## set the margins & text size
par(mfrow=c(1,2), mar=c(4,4,1.5,1), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(AR1.pos, ylim=ylm,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(phi[1]," = 0.5")))
plot.ts(AR1.neg, ylim=ylm,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(phi[1]," = -0.5")))


## ----tslab-ARpFail, eval=FALSE, echo=TRUE--------------------------------
## arima.sim(n=100, model=list(order(2,0,0), ar=c(0.5,0.5)))


## ----tslab-ARpSims, eval=TRUE, echo=TRUE---------------------------------
set.seed(123)
## the 4 AR coefficients
ARp <- c(0.7, 0.2, -0.1, -0.3)
## empty list for storing models
AR.mods <- list()
## loop over orders of p
for(p in 1:4) {
  ## assume SD=1, so not specified
  AR.mods[[p]] <- arima.sim(n=10000, list(ar=ARp[1:p]))
}


## ----tslab-plotARpCompsEcho, eval=FALSE, echo=TRUE-----------------------
## ## set up plot region
## par(mfrow=c(4,3))
## ## loop over orders of p
## for(p in 1:4) {
##   plot.ts(AR.mods[[p]][1:50],
##           ylab=paste("AR(",p,")",sep=""))
##   acf(AR.mods[[p]], lag.max=12)
##   pacf(AR.mods[[p]], lag.max=12, ylab="PACF")
## }


## ----tslab-plotARpComps, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=8, fig.cap='(ref:tslab-plotARpComps)'----
## set the margins & text size
par(mfrow=c(4,3), mar=c(4,4,0.5,0.5), oma=c(0,0,0,0), cex=1)
## loop over orders of p
for(p in 1:4) {
  plot.ts(AR.mods[[p]][1:50],ylab=paste("AR(",p,")",sep=""))
  acf(AR.mods[[p]], lag.max=12)
  pacf(AR.mods[[p]], lag.max=12, ylab="PACF")
}


## ----tslab-simMA1opps, echo=TRUE, eval=TRUE------------------------------
set.seed(123)
## list description for MA(1) model with small coef
MA.sm <- list(order=c(0,0,1), ma=0.2, sd=0.1)
## list description for MA(1) model with large coef
MA.lg <- list(order=c(0,0,1), ma=0.8, sd=0.1)
## list description for MA(1) model with large coef
MA.neg <- list(order=c(0,0,1), ma=-0.5, sd=0.1)
## simulate MA(1)
MA1.sm <- arima.sim(n=50, model=MA.sm)
MA1.lg <- arima.sim(n=50, model=MA.lg)
MA1.neg <- arima.sim(n=50, model=MA.neg)


## ----tslab-plotMA1oppsEcho, eval=FALSE, echo=TRUE------------------------
## ## setup plot region
## par(mfrow=c(1,3))
## ## plot the ts
## plot.ts(MA1.sm,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(theta," = 0.2")))
## plot.ts(MA1.lg,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(theta," = 0.8")))
## plot.ts(MA1.neg,
##         ylab=expression(italic(x)[italic(t)]),
##         main=expression(paste(theta," = -0.5")))


## ----tslab-plotMA1opps, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=3, fig.cap='(ref:tslab-plotMA1opps)'----
## set the margins & text size
par(mfrow=c(1,3), mar=c(4,4,1.5,0.5), oma=c(0,0,0,0), cex=1)
## plot the ts
plot.ts(MA1.sm,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(theta," = 0.2")))
plot.ts(MA1.lg,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(theta," = 0.8")))
plot.ts(MA1.neg,
        ylab=expression(italic(x)[italic(t)]),
        main=expression(paste(theta," = -0.5")))


## ----tslab-MAqSims, eval=TRUE, echo=TRUE---------------------------------
set.seed(123)
## the 4 MA coefficients
MAq <- c(0.7, 0.2, -0.1, -0.3)
## empty list for storing models
MA.mods <- list()
## loop over orders of q
for(q in 1:4) {
  ## assume SD=1, so not specified
  MA.mods[[q]] <- arima.sim(n=1000, list(ma=MAq[1:q]))
}


## ----tslab-plotMApCompsEcho, eval=FALSE, echo=TRUE-----------------------
## ## set up plot region
## par(mfrow=c(4,3))
## ## loop over orders of q
## for(q in 1:4) {
##   plot.ts(MA.mods[[q]][1:50],
##           ylab=paste("MA(",q,")",sep=""))
##   acf(MA.mods[[q]], lag.max=12)
##   pacf(MA.mods[[q]], lag.max=12, ylab="PACF")
## }


## ----tslab-plotMApComps, eval=TRUE, echo=FALSE, fig=TRUE, fig.height=8, fig.cap='(ref:tslab-plotMApComps)'----
## set the margins & text size
par(mfrow=c(4,3), mar=c(4,4,0.5,0.5), oma=c(0,0,0,0), cex=1)
## loop over orders of q
for(q in 1:4) {
  plot.ts(MA.mods[[q]][1:50],ylab=paste("MA(",q,")",sep=""))
  acf(MA.mods[[q]], lag.max=12)
  pacf(MA.mods[[q]], lag.max=12, ylab="PACF")
}


## ----tslab-ARMAest, eval=TRUE, echo=TRUE---------------------------------
set.seed(123)
## ARMA(2,2) description for arim.sim()
ARMA22 <- list(order=c(2,0,2), ar=c(-0.7,0.2), ma=c(0.7,0.2))
## mean of process
mu <- 5
## simulated process (+ mean)
ARMA.sim <- arima.sim(n=10000, model=ARMA22) + mu
## estimate parameters
arima(x=ARMA.sim, order=c(2,0,2))


## ----tslab-ARMAsearch1, eval=TRUE, echo=TRUE, cache=TRUE-----------------
## empty list to store model fits
ARMA.res <- list()
## set counter
cc <- 1
## loop over AR
for(p in 0:3) {
  ## loop over MA
  for(q in 0:3) {
    ARMA.res[[cc]] <- arima(x=ARMA.sim,order=c(p,0,q))
    cc <- cc + 1
  }
}
## get AIC values for model evaluation
ARMA.AIC <- sapply(ARMA.res,function(x) x$aic)
## model with lowest AIC is the best
ARMA.res[[which(ARMA.AIC==min(ARMA.AIC))]]


## ----tslab-autoARIMA, eval=TRUE, echo=TRUE, cache=TRUE-------------------
## find best ARMA(p,q) model
auto.arima(ARMA.sim, start.p=0, max.p=3, start.q=0, max.q=3)


## ----tslab-HWdata--------------------------------------------------------
data(hourlyphyto, package="atsalibrary")
pDat <- hourlyphyto


## ----tslab-HW1_1, eval=FALSE, echo=TRUE----------------------------------
## ## what day of 2014 is Dec 1st?
## dBegin <- as.Date("2014-12-01")
## dayOfYear <- (dBegin - as.Date("2014-01-01") + 1)


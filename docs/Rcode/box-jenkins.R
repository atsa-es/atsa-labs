## ----bj-load, eval=FALSE-------------------------------------------------
## library(devtools)
## devtools::install_github("nwfsc-timeseries/atsalibrary")


## ----bj-read-data--------------------------------------------------------
data(greeklandings, package="atsalibrary")
landings <- greeklandings
# Use the monthly data
data(chinook, package="atsalibrary")
chinook <- chinook.month


## ----bj-load-packages----------------------------------------------------
library(ggplot2)
library(gridExtra)
library(reshape2)
library(tseries)
library(urca)
library(forecast)


## ----bj-set-seed-invisible, echo=FALSE-----------------------------------
set.seed(123)


## ----bj-white-noise------------------------------------------------------
TT <- 100
y <- rnorm(TT, mean=0, sd=1) # 100 random numbers
op <- par(mfrow=c(1,2))
plot(y, type="l")
acf(y)
par(op)


## ----bj-white-noise-ggplot-----------------------------------------------
dat <- data.frame(t=1:TT, y=y)
p1 <- ggplot(dat, aes(x=t, y=y)) + geom_line() + 
  ggtitle("1 white noise time series") + xlab("") + ylab("value")
ys <- matrix(rnorm(TT*10),TT,10)
ys <- data.frame(ys)
ys$id = 1:TT

ys2 <- melt(ys, id.var="id")
p2 <- ggplot(ys2, aes(x=id,y=value,group=variable)) +
  geom_line() + xlab("") + ylab("value") +
  ggtitle("10 white noise processes")
grid.arrange(p1, p2, ncol = 1)


## ----bj-ar1-plot---------------------------------------------------------
theta <- 0.8
nsim <- 10
ar1 <- arima.sim(TT, model=list(ar=theta))
plot(ar1)


## ----bj-ar1-ggplot-------------------------------------------------------
dat <- data.frame(t=1:TT, y=ar1)
p1 <- ggplot(dat, aes(x=t, y=y)) + geom_line() + 
  ggtitle("AR-1") + xlab("") + ylab("value")
ys <- matrix(0,TT,nsim)
for(i in 1:nsim) ys[,i] <- as.vector(arima.sim(TT, model=list(ar=theta)))
ys <- data.frame(ys)
ys$id <- 1:TT

ys2 <- melt(ys, id.var="id")
p2 <- ggplot(ys2, aes(x=id,y=value,group=variable)) +
  geom_line() + xlab("") + ylab("value") +
  ggtitle("The variance of an AR-1 process is steady")
grid.arrange(p1, p2, ncol = 1)


## ----bj-wn-w-linear-trend------------------------------------------------
intercept <- .5
trend <- 0.1
sd <- 0.5
TT <- 20
wn <- rnorm(TT, sd=sd) #white noise
wni <- wn+intercept #white noise witn interept
wnti <- wn + trend*(1:TT) + intercept


## ----bj-wnt-plot---------------------------------------------------------
op <- par(mfrow=c(1,3))
plot(wn, type="l")
plot(trend*1:TT)
plot(wnti, type="l")
par(op)


## ----bj-wnt-ggplot-------------------------------------------------------
dat <- data.frame(t=1:TT, wn=wn, wni=wni, wnti=wnti)
p1 <- ggplot(dat, aes(x=t, y=wn)) + geom_line() + ggtitle("White noise")
p2 <- ggplot(dat, aes(x=t, y=wni)) + geom_line() + ggtitle("with non-zero mean")
p3 <- ggplot(dat, aes(x=t, y=wnti)) + geom_line() + ggtitle("with linear trend")
grid.arrange(p1, p2, p3, ncol = 3)


## ----bj-ar1-trend-plot---------------------------------------------------
beta1 <- 0.8
ar1 <- arima.sim(TT, model=list(ar=beta1), sd=sd)
ar1i <- ar1 + intercept
ar1ti <- ar1 + trend*(1:TT) + intercept
dat <- data.frame(t=1:TT, ar1=ar1, ar1i=ar1i, ar1ti=ar1ti)
p4 <- ggplot(dat, aes(x=t, y=ar1)) + geom_line() + ggtitle("AR1")
p5 <- ggplot(dat, aes(x=t, y=ar1i)) + geom_line() + ggtitle("with non-zero mean")
p6 <- ggplot(dat, aes(x=t, y=ar1ti)) + geom_line() + ggtitle("with linear trend")

grid.arrange(p4, p5, p6, ncol = 3)


## ----bj-anchovy----------------------------------------------------------
anchovy <- subset(landings, Species=="Anchovy" & Year <= 1989)$log.metric.tons
anchovyts <- ts(anchovy, start=1964)


## ----bj-anchovy-plot-----------------------------------------------------
plot(anchovyts, ylab="log catch")


## ----bj-adf-wn-----------------------------------------------------------
TT <- 100
wn <- rnorm(TT) # white noise
tseries::adf.test(wn)


## ----bj-df-wn------------------------------------------------------------
tseries::adf.test(wn, k=0)


## ----bj-adf-wn-trend-----------------------------------------------------
intercept <- 1
wnt <- wn + 1:TT + intercept
tseries::adf.test(wnt)


## ----bj-adf-rw-----------------------------------------------------------
rw <- cumsum(rnorm(TT))
tseries::adf.test(rw)


## ----bj-df-rw------------------------------------------------------------
tseries::adf.test(rw, k=0)


## ----bj-df-anchovy-------------------------------------------------------
tseries::adf.test(anchovyts)


## ----bj-df-wn2-----------------------------------------------------------
wn <- rnorm(TT)
test <- urca::ur.df(wn, type="trend", lags=0)
summary(test)


## ----bj-kpss-wnt---------------------------------------------------------
tseries::kpss.test(wnt, null="Trend")


## ----bj-kpss-wnt-level---------------------------------------------------
tseries::kpss.test(wnt, null="Level")


## ----bj-kpss-anchovy-----------------------------------------------------
kpss.test(anchovyts, null="Trend")


## ----bj-adf-wn-diff------------------------------------------------------
adf.test(diff(rw))
kpss.test(diff(rw))


## ----bj-adf-anchovy-diff-------------------------------------------------
diff1dat <- diff(anchovyts)
adf.test(diff1dat)
kpss.test(diff1dat)


## ----bj-second-diff------------------------------------------------------
diff2dat <- diff(diff1dat)
adf.test(diff2dat)


## ----bj-urdf-test--------------------------------------------------------
k <- trunc((length(diff1dat)-1)^(1/3))
test <- urca::ur.df(diff1dat, type="drift", lags=k)
summary(test)


## ----bj-ndiff------------------------------------------------------------
forecast::ndiffs(anchovyts, test="kpss")
forecast::ndiffs(anchovyts, test="adf")


## ----bj-sim-ar2----------------------------------------------------------
m <- 1
ar2 <- arima.sim(n=1000, model=list(ar=c(.8,.1))) + m


## ----bj-Arima------------------------------------------------------------
forecast::Arima(ar2, order=c(2,0,0), include.constant=TRUE)


## ----bj-arima------------------------------------------------------------
arima(ar2, order=c(2,0,0), include.mean=TRUE)


## ----bj-arima-sim--------------------------------------------------------
ar1 <- arima.sim(n=100, model=list(ar=c(.8)))+m
forecast::Arima(ar1, order=c(1,0,0), include.constant=TRUE)


## ----bj-arima-sim-2------------------------------------------------------
arma12 = arima.sim(n=100, model=list(ar=c(0.8), ma=c(0.8, 0.2)))+m
forecast::Arima(arma12, order=c(1,0,2), include.constant=TRUE)


## ----bj-arima-sim-miss---------------------------------------------------
ar2miss <- arima.sim(n=100, model=list(ar=c(.8,.1)))
ar2miss[sample(100,50)] <- NA
plot(ar2miss, type="l")
title("many missing values")


## ----bj-Arima-2----------------------------------------------------------
fit <- forecast::Arima(ar2miss, order=c(2,0,0))
fit


## ----bj-plot-Arima-fit-miss----------------------------------------------
plot(ar2miss, type="l")
title("many missing values")
lines(fitted(fit), col="blue")


## ----bj-auto-arima-------------------------------------------------------
forecast::auto.arima(ar2)


## ----bj-auto-arima-miss--------------------------------------------------
forecast::auto.arima(ar2miss)


## ----bj-many-fits, cache=TRUE--------------------------------------------
save.fits <- rep(NA,100)
for(i in 1:100){
  a2 <- arima.sim(n=100, model=list(ar=c(.8,.1)))
  fit <- auto.arima(a2, seasonal=FALSE, max.d=0, max.q=0)
  save.fits[i] <- paste0(fit$arma[1], "-", fit$arma[2])
}
table(save.fits)


## ----bj-auto-arima-trace-------------------------------------------------
forecast::auto.arima(ar2, trace=TRUE)


## ----bj-auto-arima-trace-2-----------------------------------------------
forecast::auto.arima(ar2, trace=TRUE, stepwise=FALSE)


## ----bj-auto-arima-anchovy-----------------------------------------------
fit <- auto.arima(anchovyts)
fit


## ----bj-resid-diagnostics------------------------------------------------
res <- resid(fit)
Box.test(res, type="Ljung-Box", lag=12, fitdf=2)


## ----bj-checkresiduals---------------------------------------------------
forecast::checkresiduals(fit)


## ----bj-forecast-anchovy-------------------------------------------------
fr <- forecast::forecast(fit, h=10)
plot(fr)


## ----bj-ts-chinook-------------------------------------------------------
chinookts <- ts(chinook$log.metric.tons, start=c(1990,1), 
                frequency=12)


## ----bj-plot-chinook-----------------------------------------------------
plot(chinookts)


## ----bj-fit-chinook------------------------------------------------------
traindat <- window(chinookts, c(1990,10), c(1998,12))
testdat <- window(chinookts, c(1999,1), c(1999,12))
fit <- forecast::auto.arima(traindat)
fit


## ----bj-forecast-chinook-------------------------------------------------
fr <- forecast::forecast(fit, h=12)
plot(fr)
points(testdat)


## ----bj-read-data-problems-----------------------------------------------
data(greeklandings, package="atsalibrary")
landings <- greeklandings
data(chinook, package="atsalibrary")
chinook <- chinook.month


## ----get.another.species-------------------------------------------------
datdf <- subset(landings, Species=="Sardine")
dat <- ts(datdf$log.metric.tons, start=1964)
dat <- window(dat, start=1964, end=1987)


## ----results='hide'------------------------------------------------------
forecast::auto.arima(anchovy, trace=TRUE)


## ----read_data_prob2-----------------------------------------------------
datdf <- subset(landings, Species=="Anchovy")
dat <- ts(datdf$log.metric.tons, start=1964)
dat64.87 <- window(dat, start=1964, end=1987)


## ----ex_ts_plot_www, fig.cap = "Number of users connected to the internet"----
data(WWWusage)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(WWWusage, ylab = "", las = 1, col = "blue", lwd = 2)

## ----ex_ts_plot_lynx, fig.cap = "Number of lynx trapped in Canada from 1821-1934"----
data(lynx)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lynx, ylab = "", las = 1, col = "blue", lwd = 2)

## ----load-quantmod-------------------------------------------------------
if (!require("quantmod")) {
    install.packages("quantmod")
    library(quantmod)
}
start <- as.Date("2016-01-01")
end <- as.Date("2016-10-01")
getSymbols("MSFT", src = "yahoo", from = start, to = end)
plot(MSFT[, "MSFT.Close"], main = "MSFT")

## ----ex_ts_plot_joint_dist, echo=FALSE-----------------------------------
set.seed(123)
nn <- 50
tt <- 40
ww <- matrix(rnorm(nn*tt), tt, nn)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(X[t])), xlab = "Time",
        col = gray(0.5, 0.4))

## ----ex_ts_plot_joint_dist_2, echo=FALSE---------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(X[t])), xlab = "Time",
        col = gray(0.5, 0.4))
lines(ww[,1], col = "blue", lwd = 2)

## ----ex_WN---------------------------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(x[t])), xlab = "Time",
        col = gray(0.5, 0.4))

## ----ex_RW---------------------------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(apply(ww, 2, cumsum), type="l", lty="solid",  las = 1,
        ylab = expression(italic(x[t])), xlab = "Time",
        col = gray(0.5, 0.4))

## ----plot_airpass, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960"----
xx <- AirPassengers
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")

## ----plot_airpass_fltr1, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960"----
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")
## weights for moving avg
fltr <- c(1,1,1)/3
trend <- filter(xx, filter=fltr, method="convo", sides=2)
lines(trend, col = "blue", lwd = 2)
text(x = 1949, y = max(trend, na.rm = TRUE),
     labels = expression(paste(lambda, " = 1/3")),
     adj = c(0,0), col = "blue")

## ----plot_airpass_fltr2, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960"----
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")
## weights for moving avg
fltr2 <- rep(1,9)/9
trend2 <- filter(xx, filter=fltr2, method="convo", sides=2)
lines(trend, col = "blue", lwd = 2)
lines(trend2, col = "darkorange", lwd = 2)
text(x = 1949, y = max(trend, na.rm = TRUE),
     labels = expression(paste(lambda, " = 1/3")),
     adj = c(0,0), col = "blue")
text(x = 1949, y = max(trend, na.rm = TRUE)*0.9,
     labels = expression(paste(lambda, " = 1/9")),
     adj = c(0,0), col = "darkorange")

## ----plot_airpass_fltr3, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960"----
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")
## weights for moving avg
fltr3 <- rep(1,27)/27
trend3 <- filter(xx, filter=fltr3, method="convo", sides=2)
lines(trend, col = "blue", lwd = 2)
lines(trend2, col = "darkorange", lwd = 2)
lines(trend3, col = "darkred", lwd = 2)
text(x = 1949, y = max(trend, na.rm = TRUE),
     labels = expression(paste(lambda, " = 1/3")),
     adj = c(0,0), col = "blue")
text(x = 1949, y = max(trend, na.rm = TRUE)*0.9,
     labels = expression(paste(lambda, " = 1/9")),
     adj = c(0,0), col = "darkorange")
text(x = 1949, y = max(trend, na.rm = TRUE)*0.8,
     labels = expression(paste(lambda, " = 1/27")),
     adj = c(0,0), col = "darkred")

## ----plot_airpass_decomp_seas, echo=FALSE, fig.cap = ""------------------
seas <- trend2 - xx
  
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(seas, las = 1, ylab = "")
# text(x = 1949, y = max(trend, na.rm = TRUE)*0.9,
#      labels = expression(paste(lambda, " = 1/9")),
#      adj = c(0,0), col = "darkorange")

## ----mean_seasonal_effects-----------------------------------------------
seas_2 <- decompose(xx)$seasonal
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(seas_2, las = 1, ylab = "")

## ----errors--------------------------------------------------------------
ee <- decompose(xx)$random
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(ee, las = 1, ylab = "")

## ----plot_ln_airpass, fig.cap = "Log monthly airline passengers from 1949-1960"----
lx <- log(AirPassengers)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lx, las = 1, ylab = "")

## ----plot_lin_trend, echo=FALSE------------------------------------------
tt <- as.vector(time(xx))
cc <- coef(lm(lx ~ tt))
pp <- cc[1] + cc[2] * tt
  
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot(tt, lx, type="l", las = 1,
     xlab = "Time", ylab = "")
lines(tt, pp, col = "blue", lwd = 2)

## ----seas_ln_dat, echo=FALSE---------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lx-pp)

## ----mean_seas_effects, echo=FALSE---------------------------------------
## length of ts
ll <- length(lx)
## frequency (ie, 12)
ff <- frequency(lx)
## number of periods (years); %/% is integer division
periods <- ll %/% ff
## index of cumulative month
index <- seq(1,ll,by=ff) - 1
## get mean by month
mm <- numeric(ff)
for(i in 1:ff) {
  mm[i] <- mean(lx[index+i], na.rm=TRUE)
}
## subtract mean to make overall mean=0
mm <- mm - mean(mm)
seas_2 <- ts(rep(mm, periods+1)[seq(ll)],
               start=start(lx), 
               frequency=ff)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(seas_2, las = 1, ylab = "")

## ----ln_errors-----------------------------------------------------------
le <- lx - pp - seas_2
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(le, las = 1, ylab = "")


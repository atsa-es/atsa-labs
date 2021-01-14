## ----ts-setup, include=FALSE----------------------------------------------------
knitr::opts_knit$set(unnamed.chunk.label = "ts-")
knitr::opts_chunk$set(echo = TRUE, comment=NA, cache=TRUE, tidy.opts=list(width.cutoff=60), tidy=TRUE, fig.align='center', out.width='80%')


## ----ts-plot-www, fig.cap = "Number of users connected to the internet"---------
data(WWWusage, package="datasets")
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(WWWusage, ylab = "", las = 1, col = "blue", lwd = 2)


## ----ts-plot-lynx, fig.cap = "Number of lynx trapped in Canada from 1821-1934"----
data(lynx, package="datasets")
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lynx, ylab = "", las = 1, col = "blue", lwd = 2)


## ----ts-load-quantmod, message=FALSE, warning=FALSE, echo=FALSE, results='hide'----
if (!require("quantmod")) {
    install.packages("quantmod")
    library(quantmod)
}
start <- as.Date("2016-01-01")
end <- as.Date("2016-10-01")
getSymbols("MSFT", src = "yahoo", from = start, to = end)
plot(MSFT[, "MSFT.Close"], main = "MSFT")


## ----ts-plot-joint-dist, echo=FALSE, fig.cap="Distribution of realizations"-----
set.seed(123)
nn <- 50
tt <- 40
ww <- matrix(rnorm(nn*tt), tt, nn)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(X[t])), xlab = "Time",
        col = gray(0.5, 0.4))


## ----ts-plot-joint-dist-2, echo=FALSE, fig.cap="Blue line is our one realization."----
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(X[t])), xlab = "Time",
        col = gray(0.5, 0.4))
lines(ww[,1], col = "blue", lwd = 2)


## ----ts-ex-WN-------------------------------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(ww, type="l", lty="solid",  las = 1,
        ylab = expression(italic(x[t])), xlab = "Time",
        col = gray(0.5, 0.4))


## ----ts-ex-RW-------------------------------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
matplot(apply(ww, 2, cumsum), type="l", lty="solid",  las = 1,
        ylab = expression(italic(x[t])), xlab = "Time",
        col = gray(0.5, 0.4))


## ----ts-plot-airpass, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960"----
xx <- AirPassengers
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")


## ----ts-plot-airpass-fltr1, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960 with a low filter."----
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(xx, las = 1, ylab = "")
## weights for moving avg
fltr <- c(1,1,1)/3
trend <- filter(xx, filter=fltr, method="convo", sides=2)
lines(trend, col = "blue", lwd = 2)
text(x = 1949, y = max(trend, na.rm = TRUE),
     labels = expression(paste(lambda, " = 1/3")),
     adj = c(0,0), col = "blue")


## ----ts-plot-airpass-fltr2, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960 with a medium filter."----
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


## ----ts-plot-airpass-fltr3, echo=FALSE, fig.cap = "Monthly airline passengers from 1949-1960 with a high filter."----
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


## ----ts-plot-airpass-decomp-seas, echo=FALSE, fig.cap = ""----------------------
seas <- trend2 - xx
  
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(seas, las = 1, ylab = "")
# text(x = 1949, y = max(trend, na.rm = TRUE)*0.9,
#      labels = expression(paste(lambda, " = 1/9")),
#      adj = c(0,0), col = "darkorange")


## ----ts-mean-seasonal-effects, fig.cap="Mean seasonal effect."------------------
seas_2 <- decompose(xx)$seasonal
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(seas_2, las = 1, ylab = "")


## ----ts-errors, fig.cap="Errors."-----------------------------------------------
ee <- decompose(xx)$random
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(ee, las = 1, ylab = "")


## ----ts-plot-ln-airpass, fig.cap = "Log monthly airline passengers from 1949-1960"----
lx <- log(AirPassengers)
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lx, las = 1, ylab = "")


## ----ts-plot-lin-trend, echo=FALSE----------------------------------------------
tt <- as.vector(time(xx))
cc <- coef(lm(lx ~ tt))
pp <- cc[1] + cc[2] * tt
  
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot(tt, lx, type="l", las = 1,
     xlab = "Time", ylab = "")
lines(tt, pp, col = "blue", lwd = 2)


## ----seas_ln_dat, echo=FALSE----------------------------------------------------
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(lx-pp)


## ----mean_seas_effects, echo=FALSE----------------------------------------------
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


## ----ln_errors------------------------------------------------------------------
le <- lx - pp - seas_2
par(mai = c(0.9,0.9,0.1,0.1), omi = c(0,0,0,0))
plot.ts(le, las = 1, ylab = "")


## ----mssmiss-load-data---------------------------------------------
data(snotel, package="atsalibrary")


## ----mssmiss-loadpackages, message=FALSE---------------------------
library(MARSS)
library(forecast)
library(ggplot2)
library(ggmap)
library(broom)


## ----get-LL-aug, eval=FALSE----------------------------------------
## y.aug = rbind(data,covariates)
## fit.aug = MARSS(y.aug, model=model.aug)


## ----mssmiss-get-LL-aug-2, eval=FALSE------------------------------
## fit.cov = fit.aug
## fit.cov$marss$data[1:dim(data)[1],] = NA
## extra.LL = MARSSkf(fit.cov)$logLik


## ----mssmiss-setupsnoteldata---------------------------------------
y <- snotelmeta
# Just use a subset
y = y[which(y$Longitude < -121.4),]
y = y[which(y$Longitude > -122.5),]
y = y[which(y$Latitude < 47.5),]
y = y[which(y$Latitude > 46.5),]


## ----mssmiss-plotsnotel, echo=FALSE, warning=FALSE, message=FALSE, fig.cap='(ref:snotelsites)'----
ylims=c(min(snotelmeta$Latitude)-1,max(snotelmeta$Latitude)+1)
xlims=c(min(snotelmeta$Longitude)-1,max(snotelmeta$Longitude)+1)
base = ggmap::get_map(location=c(xlims[1],ylims[1],xlims[2],ylims[2]), zoom=7, maptype="terrain-background")
map1 = ggmap::ggmap(base)
map1 + geom_point(data=y, aes(x=Longitude, y=Latitude), color="blue", cex=2.5) + 
  labs(x="Latitude", y="Longitude", title="SnoTel sites") + 
  theme_bw()


## ----mssmiss-plotsnotelts, warning=FALSE, fig.cap='(ref:snotelsites-plot)'----
swe.feb <- snotel
swe.feb <- swe.feb[swe.feb$Station.Id %in% y$Station.Id & swe.feb$Month=="Feb",]
p <- ggplot(swe.feb, aes(x=Date, y=SWE)) + geom_line()
p + facet_wrap(~Station)


## ----mssmiss-snotel-acast------------------------------------------
dat.feb <- reshape2::acast(swe.feb, Station ~ Year, value.var="SWE")


## ----mssmiss-snotel-marss-model------------------------------------
ns <- length(unique(swe.feb$Station))
B <- "diagonal and equal"
Q <- "unconstrained"
R <- diag(0.01,ns)
U <- "zero"
A <- "unequal"
x0 <- "unequal"
mod.list.ar1 = list(B=B, Q=Q, R=R, U=U, x0=x0, A=A, tinitx=1)


## ----mssmiss-snotelfit, results="hide"-----------------------------
library(MARSS)
m <- apply(dat.feb, 1, mean, na.rm=TRUE)
fit.ar1 <- MARSS(dat.feb, model=mod.list.ar1, control=list(maxit=5000), 
                 inits=list(A=matrix(m,ns,1)))


## ----mssmiss-snotelplotfits-ar1, warning=FALSE, results='hide', fig.cap='(ref:mssmiss-snotelplotfits-ar1)'----
fit <- fit.ar1
d <- fitted(fit, interval="prediction", type="ytT")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .fitted)) +
  geom_point(aes(Year, y)) +
  geom_ribbon(aes(x=Year, ymin=.lwr, ymax=.upr), linetype=2, alpha=0.2, fill="blue") +
  facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")
p


## ----mssmiss-stateresids-ar1, warning=FALSE, results='hide', fig.cap='(ref:mssmiss-stateresids-ar1)'----
fit <- fit.ar1
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(MARSSresiduals(fit, type="tT")$state.residuals[,1:30], 1, acf,
      na.action=na.pass)


## ----mssmiss-modelresids-ar1, warning=FALSE, results='hide', fig.cap='(ref:mssmiss-modelresids-ar1)'----
fit <- fit.ar1
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(MARSSresiduals(fit, type="tt1")$model.residuals[,1:30], 1, acf,
      na.action=na.pass)


## ----mssmiss-snotel-marss-model-corr-------------------------------
ns <- length(unique(swe.feb$Station))
B <- "zero"
Q <- "unconstrained"
R <- diag(0.01,ns)
U <- "zero"
A <- "unequal"
x0 <- "zero"
mod.list.corr = list(B=B, Q=Q, R=R, U=U, x0=x0, A=A, tinitx=0)


## ----mssmiss-snotelfit-corr, results="hide"------------------------
m <- apply(dat.feb, 1, mean, na.rm=TRUE)
fit.corr <- MARSS(dat.feb, model=mod.list.corr, control=list(maxit=5000), 
                  inits=list(A=matrix(m,ns,1)))


## ----mssmiss-snotelplotfits-corr, warning=FALSE, results='hide', fig.cap='(ref:mssmiss-snotelplotfits-corr)'----
fit <- fit.corr
d <- fitted(fit, type="ytT", interval="prediction")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .fitted)) +
  geom_point(aes(Year, y)) +
  geom_ribbon(aes(x=Year, ymin=.lwr, ymax=.upr), linetype=2, alpha=0.2, fill="blue") +
  facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")
p


## ----mssmiss-stateresids-fit-corr-states, warning=FALSE, results='hide'----
fit <- fit.corr
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(MARSSresiduals(fit)$state.residuals, 1, acf, na.action=na.pass)
mtext("State Residuals ACF", outer=TRUE, side=3)


## ----mssmiss-stateresids-fit-corr-model, warning=FALSE, results='hide'----
fit <- fit.corr
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(MARSSresiduals(fit)$model.residuals, 1, acf, na.action=na.pass)
mtext("Model Residuals ACF", outer=TRUE, side=3)


## ----mssmiss-snotel-dfa--------------------------------------------
ns <- dim(dat.feb)[1]
B <- matrix(list(0),2,2)
B[1,1] <- "b1"; B[2,2] <- "b2"
Q <- diag(1,2)
R <- "diagonal and unequal"
U <- "zero"
x0 <- "zero"
Z <- matrix(list(0),ns,2)
Z[1:(ns*2)] <- c(paste0("z1",1:ns),paste0("z2",1:ns))
Z[1,2] <- 0
A <- "unequal"
mod.list.dfa = list(B=B, Z=Z, Q=Q, R=R, U=U, A=A, x0=x0)


## ----mssmiss-snotelfit-dfa, results="hide"-------------------------
library(MARSS)
m <- apply(dat.feb, 1, mean, na.rm=TRUE)
fit.dfa <- MARSS(dat.feb, model=mod.list.dfa, control=list(maxit=1000), 
                 inits=list(A=matrix(m,ns,1)))


## ----mssmiss-ifwewantedloadings-dfa, include=FALSE-----------------
# if you want factor loadings
fit <- fit.dfa
# get the inverse of the rotation matrix
Z.est = coef(fit, type="matrix")$Z
H.inv = 1
if(ncol(Z.est)>1) H.inv = varimax(coef(fit, type="matrix")$Z)$rotmat
# rotate factor loadings
Z.rot = Z.est %*% H.inv
# rotate trends
trends.rot = solve(H.inv) %*% fit$states
#plot the factor loadings
spp = rownames(dat.feb)
minZ = 0.00
m=dim(trends.rot)[1]
ylims = c(-1.1*max(abs(Z.rot)), 1.1*max(abs(Z.rot)))
par(mfrow=c(ceiling(m/2),2), mar=c(3,4,1.5,0.5), oma=c(0.4,1,1,1))
for(i in 1:m) {
plot(c(1:ns)[abs(Z.rot[,i])>minZ], as.vector(Z.rot[abs(Z.rot[,i])>minZ,i]),
type="h", lwd=2, xlab="", ylab="", xaxt="n", ylim=ylims, xlim=c(0,ns+1))
for(j in 1:ns) {
if(Z.rot[j,i] > minZ) {text(j, -0.05, spp[j], srt=90, adj=1, cex=0.9)}
if(Z.rot[j,i] < -minZ) {text(j, 0.05, spp[j], srt=90, adj=0, cex=0.9)}
abline(h=0, lwd=1, col="gray")
} # end j loop
mtext(paste("Factor loadings on trend",i,sep=" "),side=3,line=.5)
} # end i loop


## ----mssmiss-snotelplotstates-dfa, warning=FALSE, echo=FALSE-------
fit <- fit.dfa
d <- fitted(fit, type="ytT", interval="prediction")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .fitted)) +
  geom_point(aes(Year, y)) +
  geom_ribbon(aes(x=Year, ymin=.lwr, ymax=.upr), linetype=2, alpha=0.2, fill="blue") +
  facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")
p


## ----mssmiss-stateresit-fit-dfa, results='hide'--------------------
fit <- fit.dfa
par(mfrow=c(1,2),mar=c(2,2,1,1))
apply(MARSSresiduals(fit)$state.residuals[,1:30,drop=FALSE], 1, acf)


## ----mssmiss-modelresids-fit-dfa-model, results='hide'-------------
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(MARSSresiduals(fit)$model.residual, 1, function(x){acf(x, na.action=na.pass)})


## ----mssfitted-snotelplotstates-dfa, warning=FALSE, echo=FALSE-----
fit <- fit.dfa
d <- tsSmooth(fit, type="ytT", interval="confidence")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .estimate)) +
  geom_point(aes(Year, y)) +
  geom_ribbon(aes(x=Year, ymin=.conf.low, ymax=.conf.up), linetype=2, alpha=0.7) +
  facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")
p


## ----mssmiss-swe-all-months----------------------------------------
swe.yr <- snotel
swe.yr <- swe.yr[swe.yr$Station.Id %in% y$Station.Id,]
swe.yr$Station <- droplevels(swe.yr$Station)


## ----mssmiss-seasonal-swe-plot, echo=FALSE, warning=FALSE----------
y3 <- swe.yr[swe.yr$Year>2010,]
p <- ggplot(y3, aes(x=Date, y=SWE)) + geom_line()
p + facet_wrap(~Station) + 
  scale_x_date(breaks=as.Date(paste0(2011:2013,"-01-01")), labels=2011:2013)


## ----echo=FALSE----------------------------------------------------
fitb <- function(x){
  a <- ts(x, start=1981, frequency=12)
  fit1 <- Arima(a, order=c(1,0,2), seasonal=c(0,1,0))
  fit4 <- Arima(a, order=c(2,0,1), seasonal=c(0,1,0))
  fit2 <- Arima(a, order=c(2,0,0), seasonal=c(0,1,0))
  fit3 <- Arima(a, order=c(1,0,0), seasonal=c(0,1,0))
  b <- c(fit1$aicc, fit4$aicc, fit2$aicc, fit3$aicc)
  b - min(b)
}
a <- tapply(swe.yr$SWE, swe.yr$Station, fitb)
b <- a
dim(b) <- NULL; names(b) <- names(a)
ta <- reshape2::melt(b)
ta$model <- rep(c("(1,0,2)","(2,0,1)","(2,0,0)","(1,0,0)"),length(b))
ta2 <- reshape2::dcast(ta, L1 ~ model)
knitr::kable(ta2)


## ----mssmiss-snotel-monthly-dat------------------------------------
dat.yr <- snotel
dat.yr <- dat.yr[dat.yr$Station.Id %in% y$Station.Id,]
dat.yr$Station <- droplevels(dat.yr$Station)
dat.yr$Month <- factor(dat.yr$Month, level=month.abb)
dat.yr <- reshape2::acast(dat.yr, Station ~ Year+Month, value.var="SWE")


## ----mssmis-seasonal-fourier---------------------------------------
period <- 12
TT <- dim(dat.yr)[2]
cos.t <- cos(2 * pi * seq(TT) / period)
sin.t <- sin(2 * pi * seq(TT) / period)
c.seas <- rbind(cos.t,sin.t)


## ----mssmiss-month-dfa---------------------------------------------
ns <- dim(dat.yr)[1]
B <- "zero"
Q <- matrix(1)
R <- "unconstrained"
U <- "zero"
x0 <- "zero"
Z <- matrix(paste0("z",1:ns),ns,1)
A <- "unequal"
mod.list.dfa = list(B=B, Z=Z, Q=Q, R=R, U=U, A=A, x0=x0)
C <- matrix(c("c1","c2"),1,2)
c <- c.seas
mod.list.seas <- list(B=B, U=U, Q=Q, A=A, R=R, Z=Z, C=C, c=c, x0=x0, tinitx=0)


## ----mssmiss-seas-fit, results="hide"------------------------------
m <- apply(dat.yr, 1, mean, na.rm=TRUE)
fit.seas <- MARSS(dat.yr, model=mod.list.seas, control=list(maxit=500), inits=list(A=matrix(m,ns,1)))


## ----mssmiss-seas, warning=FALSE, echo=FALSE-----------------------
#this is the estimate using only the season
fit <- fit.seas
d <- tsSmooth(fit, type="ytT", interval="prediction")
d$Year <- swe.yr$Year
d$Date <- swe.yr$Date
d <- subset(d, Year<1990)
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Date, .estimate)) +
  geom_ribbon(aes(x=Date, ymin=.lwr, ymax=.upr), linetype=2, alpha=0.2, fill="blue") +
  facet_wrap(~Station) + xlab("") + ylab("SWE seasonal component")
p


## ----mssmiss-snotelplotstates-seas, warning=FALSE, echo=FALSE------
fit <- fit.seas
d <- tsSmooth(fit, type="ytT", interval="none")
d$Year <- swe.yr$Year
d$Date <- swe.yr$Date
d <- subset(d, Year<1990)
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Date, .estimate)) +
  geom_point(aes(Date, y)) +
  facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")
p


## ----uss-loadpackages, results='hide', message=FALSE, warning=FALSE------
library(stats)
library(MARSS)
library(forecast)
library(datasets)


## ----uss-bad.1-----------------------------------------------------------
class(1)


## ----uss-mod.list--------------------------------------------------------
mod.list <- list(
B=matrix(1), U=matrix(0), Q=matrix("q"),
Z=matrix(1), A=matrix(0), R=matrix("r"),
x0=matrix("mu"), tinitx=0 )


## ----uss-set-seed-invisible, echo=FALSE----------------------------------
set.seed(123)


## ----uss-ar1-w-error-----------------------------------------------------
q <- 0.1; r <- 0.1; n <- 100
y <- cumsum(rnorm(n,0,sqrt(q)))+rnorm(n,0,sqrt(r))


## ----uss-ar1-fit---------------------------------------------------------
fit <- MARSS(y, model=mod.list)


## ----uss-mod.list.1, results='hide'--------------------------------------
mod.list$Q <- matrix(0.1)
fit <- MARSS(y,model=mod.list)


## ----uss-data------------------------------------------------------------
library(datasets)
dat <- as.vector(Nile)


## ----uss-plotdata, echo=FALSE, fig=TRUE, fig.cap='(ref:uss-plotdata)'----
plot(Nile,ylab="Flow volume",xlab="Year")


## ----uss-mod.nile.0, eval=TRUE-------------------------------------------
mod.nile.0 <- list( 
B=matrix(1), U=matrix(0), Q=matrix(0),
Z=matrix(1), A=matrix(0), R=matrix("r"),
x0=matrix("mu"), tinitx=0 )


## ----uss-fit.data.0, eval=TRUE, results='hide'---------------------------
kem.0 <- MARSS(dat, model=mod.nile.0)


## ----uss-coef-mod0-------------------------------------------------------
c(coef(kem.0, type="vector"), LL=kem.0$logLik, AICc=kem.0$AICc)


## ----uss-mod.nile.1, eval=TRUE-------------------------------------------
mod.nile.1 <- list(
B=matrix(1), U=matrix("u"), Q=matrix(0),
Z=matrix(1), A=matrix(0), R=matrix("r"),
x0=matrix("mu"), tinitx=0 )


## ----uss-fit.data.1, eval=TRUE, results='hide'---------------------------
kem.1 <- MARSS(dat, model=mod.nile.1)


## ----uss-fit.data.1.coef, eval=TRUE--------------------------------------
c(coef(kem.1, type="vector"), LL=kem.1$logLik, AICc=kem.1$AICc)


## ----uss-mod.nile.2, eval=TRUE-------------------------------------------
mod.nile.2 = list(
B=matrix(1), U=matrix(0), Q=matrix("q"),
Z=matrix(1), A=matrix(0), R=matrix("r"),
x0=matrix("mu"), tinitx=0 )


## ----uss-mod.nile.not.used, eval=FALSE-----------------------------------
## A <- "zero"; U <- "zero"


## ----uss-fit.data.2, eval=TRUE, results='hide'---------------------------
kem.2 <- MARSS(dat, model=mod.nile.2)


## ----uss-fit.data.2.coef, eval=TRUE--------------------------------------
c(coef(kem.2, type="vector"), LL=kem.2$logLik, AICc=kem.2$AICc)


## ----uss-mod.nile.3, eval=TRUE-------------------------------------------
mod.nile.3 = list(
B=matrix(1), U=matrix("u"), Q=matrix("q"),
Z=matrix(1), A=matrix(0), R=matrix("r"),
x0=matrix("mu"), tinitx=0)

## ----uss-fit.data.3, eval=TRUE, results='hide'---------------------------
kem.3 <- MARSS(dat, model=mod.nile.3)


## ----uss-fit.data.3.coef, eval=TRUE--------------------------------------
c(coef(kem.3, type="vector"), LL=kem.3$logLik, AICc=kem.3$AICc)


## ----uss-fit.data.2.structTS, eval=TRUE----------------------------------
fit.sts <- StructTS(dat, type="level")
fit.sts


## ----uss-fit.data.2.comp, eval=FALSE-------------------------------------
## trees <- window(treering, start = 0)
## fitts <- StructTS(trees, type = "level")
## fitem <- MARSS(as.vector(trees),mod.nile.2)
## fitbf <- MARSS(as.vector(trees),mod.nile.2, method="BFGS")


## ----uss-fit.data.2.fitted.structTS, eval=TRUE---------------------------
t=10
fitted(fit.sts)[t]


## ----uss-fit-data-2-onestepahead, eval=TRUE, results='hide'--------------
kf=print(kem.2, what="kfs")
kf$xtt1[1,t]


## ----uss-plotfit, eval=TRUE, echo=FALSE, fig=TRUE, fig.width=5, fig.height=6, fig.cap='(ref:uss-plotfit)'----
library(Hmisc)
par(mfrow=c(4,1), mar=c(4,4,0.5,0.5), oma=c(1,1,1,1))
x=seq(tsp(Nile)[1],tsp(Nile)[2],tsp(Nile)[3])
#model 0
plot(Nile,ylab="Flow volume",xlab="",xaxp=c(1870,1970,10),bty="L")
minor.tick(nx=10,ny=0,tick.ratio=.3)
kem <- kem.0 #model 0 results
lines(x,kem$states[1,],col="red",lwd=2)
legend("topright", paste("model 0, AICc=",format(kem.0$AICc,digits=1)), bty="n")

#model 1
plot(Nile,ylab="Flow volume",xlab="",xaxp=c(1870,1970,10),bty="n")
minor.tick(nx=10,ny=0,tick.ratio=.3)
kem <- kem.1 #model 1 results
lines(x,kem$states[1,],col="red",lwd=2)
legend("topright", paste("model 1, AICc=",format(kem.1$AICc,digits=1)),bty="n")

#model 2
plot(Nile,ylab="Flow volume",xlab="",xaxp=c(1870,1970,10),bty="L")
minor.tick(nx=10,ny=0,tick.ratio=.3)
kem <- kem.2 #model 2 results
lines(x,kem$states[1,],col="red",lwd=2)
lines(1871:1970,kem$states[1,]-1.96*kem$states.se[1,],col="red",lty=2)
lines(1871:1970,kem$states[1,]+1.96*kem$states.se[1,],col="red",lty=2)
legend("topright", paste("model 2, AICc=",format(kem$AICc,digits=1)),bty="n")

#model 3
plot(Nile,ylab="Flow volume",xlab="",xaxp=c(1870,1970,10),bty="L")
minor.tick(nx=10,ny=0,tick.ratio=.3)
kem <- kem.3 #model 2 results
lines(x,kem$states[1,],col="red",lwd=2)
lines(1871:1970,kem$states[1,]-1.96*kem$states.se[1,],col="red",lty=2)
lines(1871:1970,kem$states[1,]+1.96*kem$states.se[1,],col="red",lty=2)
legend("topright", paste("model 3, AICc=",format(kem$AICc,digits=1)),bty="n")


## ----uss-nile-aics-------------------------------------------------------
nile.aic = c(kem.0$AICc, kem.1$AICc, kem.2$AICc, kem.3$AICc)


## ----uss-nile-delaic-----------------------------------------------------
delAIC <- nile.aic-min(nile.aic)
relLik <- exp(-0.5*delAIC)
aicweight <- relLik/sum(relLik)


## ----uss-aic-table-------------------------------------------------------
aic.table <- data.frame(
AICc=nile.aic, 
delAIC=delAIC, 
relLik=relLik, 
weight=aicweight)
rownames(aic.table) <- c("flat level","linear trend", "stoc level", "stoc level w drift")


## ----uss-aic-table-round-------------------------------------------------
round(aic.table, digits=3)


## ----uss-resids0, fig.show='hide'----------------------------------------
par(mfrow=c(1,2))
resids <- residuals(kem.0)
plot(resids$model.residuals[1,], 
   ylab="model residual", xlab="", main="flat level")
abline(h=0)
plot(resids$state.residuals[1,], 
   ylab="state residual", xlab="", main="flat level")
abline(h=0)


## ----uss-resids, echo=FALSE, fig=TRUE, fig.cap='(ref:uss-resids)'--------
par(mfrow=c(3,2))
resids <- residuals(kem.0)
plot(resids$model.residuals[1,], 
   ylab="model residual", xlab="", main="flat level")
abline(h=0)
plot(resids$state.residuals[1,], 
   ylab="state residual", xlab="", main="flat level")
abline(h=0)

resids <- residuals(kem.1)
plot(resids$model.residuals[1,], ylab="model residual", xlab="", main="linear trend")
abline(h=0)
plot(resids$state.residuals[1,], ylab="state residual", xlab="", main="linear trend", ylim=c(-1,1))
abline(h=0)

resids <- residuals(kem.2)
plot(resids$model.residuals[1,], ylab="model residual", xlab="", main="stoc level")
abline(h=0)
plot(resids$state.residuals[1,], ylab="state residual", xlab="", main="stoc level")
abline(h=0)


## ----uss-acf0, fig.show='hide'-------------------------------------------
par(mfrow=c(2,2))
resids <- residuals(kem.0)
acf(resids$model.residuals[1,], main="flat level v(t)")
resids <- residuals(kem.1)
acf(resids$model.residuals[1,], main="linear trend v(t)")
resids <- residuals(kem.2)
acf(resids$model.residuals[1,], main="stoc level v(t)")
acf(resids$state.residuals[1,], main="stoc level w(t)", na.action=na.pass)


## ----uss-acfs, echo=FALSE, fig=TRUE, fig.cap='(ref:uss-acfs)'------------
par(mfrow=c(2,2))
resids <- residuals(kem.0)
acf(resids$model.residuals[1,], main="flat level v(t)")
resids <- residuals(kem.1)
acf(resids$model.residuals[1,], main="linear trend v(t)")
resids <- residuals(kem.2)
acf(resids$model.residuals[1,], main="stoc level v(t)")
acf(resids$state.residuals[1,], main="stoc level w(t)", na.action=na.pass)


## ----uss-jags-data-------------------------------------------------------
library(datasets)
y <- as.vector(Nile)


## ----uss-loadpackages-jags, results='hide', message=FALSE, warning=FALSE----
library(R2jags)
library(rjags)
library(coda)


## ----uss-jags-model------------------------------------------------------
model.loc <- "ss_model.txt"
jagsscript <- cat("
   model {  
   # priors on parameters
   mu ~ dnorm(Y1, 1/(Y1*100)); # normal mean = 0, sd = 1/sqrt(0.01)
   tau.q ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.q <- 1/sqrt(tau.q); # sd is treated as derived parameter
   tau.r ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.r <- 1/sqrt(tau.r); # sd is treated as derived parameter
   u ~ dnorm(0, 0.01);
    
   # Because init X is specified at t=0
   X0 <- mu
   X[1] ~ dnorm(X0+u,tau.q);
   Y[1] ~ dnorm(X[1], tau.r);
 
   for(i in 2:TT) {
   predX[i] <- X[i-1]+u; 
   X[i] ~ dnorm(predX[i],tau.q); # Process variation
   Y[i] ~ dnorm(X[i], tau.r); # Observation variation
   }
   }                  
   ",file=model.loc)


## ----uss-jags-set--------------------------------------------------------
jags.data <- list("Y"=y, "TT"=length(y), Y1=y[1])
jags.params <- c("sd.q", "sd.r", "X", "mu", "u")


## ----uss-jags-fit, results='hide', message=FALSE, cache=TRUE-------------
mod_ss <- jags(jags.data, parameters.to.save=jags.params, 
     model.file=model.loc, n.chains = 3, 
     n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)


## ----uss-fig-posteriors, fig=TRUE, fig.cap='(ref:uss-fig-posteriors)', message=FALSE, cache=TRUE----
attach.jags(mod_ss)
par(mfrow=c(2,2))
hist(mu)
abline(v=coef(kem.3)$x0, col="red")
hist(u)
abline(v=coef(kem.3)$U, col="red")
hist(log(sd.q^2))
abline(v=log(coef(kem.3)$Q), col="red")
hist(log(sd.r^2))
abline(v=log(coef(kem.3)$R), col="red")
detach.jags()


## ----uss-jags-plot-states-fun, message=FALSE, warning=FALSE--------------
plotModelOutput <- function(jagsmodel, Y) {
  attach.jags(jagsmodel)
  x <- seq(1,length(Y))
  XPred <- cbind(apply(X,2,quantile,0.025), apply(X,2,mean), apply(X,2,quantile,0.975))
  ylims <- c(min(c(Y,XPred), na.rm=TRUE), max(c(Y,XPred), na.rm=TRUE))
  plot(Y, col="white",ylim=ylims, xlab="",ylab="State predictions")
  polygon(c(x,rev(x)), c(XPred[,1], rev(XPred[,3])), col="grey70",border=NA)
  lines(XPred[,2])
  points(Y)
}


## ----uss-fig-bayesian-states, echo=TRUE, fig=TRUE, fig.cap='(ref:uss-fig-bayesian-states)', cache=TRUE----
plotModelOutput(mod_ss, y)
lines(kem.3$states[1,], col="red")
lines(1.96*kem.3$states.se[1,]+kem.3$states[1,], col="red", lty=2)
lines(-1.96*kem.3$states.se[1,]+kem.3$states[1,], col="red", lty=2)
title("State estimate and data from\nJAGS (black) versus MARSS (red)")




## ----uss-stan-setup, message=FALSE---------------------------------------
library(datasets)
library(rstan)
y <- as.vector(Nile)


## ----uss-stan-ar-model---------------------------------------------------
scode <- "
data {
  int<lower=0> TT;
  int<lower=0> n_pos; // number of non-NA values
  int<lower=0> indx_pos[n_pos]; // index of the non-NA values
  vector[n_pos] y;
}
parameters {
  real x0;
  real u;
  vector[TT] pro_dev;
  real<lower=0> sd_q;
  real<lower=0> sd_r;
}
transformed parameters {
  vector[TT] x;
  x[1] = x0 + u + pro_dev[1];
  for(i in 2:TT) {
    x[i] = x[i-1] + u + pro_dev[i];
  }
}
model {
  x0 ~ normal(y[1],10);
  u ~ normal(0,2);
  sd_q ~ cauchy(0,5);
  sd_r ~ cauchy(0,5);
  pro_dev ~ normal(0, sd_q);
  for(i in 1:n_pos){
    y[i] ~ normal(x[indx_pos[i]], sd_r);
  }
}
generated quantities {
  vector[n_pos] log_lik;
  for (i in 1:n_pos) log_lik[i] = normal_lpdf(y[i] | x[indx_pos[i]], sd_r);
}
"


## ----uss-stan-fit-model, message=FALSE, warning=FALSE, results='hide', cache=TRUE----
# We pass in the non-NA ys as vector
ypos <- y[!is.na(y)]
n_pos <- sum(!is.na(y)) #number on non-NA ys
indx_pos <- which(!is.na(y)) #index on the non-NAs
mod <- rstan::stan(model_code = scode, 
  data = list("y"=ypos, "TT"=length(y), "n_pos"=n_pos, "indx_pos"=indx_pos), 
  pars = c("sd_q","x", "sd_r", "u", "x0"),
  chains = 3, iter = 1000, thin = 1)


## ----uss-stan-ar-level, fig.cap="Estimated level and 95 percent credible intervals.  Blue dots are the actual Nile River levels."----
pars <- rstan::extract(mod)
pred_mean <- apply(pars$x, 2, mean)
pred_lo <- apply(pars$x, 2, quantile, 0.025)
pred_hi <- apply(pars$x, 2, quantile, 0.975)
plot(pred_mean, type = "l", lwd = 3, 
     ylim = range(c(pred_mean, pred_lo, pred_hi)), ylab = "Nile River Level")
lines(pred_lo)
lines(pred_hi)
points(y, col="blue")


## ----uss-stan-ar-level-ggplot, fig.cap="Estimated level and 95 percent credible intervals"----
library(ggplot2)
nile <- data.frame(y=y, year=1871:1970)
h <- ggplot(nile, aes(year))
h + geom_ribbon(aes(ymin = pred_lo, ymax = pred_hi), fill = "grey70") +
  geom_line(aes(y = pred_mean), size=1) +
  geom_point(aes(y = y), color="blue") +
  labs(y = "Nile River level")


## ----uss-stan-hist-pars, fig.cap="Histogram of the parameter samples versus the estimate (red line) from maximum likelihood."----
par(mfrow = c(2, 2))
hist(pars$x0)
abline(v = coef(kem.3)$x0, col = "red")
hist(pars$u)
abline(v = coef(kem.3)$U, col = "red")
hist(log(pars$sd_q^2))
abline(v = log(coef(kem.3)$Q), col = "red")
hist(log(pars$sd_r^2))
abline(v = log(coef(kem.3)$R), col = "red")


## ----uss-hw1, results='hide'---------------------------------------------
library(MARSS)
dat=log(grouse[,2])


## ----uss-hw3data---------------------------------------------------------
dat <- cumsum(rnorm(100,0.1,1))


## ----uss-hw3data.diff----------------------------------------------------
diff.dat=diff(dat)


## ----uss-hw4, results='hide'---------------------------------------------
library(MARSS)
dat <- log(graywhales[,2])


## ----uss-hw-greywhales, eval=FALSE---------------------------------------
## residuals(fit)$state.residuals[1,]
## residuals(fit)$model.residuals[1,]


## ----uss-hw6, results='hide'---------------------------------------------
library(forecast)
dat <- log(airmiles)
n <- length(dat)
training.dat <- dat[1:(n-3)]
test.dat <- dat[(n-2):n]


## ----uss-hw-marylee------------------------------------------------------
turtlename <- "MaryLee"
dat <- loggerheadNoisy[which(loggerheadNoisy$turtle==turtlename),5:6]
dat <- t(dat) 


## ----uss-hw-movement-fit1, results='hide'--------------------------------
fit0 <- MARSS(dat)


## ----uss-hw-movement-model-compare, eval=FALSE---------------------------
## fit1 <- MARSS(dat, list(Q=...))


## ----uss-hw-movement-resids, eval=FALSE----------------------------------
## resids <- residuals(fit0)$state.residuals


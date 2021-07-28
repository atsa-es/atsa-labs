## ----seas-dlm-setup, include=FALSE-------------------------------------------------------------
knitr::opts_knit$set(unnamed.chunk.label = "seas-dlm-")
knitr::opts_chunk$set(echo = TRUE, comment=NA, cache=FALSE, tidy.opts=list(width.cutoff=60), tidy=TRUE, fig.align='center', out.width='80%', message=FALSE, warning=FALSE)


## ----------------------------------------------------------------------------------------------
set.seed(1234)
TT <- 100
q <- 0.1; r <- 0.1
beta1 <- 0.6
beta2 <- 0.4
cov1 <- sin(2*pi*(1:TT)/12)
cov2 <- cos(2*pi*(1:TT)/12)
xt <- cumsum(rnorm(TT,0,q))
yt <- xt + beta1*cov1 + beta2*cov2 + rnorm(TT,0,r)
plot(yt, type="l", xlab="t")


## ----echo=FALSE--------------------------------------------------------------------------------
plot(1:12,(beta1*cov1 + beta2*cov2)[1:12],xlab="month",ylab="monthly effect")
title("seasonal cycle")


## ----echo=FALSE--------------------------------------------------------------------------------
require(ggplot2)
df <- data.frame()
for(beta1 in c(4,0.1))
  for(beta2 in c(-4,0.2)){
    tmp <- data.frame(line = paste0("b1=", beta1, " b2=",beta2), beta1 = beta1, beta2 = beta2, 
    value = beta1*sin(2*pi*(1:12)/12)+beta2*cos(2*pi*(1:12)/12), month=1:12)
    df <- rbind(df, tmp)
  }
df$line <- as.factor(df$line)
ggplot(df, aes(x=month, y=value, color=line)) + geom_line()


## ----echo=FALSE--------------------------------------------------------------------------------
require(ggplot2)
df <- data.frame()
beta1s = seq(-1,1,2/99)
beta2s = seq(1,-1,-2/99)
for(t in c(1,25,50,100)){
  beta1 = beta1s[t]
  beta2 = beta2s[t]
  tmp <- data.frame(t=paste("t =",t), line = paste0("b1=", beta1, " b2=",beta2), beta1 = beta1, beta2 = beta2, 
    value = beta1*sin(2*pi*(1:12)/12)+beta2*cos(2*pi*(1:12)/12), month=1:12)
    df <- rbind(df, tmp)
}
df$t = as.factor(df$t)
ggplot(df, aes(x=month, y=value)) + 
  geom_line() + facet_wrap(~t) +
  ggtitle("Seasonal cycle at different times")


## ----echo=FALSE--------------------------------------------------------------------------------
set.seed(1234)
TT <- 100
q <- 0.1; r <- 0.1
beta1 <- seq(-1,1,2/99)
beta2 <- seq(1,-1,-2/99)
cov1 <- sin(2*pi*(1:TT)/12)
cov2 <- cos(2*pi*(1:TT)/12)
xt <- cumsum(rnorm(TT,0,q))
yt <- xt + beta1*cov1 + beta2*cov2 + rnorm(TT,0,r)
plot(yt, type="l", xlab="t")


## ----seas-dlm-Z1-------------------------------------------------------------------------------
Z <- array(1, dim=c(1,3,TT))
Z[1,2,] <- sin(2*pi*(1:TT)/12)
Z[1,3,] <- cos(2*pi*(1:TT)/12)


## ----seas-dlm-mod.list1------------------------------------------------------------------------
mod.list <- list(
  U = "zero",
  Q = "diagonal and unequal",
  Z = Z,
  A = "zero")


## ----------------------------------------------------------------------------------------------
require(MARSS)
fit <- MARSS(yt, model=mod.list, inits=list(x0=matrix(0,3,1)))


## ----echo=FALSE--------------------------------------------------------------------------------
plot(fit, plot.type="xtT")


## ----echo=FALSE--------------------------------------------------------------------------------
require(ggplot2)
df$type="true"
beta1s = fit$states[2,]
beta2s = fit$states[3,]
for(t in c(1,25,50,100)){
  beta1 = beta1s[t]
  beta2 = beta2s[t]
  tmp <- data.frame(t=paste("t =",t), line = paste0("b1=", beta1, " b2=",beta2), beta1 = beta1, beta2 = beta2, 
    value = beta1*sin(2*pi*(1:12)/12)+beta2*cos(2*pi*(1:12)/12), month=1:12, type="estimate")
    df <- rbind(df, tmp)
}
ggplot(df, aes(x=month, y=value, color=type)) + 
  geom_line() + facet_wrap(~t) +
  ggtitle("Seasonal cycle at different times")


## ----------------------------------------------------------------------------------------------
yt.miss <- yt
yt.miss[sample(100, 50)] <- NA
plot(yt, type="l")
points(yt.miss)


## ----------------------------------------------------------------------------------------------
require(MARSS)
fit.miss <- MARSS(yt.miss, model=mod.list, inits=list(x0=matrix(0,3,1)))


## ----echo=FALSE--------------------------------------------------------------------------------
plot(fit.miss, plot.type="xtT")


## ----echo=FALSE--------------------------------------------------------------------------------
require(ggplot2)
beta1s = fit.miss$states[2,]
beta2s = fit.miss$states[3,]
for(t in c(1,25,50,100)){
  beta1 = beta1s[t]
  beta2 = beta2s[t]
  tmp <- data.frame(t=paste("t =",t), line = paste0("b1=", beta1, " b2=",beta2), beta1 = beta1, beta2 = beta2, 
    value = beta1*sin(2*pi*(1:12)/12)+beta2*cos(2*pi*(1:12)/12), month=1:12, type="estimate yt.miss")
    df <- rbind(df, tmp)
}
ggplot(df, aes(x=month, y=value, color=type)) + 
  geom_line() + facet_wrap(~t) +
  ggtitle("Seasonal cycle at different times")


## ----echo=FALSE, message=FALSE-----------------------------------------------------------------
require(ggplot2)
df <- data.frame()
beta1 <- 0.6; beta2 <- 0.4
for(zt in c(0.1,1,2)){
    tmp <- data.frame(line = paste0("zt = ", zt), 
    value = zt*beta1*sin(2*pi*(1:12)/12)+zt*beta2*cos(2*pi*(1:12)/12), month=1:12)
    df <- rbind(df, tmp)
  }
df$line <- as.factor(df$line)
ggplot(df, aes(x=month, y=value, color=line)) + geom_line()


## ----------------------------------------------------------------------------------------------
set.seed(1234)
TT <- 100
q <- 0.1; r <- 0.1
beta1 <- 0.6; beta2 <- 0.4
zt <- 0.5*sin(2*pi*(1:TT)/TT) + 0.75
cov1 <- sin(2*pi*(1:TT)/12)
cov2 <- cos(2*pi*(1:TT)/12)
xt <- cumsum(rnorm(TT,0,q))
yt <- xt + zt*beta1*cov1 + zt*beta2*cov2 + rnorm(TT,0,r)
plot(yt, type="l", xlab="t")


## ----seas-dlm-Z2-------------------------------------------------------------------------------
Z <- array(list(1), dim=c(1,2,TT))
Z[1,2,] <- paste0(sin(2*pi*(1:TT)/12)," + ",cos(2*pi*(1:TT)/12),"*beta")


## ----seas-dlm-mod.list2------------------------------------------------------------------------
mod.list <- list(
  U = "zero",
  Q = "diagonal and unequal",
  Z = Z,
  A = "zero")


## ----results="hide"----------------------------------------------------------------------------
require(MARSS)
fit <- MARSS(yt, model=mod.list, inits=list(x0=matrix(0,2,1)))


## ----echo=FALSE--------------------------------------------------------------------------------
df <- data.frame(t=1:TT, value=zt*beta1, type="true", var="amplitude scaling")
df <- rbind(df, data.frame(t=1:TT, value=xt, type="true", var="xt"))
df <- rbind(df, data.frame(t=1:12, value=cov1[1:12]+(beta2/beta1)*cov2[1:12], type="true", var="season"))
df <- rbind(df, data.frame(t=1:TT, value=fit$states[2,], type="estimate", var="amplitude scaling"))
df <- rbind(df, data.frame(t=1:TT, value=fit$states[1,], type="estimate", var="xt"))
df <- rbind(df, data.frame(t=1:12, value=cov1[1:12]+coef(fit)$Z[1]*cov2[1:12], type="estimate", var="season"))
ggplot(df, aes(x=t, y=value, color=type)) + geom_line() + facet_wrap(~var, scales="free")


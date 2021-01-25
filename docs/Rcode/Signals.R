## ----setup, include=FALSE-----------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, cache=FALSE)


## -----------------------------------------------------------------------------------------------
library(ggplot2)
library(MARSS)
library(stringr)
set.seed(1234)


## ----read-in-data-------------------------------------------------------------------------------
TT <- 30
qa <- .1
signal <- arima.sim(TT+3, model=list(ar=.9, sd=sqrt(qa)))
signal <- filter(signal, rep(1/3,3), sides=1)[4:(TT+3)]
signal <- signal - mean(signal)
dfsignal <- data.frame(t=1:TT, val=signal, name="signal")
p1 <- ggplot(dfsignal, aes(x=t, y=val)) + geom_line() + ggtitle("The signal")
p1


## ----sub.dat------------------------------------------------------------------------------------
createdata <- function(n, TT, ar, sd){
dat <- matrix(NA, n, TT)
rownames(dat) <- paste0("S", 1:n)
err <- dat
rownames(err) <- paste0("E", 1:n)
df <- dfsignal
for(i in 1:n){
  err[i,] <- arima.sim(TT, model=list(ar=ar[i]), sd=sd[i])
  err[i,] <- err[i, ] - mean(err[i, ])
  dat[i,] <- signal + err[i,]
  tmp <-  data.frame(t=1:TT, val=dat[i,], name=paste0("dat",i))
  tmp2 <-  data.frame(t=1:TT, val=err[i,], name=paste0("err",i))
  df <- rbind(df, tmp, tmp2)
}
return(list(dat=dat, df=df))
}

n <- 3
ar <- c(.7, .4, .99)
sd <- sqrt(c(1, 28, 41))
tmp <- createdata(n, TT, ar, sd)
dat <- tmp$dat
df <- tmp$df


## -----------------------------------------------------------------------------------------------
p1 <- ggplot(subset(df, name!="signal"), 
             aes(x=t, y=val)) + geom_line() + facet_wrap(~name, ncol=2)
p1


## ----mod.list1----------------------------------------------------------------------------------
makemod <- function(n){
  B <- matrix(list(0), n+1, n+1)
diag(B)[2:(n+1)] <- paste0("b", 1:n)
B[1,1] <- 1
A <- "zero"
Z <- cbind(1,diag(1,n))
Q <- matrix(list(0),n+1,n+1)
Q[1,1] <- 1
diag(Q)[2:(n+1)] <- paste0("q",1:n)
R <- "zero"
U <- "zero"
x0 <- "zero"
mod.list <- list(B=B, A=A, Z=Z, Q=Q, R=R, U=U, x0=x0, tinitx=0)
return(mod.list)
}
mod.list1 <- makemod(3)


## ----fit.mod1-----------------------------------------------------------------------------------
dat2 <- dat - apply(dat,1,mean) %*% matrix(1,1,TT)


## -----------------------------------------------------------------------------------------------
fit.mod1 <- MARSS(dat2, model=mod.list1)


## -----------------------------------------------------------------------------------------------
require(ggplot2)
autoplot(fit.mod1, plot.type="states", conf.int=FALSE)


## ----echo=FALSE---------------------------------------------------------------------------------
t <- 1:TT
df <- data.frame(val=c(fit.mod1$states[1,],
                 signal,
                 apply(dat2,2,mean)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(t, 3))
rmse <- sqrt(mean((fit.mod1$states[1,] - signal)^2))

ggplot(subset(df, name!="mean data"),aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))


## ----echo=FALSE---------------------------------------------------------------------------------
ggplot(df, aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2)


## ----echo=FALSE---------------------------------------------------------------------------------
dat.miss <- dat
dat.miss[sample(n*TT,n*TT/3)] <- NA
dat2.miss <- dat.miss - apply(dat.miss,1,mean,na.rm=TRUE) %*% matrix(1,1,TT)
df <- data.frame(val=as.vector(t(dat.miss)),
                 name=rep(rownames(dat.miss),each=TT),
                 x=rep(t, 3))
ggplot(df, aes(y = val, x = x)) + 
  geom_line(size=1.2) + facet_wrap(~name)


## -----------------------------------------------------------------------------------------------
fit <- MARSS(dat2.miss, model=mod.list1, silent=TRUE)


## ----echo=FALSE---------------------------------------------------------------------------------
df <- data.frame(val=c(fit$states[1,],
                 signal,
                 apply(dat2.miss,2,mean, na.rm=TRUE)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(1:TT, 3))
rmse <- sqrt(mean((fit$states[1,] - signal)^2))

ggplot(subset(df, name!="mean data"),aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))


## ----echo=FALSE---------------------------------------------------------------------------------
ggplot(df,aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2)


## ----echo=FALSE---------------------------------------------------------------------------------
dat.miss <- dat
for(i in 1:n)
dat.miss[i, arima.sim(TT, model=list(ar=.8)) < -1] <- NA
dat2.miss <- dat.miss - apply(dat.miss,1,mean,na.rm=TRUE) %*% matrix(1,1,TT)
df <- data.frame(val=as.vector(t(dat.miss)),
                 name=rep(rownames(dat.miss),each=TT),
                 x=rep(t, 3))
ggplot(df, aes(y = val, x = x)) + 
  geom_line(size=1.2) + facet_wrap(~name)


## -----------------------------------------------------------------------------------------------
fit <- MARSS(dat2.miss, model=mod.list1, silent=TRUE)


## ----echo=FALSE---------------------------------------------------------------------------------
t <- 1:TT
df <- data.frame(val=c(fit$states[1,],
                 signal,
                 apply(dat2.miss,2,mean, na.rm=TRUE)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(t, 3))
rmse <- sqrt(mean((fit$states[1,] - signal)^2))

ggplot(subset(df, name!="mean data"),aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))



## -----------------------------------------------------------------------------------------------
Q <- matrix(list(0),n+1,n+1)
Q[1,1] <- 1
Q2 <- matrix("q",n,n)
diag(Q2) <- paste0("q", 1:n)
Q2[upper.tri(Q2)] <- paste0("c",1:n)
Q2[lower.tri(Q2)] <- paste0("c",1:n)
Q[2:(n+1),2:(n+1)] <- Q2
Q


## -----------------------------------------------------------------------------------------------
mod.list2 <- mod.list1
mod.list2$Q <- Q
fit <- MARSS(dat2, model=mod.list2)


## -----------------------------------------------------------------------------------------------
c(fit$AIC, fit.mod1$AIC)


## ----echo=FALSE---------------------------------------------------------------------------------
df <- data.frame(val=c(fit$states[1,],
                 signal,
                 apply(dat2,2,mean, na.rm=TRUE)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(t, 3))
rmse <- sqrt(mean((fit$states[1,] - signal)^2))

ggplot(subset(df, name!="mean data"),aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))


## -----------------------------------------------------------------------------------------------
sd <- sqrt(c(10, 28, 41))
dat[1,] <- signal + arima.sim(TT, model=list(ar=ar[1]), sd=sd[1])
dat2 <- dat - apply(dat,1,mean) %*% matrix(1,1,TT)

fit <- MARSS(dat2, model=mod.list1, silent=TRUE)


## ----echo=FALSE---------------------------------------------------------------------------------
df <- data.frame(val=c(fit$states[1,],
                 signal,
                 apply(dat2,2,mean)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(t, 3))
rmse <- sqrt(mean((fit$states[1,] - signal)^2))
ggplot(df ,aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))


## -----------------------------------------------------------------------------------------------
tmp1 <- createdata(n, TT, ar, sd)
tmp2 <- createdata(n, TT, ar, sd)
dat <- rbind(dat, tmp1$dat, tmp2$dat)
dat2 <- dat - apply(dat,1,mean) %*% matrix(1,1,TT)

fit <- MARSS(dat2, model=makemod(3*n), silent=TRUE)


## ----echo=FALSE---------------------------------------------------------------------------------
rmse <- sqrt(mean((fit$states[1,] - signal)^2))
df <- data.frame(val=c(fit$states[1,],
                 signal,
                 apply(dat2,2,mean)),
                 name=rep(c("estimate","true signal","mean data"),each=TT),
                 x=rep(t, 3))
ggplot(df ,aes(y = val, x = x, color = name)) + 
  geom_line(size=1.2) + ggtitle(paste0("RMSE = ", rmse))


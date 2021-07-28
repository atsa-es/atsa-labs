## ----cylcic-sockeye-setup, include=FALSE-------------------------------------------------------
knitr::opts_knit$set(unnamed.chunk.label = "cyclic-sockeye-")
knitr::opts_chunk$set(echo = TRUE, comment=NA, cache=TRUE,
                      tidy.opts=list(width.cutoff=60), tidy=TRUE,
                      fig.align='center', out.width='80%', message=FALSE,
                      warning=FALSE)


## ----message=FALSE-----------------------------------------------------------------------------
library(atsalibrary)
library(ggplot2)
library(MARSS)


## ----echo=FALSE, out.width="50%"---------------------------------------------------------------
knitr::include_graphics("images/BB_sockeye_rivers_inset.png")
# ![](images/BB_sockeye_rivers_inset.png)


## ----echo=FALSE--------------------------------------------------------------------------------
ggplot(sockeye, aes(x=brood_year, y=log(spawners))) + geom_line() + facet_wrap(~region, scales="free_y") + ggtitle("log spawners")


## ----echo=FALSE--------------------------------------------------------------------------------
a <- tapply(sockeye$spawners, sockeye$region, function(x){acf(x, na.action=na.pass, plot=FALSE, lag=10)$acf[,1,1]})
aa <- data.frame(acf=Reduce(c, a),
                    region=rep(names(a), each=11),
                    lag=rep(0:10, length(names(a))))
ggplot(aa, aes(x=lag, y=acf)) +
       geom_bar(stat = "identity", position = "identity") + geom_vline(xintercept=5)+
  facet_wrap(~region)+ggtitle("ACF")


## ----------------------------------------------------------------------------------------------
river <- "KVICHAK"
df <- subset(sockeye, region==river)
yt <- log(df$spawners)
TT <- length(yt)
p <- 5


## ----cylcic-sockeye-Z1-------------------------------------------------------------------------
Z <- array(1, dim=c(1,3,TT))
Z[1,2,] <- sin(2*pi*(1:TT)/p)
Z[1,3,] <- cos(2*pi*(1:TT)/p)


## ----cylcic-sockeye-mod-list1------------------------------------------------------------------
mod.list <- list(
  U = "zero",
  Q = "diagonal and unequal",
  Z = Z,
  A = "zero")


## ----cyclic-sockeye-fit-1, cache=TRUE----------------------------------------------------------
m <- dim(Z)[2]
fit <- MARSS(yt, model=mod.list, inits=list(x0=matrix(0,m,1)))


## ----echo=FALSE--------------------------------------------------------------------------------
plot(fit, plot.type="xtT")


## ----echo=FALSE--------------------------------------------------------------------------------
beta1s = fit$states[2,]
beta2s = fit$states[3,]
value = beta1s*sin(2*pi*(1:TT/p))+beta2s*cos(2*pi*(1:TT)/p)

plot(1:TT, value, type="l",xlab="", ylab="beta1*sin() + beta2*cos()")
abline(v=seq(0,TT,p), col="grey")
title(river)


## ----------------------------------------------------------------------------------------------
fitriver <- function(river, p=5){ 
df <- subset(sockeye, region==river)
yt <- log(df$spawners)
TT <- length(yt)
Z <- array(1, dim=c(1,3,TT))
Z[1,2,] <- sin(2*pi*(1:TT)/p)
Z[1,3,] <- cos(2*pi*(1:TT)/p)
mod.list <- list(
  U = "zero",
  Q = "diagonal and unequal",
  Z = Z,
  A = "zero")
fit <- MARSS(yt, model=mod.list, inits=list(x0=matrix(0,3,1)), silent=TRUE)
return(fit)
}


## ----cyclic-sockeye-list-of-fits, cache=TRUE---------------------------------------------------
fits <- list()
for(river in names(a)){
  fits[[river]] <- fitriver(river)
}


## ----------------------------------------------------------------------------------------------
dfz <- data.frame()
for(river in names(a)){
  fit <- fits[[river]]
  tmp <- data.frame(amplitude = sqrt(fit$states[2,]^2+fit$states[3,]^2),
                    trend = fit$states[1,],
                    river=river,
                    brood_year=subset(sockeye, region==river)$brood_year)
  dfz <- rbind(dfz, tmp)
}


## ----------------------------------------------------------------------------------------------
ggplot(dfz, aes(x=brood_year, y=amplitude)) + 
  geom_line() + 
  facet_wrap(~river, scales="free_y") + 
  ggtitle("Cycle Amplitude")


## ----------------------------------------------------------------------------------------------
ggplot(dfz, aes(x=brood_year, y=trend)) + 
  geom_line() + 
  facet_wrap(~river, scales="free_y") + 
  ggtitle("Stochastic Level")


## ----------------------------------------------------------------------------------------------
n <- 2


## ----------------------------------------------------------------------------------------------
Z <- array(1, dim=c(n,n*3,TT))
Z[1:n,1:n,] <- diag(1,n)
for(t in 1:TT){
Z[,(n+1):(2*n),t] <- diag(sin(2*pi*t/p),n)
Z[,(2*n+1):(3*n),t] <- diag(cos(2*pi*t/p),n)
}
Z[,,1]


## ----------------------------------------------------------------------------------------------
Q <- matrix(list(0), 3*n, 3*n)
Q[1:n,1:n] <- "c"
diag(Q) <- c(paste0("q",letters[1:n]), paste0("q",1:(2*n)))
Q


## ----------------------------------------------------------------------------------------------
fitriver.m <- function(river, p=5){ 
  require(tidyr)
  require(dplyr)
  require(MARSS)
df <- subset(sockeye, region %in% river)
df <- df %>% pivot_wider(id_cols=brood_year,names_from="region", values_from=spawners) %>%
  ungroup() %>% select(-brood_year)
yt <- t(log(df))
TT <- ncol(yt)
n <- nrow(yt)
Z <- array(1, dim=c(n,n*3,TT))
Z[1:n,1:n,] <- diag(1,n)
for(t in 1:TT){
Z[,(n+1):(2*n),t] <- diag(sin(2*pi*t/p),n)
Z[,(2*n+1):(3*n),t] <- diag(cos(2*pi*t/p),n)
}
Q <- matrix(list(0), 3*n, 3*n)
Q[1:n,1:n] <- paste0("c",1:(n^2))
diag(Q) <- c(paste0("q",letters[1:n]), paste0("q",1:(2*n)))
Q[lower.tri(Q)] <- t(Q)[lower.tri(Q)]
mod.list <- list(
  U = "zero",
  Q = Q,
  Z = Z,
  A = "zero")
fit <- MARSS(yt, model=mod.list, inits=list(x0=matrix(0,3*n,1)), silent=TRUE)
return(fit)
}


## ----cyclic-sockeye-more-rivers, cache=TRUE----------------------------------------------------
river <- unique(sockeye$region)
n <- length(river)
fit <- fitriver.m(river)


## ----cyclic-sockeye-corrplot-------------------------------------------------------------------
require(corrplot)
Qmat <- coef(fit, type="matrix")$Q[1:n,1:n]
rownames(Qmat) <- colnames(Qmat) <- river
M <- cov2cor(Qmat)
corrplot(M, order = "hclust", addrect = 4)


## ----echo=FALSE, out.width="50%"---------------------------------------------------------------
knitr::include_graphics("images/BB_sockeye_rivers_inset.png")
# ![](images/BB_sockeye_rivers_inset.png)


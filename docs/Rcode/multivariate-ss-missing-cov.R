## ----get-LL-aug, eval=FALSE----------------------------------------------
## y.aug = rbind(data,covariates)
## fit.aug = MARSS(y.aug, model=model.aug)

## ----mssmiss-get-LL-aug-2, eval=FALSE------------------------------------
## fit.cov = fit.aug
## fit.cov$marss$data[1:dim(data)[1],] = NA
## extra.LL = MARSSkf(fit.cov)$logLik

## ----mssmiss-loaddata, include=FALSE-------------------------------------
#If bookdown is being run, then we are at the top level
#If "gitbook" is not in the output
#then user is running Rmd in the folder for debugging
if("bookdown::gitbook" %in% rmarkdown::all_output_formats('index.Rmd')){ 
  #load the data
  a <- load("docs/data/snotel.RData")
}else{
  load("snotel.RData")
}

## ----mssmiss-loadsno, eval=FALSE-----------------------------------------
## load("snotel.RData")

## ----mssmiss-setupsnoteldata---------------------------------------------
y <- snotelmeta
# Just use a subset
y = y[which(y$Longitude < -121.4),]
y = y[which(y$Longitude > -122.5),]
y = y[which(y$Latitude < 47.5),]
y = y[which(y$Latitude > 46.5),]

## ----mssmiss-plotsnotel, echo=FALSE, warning=FALSE, message=FALSE--------
library(ggplot2)
library(ggmap)
ylims=c(min(snotelmeta$Latitude)-1,max(snotelmeta$Latitude)+1)
xlims=c(min(snotelmeta$Longitude)-1,max(snotelmeta$Longitude)+1)
base = get_map(location=c(xlims[1],ylims[1],xlims[2],ylims[2]), zoom=7, maptype="terrain-background")
map1 = ggmap(base)
map1 + geom_point(data=y, aes(x=Longitude, y=Latitude), color="blue", cex=2.5) + 
  labs(x="Latitude", y="Longitude", title="SnoTel sites") + 
  theme_bw()

## ----mssmiss-plotsnotelts, warning=FALSE---------------------------------
yy <- snotel
yy <- yy[yy$Station.Id %in% y$Station.Id & yy$Month=="Feb",]
p <- ggplot(yy, aes(x=Date, y=SWE)) + geom_line()
p + facet_wrap(~Station)

## ----mssmiss-snotel-acast------------------------------------------------
dat <- reshape2::acast(yy, Station ~ Year, value.var="SWE")

## ----mssmiss-snotel-marss-model------------------------------------------
ns <- length(unique(yy$Station))
B <- "diagonal and equal"
Q <- "unconstrained"
R <- diag(0.01,ns)
U <- "zero"
A <- "unequal"
x0 <- "zero"
mod.list = list(B=B, Q=Q, R=R, U=U, x0=x0, A=A)

## ----mssmiss-snotelfit, results="hide"-----------------------------------
library(MARSS)
m <- apply(dat, 1, mean, na.rm=TRUE)
fit <- MARSS(dat, model=mod.list, control=list(maxit=5000), inits=list(A=matrix(m,ns,1)))

## ------------------------------------------------------------------------
coef(fit)$B

## ----mssmiss-snotelplotstates, include=FALSE-----------------------------
library(broom)
library(ggplot2)
d <- tidy(fit, type="states")
d$Year <- d$t + 1980
d$Station <- stringr::str_replace(d$term,"X.","")
p <- ggplot(data = d) + 
  geom_line(aes(Year, estimate)) +
  geom_ribbon(aes(x=Year, ymin=conf.low, ymax=conf.high), linetype=2, alpha=0.5)
p <- p + geom_point(data=yy, mapping = aes(x=Year, y=SWE))
p + facet_wrap(~Station) + xlab("") + ylab("SWE")

## ----mssmiss-snotelplotfits, warning=FALSE, results='hide'---------------
library(broom)
library(ggplot2)
d <- augment(fit, interval="confidence")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .fitted)) +
  geom_ribbon(aes(x=Year, ymin=.conf.low, ymax=.conf.up), linetype=2, alpha=0.5)
p <- p + geom_point(data=yy, mapping = aes(x=Year, y=SWE))
p + facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")

## ----mssmiss-stateresids-plot-fit1, warning=FALSE, results='hide'--------
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(residuals(fit)$state.residuals[,1:30], 1, acf)

## ----mssmiss-snotel-marss-model2-----------------------------------------
ns <- length(unique(yy$Station))
B <- matrix(list(0),2,2)
B[1,1] <- "b1"; B[2,2] <- "b2"
Q <- diag(1,2)
R <- "diagonal and equal"
U <- "zero"
x0 <- "zero"
Z <- matrix(list(0),ns,2)
Z[1:(ns*2)] <- c(paste0("z1",1:ns),paste0("z2",1:ns))
Z[1,2] <- 0
A <- "unequal"
mod.list2 = list(B=B, Z=Z, Q=Q, R=R, U=U, A=A, x0=x0)

## ----mssmiss-snotelfit2, results="hide"----------------------------------
library(MARSS)
m <- apply(dat, 1, mean, na.rm=TRUE)
fit2 <- MARSS(dat, model=mod.list2, control=list(maxit=1000), inits=list(A=matrix(m,ns,1)))

## ----mssmiss-ifwewantedloadings, include=FALSE---------------------------
# get the inverse of the rotation matrix
Z.est = coef(fit2, type="matrix")$Z
H.inv = 1
if(ncol(Z.est)>1) H.inv = varimax(coef(fit2, type="matrix")$Z)$rotmat
# rotate factor loadings
Z.rot = Z.est %*% H.inv
# rotate trends
trends.rot = solve(H.inv) %*% fit2$states
#plot the factor loadings
spp = rownames(dat)
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

## ----mssmiss-snotelplotstates2, warning=FALSE, echo=FALSE----------------
library(broom)
library(ggplot2)
d <- augment(fit2, interval="confidence")
d$Year <- d$t + 1980
d$Station <- d$.rownames
p <- ggplot(data = d) + 
  geom_line(aes(Year, .fitted)) +
  geom_ribbon(aes(x=Year, ymin=.conf.low, ymax=.conf.up), linetype=2, alpha=0.5)
yy2 <- reshape2::melt(dat-apply(dat,1,mean,na.rm=TRUE))
colnames(yy2) <- c("Station","Year","SWE")
p <- p + geom_point(data=yy, mapping = aes(x=Year, y=SWE))
p + facet_wrap(~Station) + xlab("") + ylab("SWE (demeaned)")

## ----mssmiss-stateresit-fit2, results='hide'-----------------------------
par(mfrow=c(1,2),mar=c(2,2,1,1))
apply(residuals(fit2)$state.residuals[,1:30,drop=FALSE], 1, acf)

## ----mssmiss-modelresids-fit2, results='hide'----------------------------
par(mfrow=c(4,4),mar=c(2,2,1,1))
apply(residuals(fit2)$model.residual, 1, function(x){acf(na.omit(x))})

## ----mssmiss-seasonal-swe-plot, echo=FALSE, warning=FALSE----------------
y3 <- snotel
y3 <- y3[y3$Station.Id %in% y$Station.Id & y3$Year>2010,]
p <- ggplot(y3, aes(x=Date, y=SWE)) + geom_line()
p + facet_wrap(~Station) + 
  scale_x_date(breaks=as.Date(paste0(2011:2013,"-01-01")), labels=2011:2013)


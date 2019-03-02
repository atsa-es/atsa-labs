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
B <- matrix(list(0), ns, ns); diag(B)="b"
Q <- "unconstrained"
R <- diag(0.01,ns)
U <- "unequal"
x0 <- matrix(apply(dat,1,mean,na.rm=TRUE),ns,1)
mod.list = list(B=B, Q=Q,R=R, U=U, x0=x0)

## ----mssmiss-snotelfit, results="hide"-----------------------------------
library(MARSS)
fit <- MARSS(dat, model=mod.list, control=list(maxit=1000))

## ----mssmiss-snotelplotstates, warnings=FALSE----------------------------
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


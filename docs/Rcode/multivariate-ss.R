## ----mss-loadpackages, results='hide', message=FALSE, warning=FALSE------
library(MARSS)
library(R2jags)
library(coda)

## ----mss-noshowlegend, echo=FALSE, results='hide'------------------------
d=harborSealWA
legendnames = (unlist(dimnames(d)[2]))[2:ncol(d)]
for(i in 1:length(legendnames)) cat(paste(i,legendnames[i],"\n",sep=" "))

## ----mss-fig1, fig=TRUE, echo=FALSE, fig.width=5, fig.height=5, fig.cap='(ref:mss-fig1)'----
d=harborSealWA
dat = d[,2:ncol(d)] #first col is years
x = d[,1] #first col is years
n = ncol(dat) #num time series

#set up the graphical parameters to give each data a unique line, color and width
options(warn=-99)
ltys=matrix(1,nrow=n)
cols=matrix(1:4,nrow=n)
lwds=matrix(1:2,nrow=n)
pchs=matrix(as.character(c(1:n)),nrow=n)
options(warn=0)

matplot(x,dat,xlab="",ylab="log(counts)",type="b",pch=pchs,lty=ltys,col=cols,lwd=lwds,bty="L")
title("Puget Sound Harbor Seal Surveys")

## ----mss-Cs2-showdata----------------------------------------------------
print(harborSealWA[1:8,], digits=3)

## ----mss-Cs2-readindata--------------------------------------------------
years = harborSealWA[,"Year"]
dat= harborSealWA[,!(colnames(harborSealWA) %in% c("Year", "HC"))]
dat=t(dat) #transpose to have years across columns
colnames(dat) = years
n = nrow(dat)-1

## ----mss-fit.0.model-----------------------------------------------------
mod.list.0 = list(
B=matrix(1),
U=matrix("u"),
Q=matrix("q"),
Z=matrix(1,4,1),
A="scaling",
R="diagonal and unequal",
x0=matrix("mu"),
tinitx=0 )

## ----mss-fit.0.fit-------------------------------------------------------
fit.0 = MARSS(dat, model=mod.list.0)

## ----mss-model-resids, fig.show='hide'-----------------------------------
par(mfrow=c(2,2))
resids=residuals(fit.0)
for(i in 1:4){
plot(resids$model.residuals[i,],ylab="model residuals", xlab="")
abline(h=0)
title(rownames(dat)[i])
}

## ----mss-model-resids-plot, echo=FALSE, fig=TRUE, fig.cap='(ref:mss-model-resids-plot)'----
par(mfrow=c(2,2))
resids=residuals(fit.0)
for(i in 1:4){
plot(resids$model.residuals[i,],ylab="model residuals", xlab="")
abline(h=0)
title(rownames(dat)[i])
}

## ----mss-fit-1-model-----------------------------------------------------
mod.list.1 = list(
B="identity",
U="equal",
Q="diagonal and equal",
Z="identity",
A="scaling",
R="diagonal and unequal",
x0="unequal",
tinitx=0 )

## ----mss-fit.1.fit, results='hide'---------------------------------------
fit.1 = MARSS(dat, model=mod.list.1)

## ----mss-fit-2-model-----------------------------------------------------
mod.list.2 = mod.list.1
mod.list.2$Q = "equalvarcov"

## ----mss-fit-1-fit, results='hide'---------------------------------------
fit.2 = MARSS(dat, model=mod.list.2)

## ----mss-fits-aicc-------------------------------------------------------
c(fit.0$AICc, fit.1$AICc, fit.2$AICc)

## ----mss-model-resids-2, echo=FALSE, fig=TRUE, fig.cap='(ref:mss-model-resids-2)'----
par(mfrow=c(2,2))
resids=residuals(fit.2)
for(i in 1:4){
plot(resids$model.residuals[i,],ylab="model residuals", xlab="")
abline(h=0)
title(rownames(dat)[i])
}

## ----mss-fig2, fig.show='hide'-------------------------------------------
par(mfrow=c(2,2))
for(i in 1:4){
plot(years,fit.2$states[i,],ylab="log subpopulation estimate", xlab="", type="l")
lines(years,fit.2$states[i,]-1.96*fit.2$states.se[i,],type="l",lwd=1,lty=2,col="red")
lines(years,fit.2$states[i,]+1.96*fit.2$states.se[i,],type="l",lwd=1,lty=2,col="red")
title(rownames(dat)[i])
}

## ----mss-fig2-plot, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:mss-fig2-plot)'----
par(mfrow=c(2,2))
for(i in 1:4){
plot(years,fit.2$states[i,],ylab="log subpopulation estimate", xlab="", type="l")
lines(years,fit.2$states[i,]-1.96*fit.2$states.se[i,],type="l",lwd=1,lty=2,col="red")
lines(years,fit.2$states[i,]+1.96*fit.2$states.se[i,],type="l",lwd=1,lty=2,col="red")
title(rownames(dat)[i])
}

## ----mss-Cs01-setup-data-------------------------------------------------
years = harborSeal[,"Year"]
good = !(colnames(harborSeal)%in%c("Year","HoodCanal"))
sealData = t(harborSeal[,good])

## ----mss-Cs02-fig1, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:mss-Cs02-fig1)'----
par(mfrow=c(4,3),mar=c(2,2,2,2))
for(i in 2:dim(harborSeal)[2]) {
    plot(years, harborSeal[,i], xlab="", ylab="", main=colnames(harborSeal)[i])
}

## ----mss-Zmodel, tidy=FALSE----------------------------------------------
Z.model=matrix(0,11,3)
Z.model[c(1,2,9,10),1]=1  #which elements in col 1 are 1
Z.model[c(3:6,11),2]=1  #which elements in col 2 are 1
Z.model[7:8,3]=1  #which elements in col 3 are 1

## ----mss-Zmodel1---------------------------------------------------------
Z1=factor(c("pnw","pnw",rep("ps",4),"ca","ca","pnw","pnw","ps")) 

## ----mss-model-list, tidy=FALSE------------------------------------------
mod.list = list(
B = "identity",
U = "unequal",
Q = "equalvarcov",
Z = "placeholder",
A = "scaling",
R = "diagonal and equal",
x0 = "unequal",
tinitx = 0 )

## ----mss-set-up-Zs, tidy=FALSE-------------------------------------------
Z.models = list(
H1=factor(c("pnw","pnw",rep("ps",4),"ca","ca","pnw","pnw","ps")), 
H2=factor(c(rep("coast",2),rep("ps",4),rep("coast",4),"ps")), 
H3=factor(c(rep("N",6),"S","S","N","S","N")),
H4=factor(c("nc","nc","is","is","ps","ps","sc","sc","nc","sc","is")),
H5=factor(rep("pan",11)),
H6=factor(1:11) #site
)
names(Z.models)=
     c("stock","coast+PS","N+S","NC+strait+PS+SC","panmictic","site")

## ----mss-Cs05-run-models-------------------------------------------------
out.tab=NULL
fits=list()
for(i in 1:length(Z.models)){
     mod.list$Z = Z.models[[i]] 
     fit = MARSS(sealData, model=mod.list,
            silent=TRUE, control=list(maxit=1000))
     out=data.frame(H=names(Z.models)[i], 
            logLik=fit$logLik, AICc=fit$AICc, num.param=fit$num.params,
            m=length(unique(Z.models[[i]])),
            num.iter=fit$numIter, converged=!fit$convergence)
     out.tab=rbind(out.tab,out)
     fits=c(fits,list(fit))
}

## ----mss-Cs06-sort-results-----------------------------------------------
min.AICc=order(out.tab$AICc)
out.tab.1=out.tab[min.AICc,]

## ----mss-Cs07-add-delta-aicc---------------------------------------------
out.tab.1=cbind(out.tab.1,
           delta.AICc=out.tab.1$AICc-out.tab.1$AICc[1])

## ----mss-Cs08-add-delta-aicc---------------------------------------------
out.tab.1=cbind(out.tab.1, 
           rel.like=exp(-1*out.tab.1$delta.AICc/2))

## ----mss-Cs09-aic-weight-------------------------------------------------
out.tab.1=cbind(out.tab.1,
          AIC.weight = out.tab.1$rel.like/sum(out.tab.1$rel.like))

## ----mss-Cs10-print-table, echo=FALSE------------------------------------
out.tab.1$delta.AICc = round(out.tab.1$delta.AICc, digits=2)
out.tab.1$AIC.weight = round(out.tab.1$AIC.weight, digits=3)
print(out.tab.1[,c("H","delta.AICc","AIC.weight", "converged")], row.names=FALSE)

## ----mss-set-up-seal-data------------------------------------------------
sites = c("SJF","SJI","EBays","PSnd")
Y = harborSealWA[,sites]

## ----mss-jagsscript------------------------------------------------------
jagsscript = cat("
model {  
   U ~ dnorm(0, 0.01);
   tauQ~dgamma(0.001,0.001);
   Q <- 1/tauQ;

   # Estimate the initial state vector of population abundances
   for(i in 1:nSites) {
      X[1,i] ~ dnorm(3,0.01); # vague normal prior 
   }

   # Autoregressive process for remaining years
   for(i in 2:nYears) {
      for(j in 1:nSites) {
         predX[i,j] <- X[i-1,j] + U;
         X[i,j] ~ dnorm(predX[i,j], tauQ);
      }
   }

   # Observation model
   # The Rs are different in each site
   for(i in 1:nSites) {
     tauR[i]~dgamma(0.001,0.001);
     R[i] <- 1/tauR[i];
   }
   for(i in 1:nYears) {
     for(j in 1:nSites) {
       Y[i,j] ~ dnorm(X[i,j],tauR[j]);
     }
   }
}  

",file="marss-jags.txt")

## ----mss-marss-jags, results='hide', message=FALSE-----------------------
jags.data = list("Y"=Y,nSites=dim(Y)[2],nYears = dim(Y)[1]) # named list
jags.params=c("X","U","Q") 
model.loc="marss-jags.txt" # name of the txt file
mod_1 = jags(jags.data, parameters.to.save=jags.params, 
             model.file=model.loc, n.chains = 3, 
             n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  

## ----mss-plot-jags-states, fig.cap='(ref:NA)'----------------------------
#attach.jags attaches the jags.params to our workspace
attach.jags(mod_1)
means = apply(X,c(2,3),mean)
upperCI = apply(X,c(2,3),quantile,0.975)
lowerCI = apply(X,c(2,3),quantile,0.025)
par(mfrow =c(2,2))
nYears = dim(Y)[1]
for(i in 1:dim(means)[2]) {
  plot(means[,i],lwd=3,ylim=range(c(lowerCI[,i],upperCI[,i])),
       type="n",main=colnames(Y)[i],ylab="log abundance", xlab="time step")
  polygon(c(1:nYears,nYears:1,1),
          c(upperCI[,i],rev(lowerCI[,i]),upperCI[1,i]),col="skyblue",lty=0)
  lines(means[,i],lwd=3)
}

## ----mss-Reset, echo=FALSE-----------------------------------------------


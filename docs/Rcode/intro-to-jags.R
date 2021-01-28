## ----jags-loadpackages, results='hide', message=FALSE, warnings=FALSE----
library(coda)
library(rjags)
library(R2jags)


## ----jags-loaddata, echo=TRUE, results='hide', eval=TRUE----------
data(airquality, package="datasets")
Wind = airquality$Wind # wind speed
Temp = airquality$Temp # air temperature
N = dim(airquality)[1] # number of data points


## ----jags-lr1, results='hide', cache=TRUE-------------------------
# 1. LINEAR REGRESSION with no covariates
# no covariates, so intercept only. The parameters are 
# mean 'mu' and precision/variance parameter 'tau.obs'

model.loc="lm_intercept.txt" # name of the txt file
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # mean = 0, sd = 1/sqrt(0.01)
   tau.obs ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.obs <- 1/sqrt(tau.obs); # sd is treated as derived parameter

    for(i in 1:N) {
      Y[i] ~ dnorm(mu, tau.obs);
   }
}  
",file=model.loc)



## ----jags-call-fun1, results='hide', cache=TRUE-------------------
jags.data = list("Y"=Wind,"N"=N) # named list of inputs
jags.params=c("sd.obs","mu") # parameters to be monitored
mod_lm_intercept = jags(jags.data, parameters.to.save=jags.params, 
                model.file=model.loc, n.chains = 3, n.burnin=5000,
                n.thin=1, n.iter=10000, DIC=TRUE)  


## ----jags-lm1-mod-------------------------------------------------
mod_lm_intercept


## ----jags-lm1-attach----------------------------------------------
attach.jags(mod_lm_intercept)


## ----jags-plot-lm1, echo=TRUE, eval=TRUE, fig.show='hide'---------
# Now we can make plots of posterior values
par(mfrow = c(2,1))
hist(mu,40,col="grey",xlab="Mean",main="")
hist(sd.obs,40,col="grey",xlab=expression(sigma[obs]),main="")


## ----jags-plot-hist-post, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-plot-hist-post)'----
par(mfrow = c(2,1))
hist(mu,40,col="grey",xlab="Mean",main="")
hist(sd.obs,40,col="grey",xlab=expression(sigma[obs]),main="")


## ----jags-lm1-mcmclist-func, cache=TRUE---------------------------
createMcmcList = function(jagsmodel) {
McmcArray = as.array(jagsmodel$BUGSoutput$sims.array)
McmcList = vector("list",length=dim(McmcArray)[2])
for(i in 1:length(McmcList)) McmcList[[i]] = as.mcmc(McmcArray[,i,])
McmcList = mcmc.list(McmcList)
return(McmcList)
}


## ----jags-make-myList---------------------------------------------
myList = createMcmcList(mod_lm_intercept)
summary(myList[[1]])
plot(myList[[1]])


## ----jags-plot-myList,fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-plot-myList)'----
plot(myList[[1]])


## ----jags-coda, results='hide', eval=FALSE------------------------
## # Run the majority of the diagnostics that CODA() offers
## library(coda)
## gelmanDiags = gelman.diag(createMcmcList(mod_lm_intercept),multivariate=F)
## autocorDiags = autocorr.diag(createMcmcList(mod_lm_intercept))
## gewekeDiags = geweke.diag(createMcmcList(mod_lm_intercept))
## heidelDiags = heidel.diag(createMcmcList(mod_lm_intercept))


## ----jags-lm1ar, results='hide', cache=TRUE-----------------------
# 2. LINEAR REGRESSION WITH AUTOCORRELATED ERRORS
# no covariates, so intercept only. 

model.loc=("lmcor_intercept.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); 
   tau.obs ~ dgamma(0.001,0.001); 
   sd.obs <- 1/sqrt(tau.obs); 
   phi ~ dunif(-1,1);
   tau.cor <- tau.obs / (1-phi*phi); # Var = sigma2 * (1-rho^2)
   
   epsilon[1] <- Y[1] - mu;
   predY[1] <- mu; # initial value
   for(i in 2:N) {
      predY[i] <- mu + phi * epsilon[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.cor);
      epsilon[i] <- (Y[i] - mu) - phi*epsilon[i-1];
   }
}
",file=model.loc)



## ----jags-lm1ar-mod, results='hide', cache=TRUE-------------------
jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.obs","predY","mu","phi")
mod_lmcor_intercept = jags(jags.data, parameters.to.save=jags.params, 
        model.file=model.loc, n.chains = 3, n.burnin=5000,
        n.thin=1, n.iter=10000, DIC=TRUE)   


## ----jags-lm1ar-plot-func, results='hide'-------------------------
plotModelOutput = function(jagsmodel, Y) {
# attach the model
attach.jags(jagsmodel)
x = seq(1,length(Y))
summaryPredictions = cbind(apply(predY,2,quantile,0.025), apply(predY,2,mean), 
apply(predY,2,quantile,0.975))
plot(Y, col="white",ylim=c(min(c(Y,summaryPredictions)),max(c(Y,summaryPredictions))), 
xlab="",ylab="95% CIs of predictions and data",main=paste("JAGS results:", 
jagsmodel$model.file))
polygon(c(x,rev(x)), c(summaryPredictions[,1], rev(summaryPredictions[,3])), 
col="grey70",border=NA)
lines(summaryPredictions[,2])
points(Y)
}


## ----jags-lm1ar-plot, results='hide', eval=FALSE, fig.show='hide'----
## plotModelOutput(mod_lmcor_intercept, Wind)


## ----jags-lm1ar-plot1, fig=TRUE, echo=FALSE, fig.width=6, fig.height=6, fig.cap='(ref:jags-lm1ar-plot1)'----
plotModelOutput(mod_lmcor_intercept, Wind)


## ----jags-ar1, results='hide', cache=TRUE-------------------------
# 3. AR(1) MODEL WITH NO ESTIMATED AR COEFFICIENT = RANDOM WALK
# no covariates. The model is y[t] ~ Normal(y[n-1], sigma) for 
# we will call the precision tau.pro 
# Note too that we have to define predY[1]
model.loc=("rw_intercept.txt")
jagsscript = cat("
model {  
   mu ~ dnorm(0, 0.01); 
   tau.pro ~ dgamma(0.001,0.001); 
   sd.pro <- 1/sqrt(tau.pro);

   predY[1] <- mu; # initial value
   for(i in 2:N) {
      predY[i] <- Y[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.pro);
   }
}  
",file=model.loc)

jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.pro","predY","mu")
mod_rw_intercept = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, 
n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  



## ----jags-ar1est, echo=TRUE, results='hide', cache=TRUE-----------
# 4. AR(1) MODEL WITH AND ESTIMATED AR COEFFICIENT
# We're introducting a new AR coefficient 'phi', so the model is 
# y[t] ~ N(mu + phi*y[n-1], sigma^2) 

model.loc=("ar1_intercept.txt")
jagsscript = cat("
model {  
   mu ~ dnorm(0, 0.01); 
   tau.pro ~ dgamma(0.001,0.001); 
   sd.pro <- 1/sqrt(tau.pro); 
   phi ~ dnorm(0, 1); 
   
   predY[1] <- Y[1];
   for(i in 2:N) {
      predY[i] <- mu + phi * Y[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.pro);
   }
}  
",file=model.loc)

jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.pro","predY","mu","phi")
mod_ar1_intercept = jags(jags.data, parameters.to.save=jags.params, 
        model.file=model.loc, n.chains = 3, n.burnin=5000, n.thin=1, 
        n.iter=10000, DIC=TRUE)  



## ----jags-ss1, echo=TRUE, results='hide', cache=TRUE--------------
# 5. MAKE THE SS MODEL a univariate random walk
# no covariates. 

model.loc=("ss_model.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); 
   tau.pro ~ dgamma(0.001,0.001); 
   sd.q <- 1/sqrt(tau.pro);
   tau.obs ~ dgamma(0.001,0.001);
   sd.r <- 1/sqrt(tau.obs); 
   phi ~ dnorm(0,1);
   
   X[1] <- mu;
   predY[1] <- X[1];
   Y[1] ~ dnorm(X[1], tau.obs);

   for(i in 2:N) {
      predX[i] <- phi*X[i-1]; 
      X[i] ~ dnorm(predX[i],tau.pro); # Process variation
      predY[i] <- X[i];
      Y[i] ~ dnorm(X[i], tau.obs); # Observation variation
   }
}  
",file=model.loc)

jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.q","sd.r","predY","mu")
mod_ss = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, n.chains = 3, 
n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  



## ----jags-cov, results='hide', cache=TRUE-------------------------
# 6. Include some covariates in a linear regression
# Use temperature as a predictor of wind

model.loc=("lm.txt")
jagsscript = cat("
model {  
   mu ~ dnorm(0, 0.01); 
   beta ~ dnorm(0,0.01);
   tau.obs ~ dgamma(0.001,0.001); 
   sd.obs <- 1/sqrt(tau.obs); 
   
   for(i in 1:N) {
      predY[i] <- mu + C[i]*beta; 
      Y[i] ~ dnorm(predY[i], tau.obs);
   }
}  
",file=model.loc)

jags.data = list("Y"=Wind,"N"=N,"C"=Temp)
jags.params=c("sd.obs","predY","mu","beta")
mod_lm = jags(jags.data, parameters.to.save=jags.params, 
        model.file=model.loc, n.chains = 3, n.burnin=5000, 
        n.thin=1, n.iter=10000, DIC=TRUE)  



## ----jags-cov-forecast, results='hide', cache=TRUE----------------
jags.data = list("Y"=c(Wind,NA,NA,NA),"N"=(N+3))
jags.params=c("sd.q","sd.r","predY","mu")
model.loc=("ss_model.txt")
mod_ss_forecast = jags(jags.data, parameters.to.save=jags.params,
      model.file=model.loc, n.chains = 3, n.burnin=5000, n.thin=1,
      n.iter=10000, DIC=TRUE)


## ----jags-hwdata, echo=TRUE---------------------------------------
Spawners = c(2662,1806,1707,1339,1686,2220,3121,5028,9263,4567,1850,3353,2836,3961,4624,3262,3898,3039,5966,5931,7346,4911,3116,3185,5590,2485,2987,3829,4921,2348,1932,3151,2306,1686,4584,2635,2339,1454,3705,1510,1331,942,884,666,1521,409,2388,1043,3262,2606,4866,1161,3070,3320)
Recruits = c(12741,15618,23675,37710,62260,32725,8659,28101,17054,29885,33047,20059,35192,11006,48154,35829,46231,32405,20782,21340,58392,21553,27528,28246,35163,15419,16276,32946,11075,16909,22359,8022,16445,2912,17642,2929,7554,3047,3488,577,4511,1478,3283,1633,8536,7019,3947,2789,4606,3545,4421,1289,6416,3647)
logRS = log(Recruits/Spawners)


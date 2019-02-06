### R code from vignette source 'Intro to jags.Rnw'

###################################################
### code chunk number 1: RUNFIRST
###################################################
options(prompt=" ", continue=" ", width=60)


###################################################
### code chunk number 2: Intro to jags.Rnw:20-22
###################################################
require(coda)
require(R2jags)


###################################################
### code chunk number 3: Intro to jags.Rnw:29-33
###################################################
data(airquality, package="datasets")
Wind = airquality$Wind # wind speed
Temp = airquality$Temp # air temperature
N = dim(airquality)[1] # number of data points


###################################################
### code chunk number 4: Intro to jags.Rnw:49-74
###################################################
#################################################################################
# 1. START WITH AN EXAMPLE OF LINEAR REGRESSION
# no covariates, so intercept only. The parameters here are the mean 'mu' and 
# precision/variance parameter 'tau.obs'
#################################################################################
model.loc="lm_intercept.txt" # name of the txt file
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   tau.obs ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.obs <- 1/sqrt(tau.obs); # sd is treated as derived parameter

   # Jags is not vectorized, so we have to loop over observations
   for(i in 1:N) {
      # for each observation, we'll assume the data to be 
      # normally distributed around a common mean
      predY[i] <- mu; 
      Y[i] ~ dnorm(predY[i], tau.obs);
      # The above 2 lines are inefficient, and could also be written as
      # Y[i] ~ dnorm(mu, tau);
   }
}  

",file=model.loc)


###################################################
### code chunk number 5: Intro to jags.Rnw:78-79 (eval = FALSE)
###################################################
## ?jags 


###################################################
### code chunk number 6: Intro to jags.Rnw:84-85 (eval = FALSE)
###################################################
## ?jags.parallel


###################################################
### code chunk number 7: Intro to jags.Rnw:90-94
###################################################
jags.data = list("Y"=Wind,"N"=N) # named list of data
jags.params=c("sd.obs","mu") # parameters in the linear regression model
mod_lm_intercept = jags(jags.data, parameters.to.save=jags.params, 
model.file=model.loc, n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  


###################################################
### code chunk number 8: Intro to jags.Rnw:100-101
###################################################
mod_lm_intercept


###################################################
### code chunk number 9: Intro to jags.Rnw:106-107
###################################################
attach.jags(mod_lm_intercept)


###################################################
### code chunk number 10: Intro to jags.Rnw:112-116
###################################################
# Now we can make plots of posterior values
par(mfrow = c(2,1))
hist(mu,40,col="grey",xlab="Mean",main="")
hist(sd.obs,40,col="grey",xlab=expression(sigma[obs]),main="")


###################################################
### code chunk number 11: Intro to jags.Rnw:121-128
###################################################
createMcmcList = function(jagsmodel) {
McmcArray = as.array(jagsmodel$BUGSoutput$sims.array)
McmcList = vector("list",length=dim(McmcArray)[2])
for(i in 1:length(McmcList)) McmcList[[i]] = as.mcmc(McmcArray[,i,])
McmcList = mcmc.list(McmcList)
return(McmcList)
}


###################################################
### code chunk number 12: Intro to jags.Rnw:140-143
###################################################
myList = createMcmcList(mod_lm_intercept)
summary(myList[[1]])
plot(myList[[1]])


###################################################
### code chunk number 13: Intro to jags.Rnw:149-155 (eval = FALSE)
###################################################
## # Run the majority of the diagnostics that CODA() offers
## library(coda)
## gelmanDiags = gelman.diag(createMcmcList(mod_lm_intercept),multivariate=F)
## autocorDiags = autocorr.diag(createMcmcList(mod_lm_intercept))
## gewekeDiags = geweke.diag(createMcmcList(mod_lm_intercept))
## heidelDiags = heidel.diag(createMcmcList(mod_lm_intercept))


###################################################
### code chunk number 14: Intro to jags.Rnw:175-202
###################################################
#################################################################################
# 2. MODIFY THE ERRORS TO BE AUTOCORRELATED 
# no covariates, so intercept only. 
#################################################################################
model.loc=("lmcor_intercept.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   tau.obs ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.obs <- 1/sqrt(tau.obs); # sd is treated as derived parameter
   phi ~ dunif(-1,1);
   tau.cor <- tau.obs / (1-phi*phi); # Var = sigma2 * (1-rho^2)
   
   # Jags is not vectorized, so we have to loop over observations
   epsilon[1] <- Y[1] - mu;
   predY[1] <- mu; # initial value
   for(i in 2:N) {
      # for each observation, we'll assume the data to be normally 
      # distributed around a common mean
      predY[i] <- mu + phi * epsilon[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.cor);
      epsilon[i] <- (Y[i] - mu) - phi*epsilon[i-1];
   }
}  

",file=model.loc)


###################################################
### code chunk number 15: Intro to jags.Rnw:207-211
###################################################
jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.obs","predY","mu","phi")
mod_lmcor_intercept = jags(jags.data, parameters.to.save=jags.params, 
model.file=model.loc, n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)   


###################################################
### code chunk number 16: Intro to jags.Rnw:216-230
###################################################
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


###################################################
### code chunk number 17: Intro to jags.Rnw:234-235 (eval = FALSE)
###################################################
## plotModelOutput(mod_lmcor_intercept, Wind)


###################################################
### code chunk number 18: Cs02_fig1-plot
###################################################
plotModelOutput(mod_lmcor_intercept, Wind)


###################################################
### code chunk number 19: Intro to jags.Rnw:262-294
###################################################
#################################################################################
# 3. MAKE THE MODEL AN AR(1) MODEL WITH NO ESTIMATED AR COEFFICIENT = RANDOM WALK
# no covariates. The model is y[t] ~ Normal(y[n-1], sigma) for 
# clarity we'll call the prcsn tau.pro, because the error is process variation. 
# Note too that we have to define predY[1]
#################################################################################
model.loc=("rw_intercept.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   tau.pro ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.pro <- 1/sqrt(tau.pro); # sd is treated as derived parameter

   # Jags is not vectorized, so we have to loop over observations
   predY[1] <- mu; # initial value
   for(i in 2:N) {
      # for each observation, we'll assume the data to be normally 
      # distributed around a common mean
      predY[i] <- Y[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.pro);
      # The above 2 lines are inefficient, and could also be written 
      # as Y[i] ~ dnorm(mu + Y[i-1], tau);
   }
}  

",file=model.loc)

jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.pro","predY","mu")
mod_rw_intercept = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, 
n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  


###################################################
### code chunk number 20: Intro to jags.Rnw:315-350
###################################################
#################################################################################
# 4. MAKE THE MODEL AN AR(1) MODEL WITH AND ESTIMATED AR COEFFICIENT
# no covariates. We're introducting a new AR coefficient 'phi', rather than
# just modeling the process as a random walk, so the model is 
# y[t] ~ Normal(mu + phi*y[n-1], sigma) for clarity we'll call the prcsn
# tau.pro, because the error is process variation. Note too that we 
# have to define predY[1]
#################################################################################
model.loc=("ar1_intercept.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   tau.pro ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.pro <- 1/sqrt(tau.pro); # sd is treated as derived parameter
   phi ~ dnorm(0, 1); # this is the ar coefficient
   
   # Jags is not vectorized, so we have to loop over observations
   predY[1] <- Y[1];
   for(i in 2:N) {
      # for each observation, we'll assume the data to be normally distributed around
      # a common mean
      predY[i] <- mu + phi * Y[i-1]; 
      Y[i] ~ dnorm(predY[i], tau.pro);
      # The above 2 lines are inefficient, and could also be written as
      # Y[i] ~ dnorm(mu + phi * Y[i-1], tau);
   }
}  

",file=model.loc)

jags.data = list("Y"=Wind,"N"=N)
jags.params=c("sd.pro","predY","mu","phi")
mod_ar1_intercept = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, 
n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  


###################################################
### code chunk number 21: Intro to jags.Rnw:369-402
###################################################
######################################################################################
# 5. MAKE THE SS MODEL a univariate random walk
# no covariates. 
######################################################################################
model.loc=("ss_model.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   tau.pro ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.q <- 1/sqrt(tau.pro); # sd is treated as derived parameter
   tau.obs ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.r <- 1/sqrt(tau.obs); # sd is treated as derived parameter
   phi ~ dnorm(0,1);
   
   # Jags is not vectorized, so we have to loop over observations
   X[1] <- mu;
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


###################################################
### code chunk number 22: Intro to jags.Rnw:411-440
###################################################
######################################################################################
# 6. Let's go back to our original model and include some covariates
# We'll use temperature as a predictor of wind in the air quality dataset. 
######################################################################################
model.loc=("lm.txt")
jagsscript = cat("
model {  
   # priors on parameters
   mu ~ dnorm(0, 0.01); # This is normal with mean = 0, sd = 1/sqrt(0.01)
   beta ~ dnorm(0,0.01);
   tau.obs ~ dgamma(0.001,0.001); # This is inverse gamma
   sd.obs <- 1/sqrt(tau.obs); # sd is treated as derived parameter
   
   # Jags is not vectorized, so we have to loop over observations
   for(i in 1:N) {
      # for each observation, we'll assume the data to be normally distributed around
      # a common mean
      predY[i] <- mu + C[i]*beta; 
      Y[i] ~ dnorm(predY[i], tau.obs);
      # The above 2 lines are inefficient, and could also be written as Y[i] ~ dnorm(mu, tau);
   }
}  

",file=model.loc)

jags.data = list("Y"=Wind,"N"=N,"C"=Temp)
jags.params=c("sd.obs","predY","mu","beta")
mod_lm = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, 
n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  


###################################################
### code chunk number 23: Intro to jags.Rnw:448-454
###################################################
jags.data = list("Y"=c(Wind,NA,NA,NA),"N"=(N+3))
jags.params=c("sd.q","sd.r","predY","mu")
model.loc=("ss_model.txt")
mod_ss_forecast = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, 
n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)
attach.jags(mod_ss_forecast)


###################################################
### code chunk number 24: Intro to jags.Rnw:472-481
###################################################
Spawners = c(2662,1806,1707,1339,1686,2220,3121,5028,9263,4567,1850,3353,2836,3961,4624,
3262,3898,3039,5966,5931,7346,4911,3116,3185,5590,2485,2987,3829,4921,2348,1932,3151,2306,
1686,4584,2635,2339,1454,3705,1510,1331,942,884,666,1521,409,2388,1043,3262,2606,4866,
1161,3070,3320)
Recruits = c(12741,15618,23675,37710,62260,32725,8659,28101,17054,29885,33047,20059,35192,
11006,48154,35829,46231,32405,20782,21340,58392,21553,27528,28246,35163,15419,16276,32946,
11075,16909,22359,8022,16445,2912,17642,2929,7554,3047,3488,577,4511,1478,3283,1633,8536,
7019,3947,2789,4606,3545,4421,1289,6416,3647)
logRS = log(Recruits/Spawners)


###################################################
### code chunk number 25: reset
###################################################
options(prompt="> ", continue=" +", width=120)



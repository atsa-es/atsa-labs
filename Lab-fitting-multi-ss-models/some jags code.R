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

library(R2jags)
library(coda)
jags.data = list("Y"=Y,nSites=dim(Y)[2],nYears = dim(Y)[1]) # named list
jags.params=c("X","U","Q") 
model.loc="marss-jags.txt" # name of the txt file
mod_1 = jags(jags.data, parameters.to.save=jags.params, 
             model.file=model.loc, n.chains = 3, n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  

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

###########################################################

# Equalvarcov

tau ~ dgamma(0.01,0.01);
sigma2 <- 1/tau;
sigma <- sqrt(sigma2);
cor ~ dunif(-1,1);
sigma2.cor <- sigma2*cor;
sigma.cor <- sqrt(sigma2.cor);
Q[1,1] <- sigma2;
for(i in 2:nSites) { Q[1,i] <- sigma2.cor; }
for(i in 2:nSites) {
  for(j in 1:(i-1)) {	Q[i,j] <- sigma2.cor; }
  Q[i,i] <- sigma2;
  for(j in (i+1):nSites) {  Q[i,j] <- sigma2.cor; }
}
invQ[1:nSites,1:nSites] <- inverse(Q[1:nSites,1:nSites]);

# JAGS wants us to use the matrix inverse
tauQ[1:nSites,1:nSites] <- inverse(Q[1:nSites,1:nSites]);

# Estimate the initial state vector of population abundances
for(i in 1:nSites) {
  X[1,i] ~ dnorm(3,0.01); # vague normal prior 
}
# Autoregressive process for remaining years
for(i in 2:nYears) {
  for(j in 1:nSites) {
    predX[i,j] <- X[i-1,j] + U[j];
  }
  X[i,1:nSites] ~ dmnorm(predX[i,1:nSites],tauQ[1:nSites,1:nSites]);
}
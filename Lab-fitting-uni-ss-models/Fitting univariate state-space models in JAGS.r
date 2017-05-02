######################################################################################
# Fitting a univariate state-space model with MARSS and JAGS
# x[1] = mu
# x[t] = x[t-1] + u + w[t], w[t] ~ N(0, q)
# y[t] = x[t] + v[t], v[t] ~ N(0, r)
######################################################################################

# load the needed packages
require(coda)
require(R2jags)
require(MARSS)

# Our univariate data
y = log(graywhales[,2])
n = length(y)

# Fit with MARSS
# MARSS specification for a random walk with drift, observed with error
mod.list = list( 
  B=matrix(1), U=matrix("u"), Q=matrix("q"),
  Z=matrix(1), A=matrix(0), R=matrix("r"),
  x0=matrix("mu"), tinitx=1 )

fit.marss = MARSS(y, model=mod.list)

# Fit with JAGS
# jags model specification
jagsscript = cat("
	model {  
	# priors on parameters
	# Make sure mu prior is scaled to the data
	mu ~ dnorm(Y1, 1/(Y1*100)); 
	tau.q ~ dgamma(0.001,0.001); # This is inverse gamma
	sd.q <- 1/sqrt(tau.q); # sd is treated as derived parameter
	tau.r ~ dgamma(0.001,0.001); # This is inverse gamma
	sd.r <- 1/sqrt(tau.r); # sd is treated as derived parameter
	u ~ dnorm(0, 0.01);

	# If X[0] = mu instead of X[1]
	# X[1] ~ dnorm(mu+u, tau.q)
	X[1] <- mu;
	Y[1] ~ dnorm(X[1], tau.r);
	# Jags is not vectorized, so we have to loop over observations
	for(i in 2:N) {
	predX[i] <- X[i-1]+u; 
	X[i] ~ dnorm(predX[i],tau.q); # Process variation
	Y[i] ~ dnorm(X[i], tau.r); # Observation variation
		}
	}  

",file="ss_model.txt")

# The data (an any other input) we pass to jags
jags.data = list("Y"=y, "N"=n, Y1=y[1])
# The parameters that we are monitoring (must monitor at least 1)
jags.params=c("sd.q","sd.r","X","mu", "u")
model.loc=("ss_model.txt")
mod_ss = jags(jags.data, parameters.to.save=jags.params, model.file=model.loc, n.chains = 3, 
              n.burnin=5000, n.thin=1, n.iter=10000, DIC=TRUE)  

# Plot the posterior of mu, u, q and r with the MLE ests from MARSS on top
attach.jags(mod_ss)
par(mfrow=c(2,2))
#you need to know that mu is in the x0 val in MARSS
hist(mu)
abline(v=coef(fit.marss)$x0, col="red")
#you need to know that u is in the U val in MARSS
hist(u)
abline(v=coef(fit.marss)$U, col="red")
#you need to know that q is in the Q val in MARSS
#put on log scale
hist(log(sd.q^2))
abline(v=log(coef(fit.marss)$Q), col="red")
#you need to know that r is in the R val in MARSS
#put on log scale
hist(log(sd.r^2))
abline(v=log(coef(fit.marss)$R), col="red")
detach.jags()

# Plotting the estimated states
# We define a function to do this for us from the jags output
plotModelOutput = function(jagsmodel, Y) {
  # attach the model
  attach.jags(jagsmodel)
  x = seq(1,length(Y))
  summaryPredictions = cbind(apply(X,2,quantile,0.025), apply(X,2,mean), 
                             apply(X,2,quantile,0.975))
  ylims = c(min(c(Y,summaryPredictions), na.rm=TRUE),max(c(Y,summaryPredictions), na.rm=TRUE))
  plot(Y, col="white",ylim=ylims, 
       xlab="",ylab="95% CIs of predictions and data")
  polygon(c(x,rev(x)), c(summaryPredictions[,1], rev(summaryPredictions[,3])), 
          col="grey70",border=NA)
  lines(summaryPredictions[,2])
  points(Y)
  detach.jags()
}

par(mfrow=c(1,1))
plotModelOutput(mod_ss, y)
lines(fit.marss$states[1,], col="red")
lines(1.96*fit.marss$states.se[1,]+fit.marss$states[1,], col="red", lty=2)
lines(-1.96*fit.marss$states.se[1,]+fit.marss$states[1,], col="red", lty=2)
title("State estimate and data from\nJAGS (black) versus MARSS (red)")
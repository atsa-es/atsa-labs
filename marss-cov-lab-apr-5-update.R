# April 18 update

[done] Need to change cov to use Temp and TP at t-1. Does not make sense
to have temp at time t affect x(t) if we are modeling growth.

# April 5th update

The Temp and TP models are much worse than any seasonal model.

But seasonal models with not too much flexibility 
can be improved with covariates. As long as the seasonal model is not too complex.

Note, need to switch Key to use poly() not i,i^2 etc.

ord=3
c.m.poly=t(poly(rep(1:12,15),ord))
rownames(c.m.poly) <- paste0("Mon", 1:ord)
C = "unconstrained"; c=c.m.poly
model.list = c(common, list(C=C,c=c,D=D,d=d))
test2 = MARSS(dat, model=model.list, control=ctl, silent=TRUE)
test2$AIC

# This AICc is the same but the seasonal model changes.  The seasonal part is getting 'absorbed' into 
# into the polynomial part.
# C = "unconstrained"; c=rbind(c.m.poly,covars[1:2,])
# model.list = c(common, list(C=C,c=c,D=D,d=d))
# test2 = MARSS(dat, model=model.list, control=ctl, silent=TRUE)
# test2$AICc

Instead use anomalies. Temp & TP part not explained by the polynomials. 
This has lower AICc.

fit <- lm(covars[1,]~poly(rep(1:12,15),ord))
anoms = residuals(fit)
fit <- lm(covars[2,]~poly(rep(1:12,15),ord))
anoms = rbind(anoms,residuals(fit))
rownames(anoms) <- paste0(rownames(covars)[1:2], "_anom")
C = "unconstrained"; c=rbind(c.m.poly,anoms)
model.list = c(common, list(C=C,c=c,D=D,d=d))
test2 = MARSS(dat, model=model.list, control=ctl, silent=TRUE)
test2$AICc

Add this after, comparing the models with Temp and TP.  And after showing that Temp and TP only models
are not very good.


Another way to do orthogonal covariates.

X=t(covars[1:2,])
orthcov = -QR(X)$Q
orthcov = orthcov/sqrt(apply(orthcov,2,var))
c=t(orthcov)
model.list = list(B=B,U=U,Q=Q,Z=Z,A=A,R=R,C=D,c=d,D=C,d=c,tinitx=1)
cov.mod.5 = MARSS(dat,model=model.list,control=list(maxit=1500)) #1450.019
cov.mod.5$AICc

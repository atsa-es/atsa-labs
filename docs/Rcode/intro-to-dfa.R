## ----dfa-load-packages, results='hide', message=FALSE, warnings=FALSE----
library(MARSS)

## ----dfa-read_data-------------------------------------------------------
## load the data (there are 3 datasets contained here)
data(lakeWAplankton)
## we want lakeWAplanktonTrans, which has been transformed
## so the 0s are replaced with NAs and the data z-scored
all_dat <- lakeWAplanktonTrans
## use only the 10 years from 1980-1989
yr_frst <- 1980
yr_last <- 1989
plank_dat <- all_dat[all_dat[,"Year"]>=yr_frst & all_dat[,"Year"]<=yr_last,]
## create vector of phytoplankton group names
phytoplankton <- c("Cryptomonas", "Diatoms", "Greens",
                   "Unicells", "Other.algae")
## get only the phytoplankton
dat_1980 <- plank_dat[,phytoplankton]

## ----dfa-trans_data------------------------------------------------------
## transpose data so time goes across columns
dat_1980 <- t(dat_1980)
## get number of time series
N_ts <- dim(dat_1980)[1]
## get length of time series
TT <- dim(dat_1980)[2] 

## ----dfa-demean_data-----------------------------------------------------
y_bar <- apply(dat_1980, 1, mean, na.rm=TRUE)
dat <- dat_1980 - y_bar
rownames(dat) <- rownames(dat_1980)

## ----dfa-plot-phytos, fig.height=9, fig.width=8, fig.cap='Demeaned time series of Lake Washington phytoplankton.'----
spp <- rownames(dat_1980)
clr <- c("brown","blue","darkgreen","darkred","purple")
cnt <- 1
par(mfrow=c(N_ts,1), mai=c(0.5,0.7,0.1,0.1), omi=c(0,0,0,0))
for(i in spp){
  plot(dat[i,],xlab="",ylab="Abundance index", bty="L", xaxt="n", pch=16, col=clr[cnt], type="b")
  axis(1,12*(0:dim(dat_1980)[2])+1,yr_frst+0:dim(dat_1980)[2])
  title(i)
  cnt <- cnt + 1
  }

## ----dfa-dfa_obs_eqn-----------------------------------------------------
## 'ZZ' is loadings matrix
Z_vals <- list("z11",  0  ,  0  ,
               "z21","z22",  0  ,
               "z31","z32","z33",
               "z41","z42","z43",
               "z51","z52","z53")
ZZ <- matrix(Z_vals, nrow=N_ts, ncol=3, byrow=TRUE)
ZZ
## 'aa' is the offset/scaling
aa <- "zero"
## 'DD' and 'd' are for covariates
DD <- "zero"  # matrix(0,mm,1)
dd <- "zero"  # matrix(0,1,wk_last)
## 'RR' is var-cov matrix for obs errors
RR <- "diagonal and unequal"

## ----dfa-dfa_proc_eqn----------------------------------------------------
## number of processes
mm <- 3
## 'BB' is identity: 1's along the diagonal & 0's elsewhere
BB <- "identity"  # diag(mm)
## 'uu' is a column vector of 0's
uu <- "zero"  # matrix(0,mm,1)
## 'CC' and 'cc' are for covariates
CC <- "zero"  # matrix(0,mm,1)
cc <- "zero"  # matrix(0,1,wk_last)
## 'QQ' is identity
QQ <- "identity"  # diag(mm)

## ----dfa-create_model_lists----------------------------------------------
## list with specifications for model vectors/matrices
mod_list <- list(Z=ZZ, A=aa, D=DD, d=dd, R=RR,
                 B=BB, U=uu, C=CC, c=cc, Q=QQ)
## list with model inits
init_list <- list(x0 = matrix(rep(0, mm), mm, 1))
## list with model control parameters
con_list <- list(maxit = 3000, allow.degen = TRUE)

## ----dfa-fit_dfa_1, cache=TRUE-------------------------------------------
## fit MARSS
dfa_1 <- MARSS(y = dat, model = mod_list, inits = init_list, control = con_list)

## ----dfa-get_H_inv-------------------------------------------------------
## get the estimated ZZ
Z_est <- coef(dfa_1, type="matrix")$Z
## get the inverse of the rotation matrix
H_inv <- varimax(Z_est)$rotmat

## ----dfa-rotate_Z_x------------------------------------------------------
## rotate factor loadings
Z_rot = Z_est %*% H_inv   
## rotate processes
proc_rot = solve(H_inv) %*% dfa_1$states

## ----dfa-plot-dfa1, fig.height=9, fig.width=8, eval=TRUE, fig.cap='Estimated states from the DFA model.'----
ylbl <- phytoplankton
w_ts <- seq(dim(dat)[2])
layout(matrix(c(1,2,3,4,5,6),mm,2),widths=c(2,1))
## par(mfcol=c(mm,2), mai=c(0.5,0.5,0.5,0.1), omi=c(0,0,0,0))
par(mai=c(0.5,0.5,0.5,0.1), omi=c(0,0,0,0))
## plot the processes
for(i in 1:mm) {
  ylm <- c(-1,1)*max(abs(proc_rot[i,]))
  ## set up plot area
	plot(w_ts,proc_rot[i,], type="n", bty="L",
	     ylim=ylm, xlab="", ylab="", xaxt="n")
	## draw zero-line
	abline(h=0, col="gray")
	## plot trend line
	lines(w_ts,proc_rot[i,], lwd=2)
	lines(w_ts,proc_rot[i,], lwd=2)
	## add panel labels
	mtext(paste("State",i), side=3, line=0.5)
	axis(1,12*(0:dim(dat_1980)[2])+1,yr_frst+0:dim(dat_1980)[2])
}
## plot the loadings
minZ <- 0
ylm <- c(-1,1)*max(abs(Z_rot))
for(i in 1:mm) {
  plot(c(1:N_ts)[abs(Z_rot[,i])>minZ], as.vector(Z_rot[abs(Z_rot[,i])>minZ,i]), type="h",
       lwd=2, xlab="", ylab="", xaxt="n", ylim=ylm, xlim=c(0.5,N_ts+0.5), col=clr)
	for(j in 1:N_ts) {
	  if(Z_rot[j,i] > minZ) {text(j, -0.03, ylbl[j], srt=90, adj=1, cex=1.2, col=clr[j])}
	  if(Z_rot[j,i] < -minZ) {text(j, 0.03, ylbl[j], srt=90, adj=0, cex=1.2, col=clr[j])}
	  abline(h=0, lwd=1.5, col="gray")
	  } 
  mtext(paste("Factor loadings on state",i),side=3,line=0.5)
}

## ----dfa-xy-states12, height=4, width=5, fig.cap='Cross-correlation plot of the two rotations.'----
par(mai=c(0.9,0.9,0.1,0.1))
ccf(proc_rot[1,],proc_rot[2,], lag.max = 12, main="")

## ----dfa-defn_get_DFA_fits-----------------------------------------------
get_DFA_fits <- function(MLEobj,dd=NULL,alpha=0.05) {
  ## empty list for results
  fits <- list()
  ## extra stuff for var() calcs
  Ey <- MARSS:::MARSShatyt(MLEobj)
  ## model params
	ZZ <- coef(MLEobj, type="matrix")$Z
	## number of obs ts
	nn <- dim(Ey$ytT)[1]
	## number of time steps
	TT <- dim(Ey$ytT)[2]
	## get the inverse of the rotation matrix
	H_inv <- varimax(ZZ)$rotmat
	## check for covars
	if(!is.null(dd)) {
	  DD <- coef(MLEobj, type="matrix")$D
	  ## model expectation
	  fits$ex <- ZZ %*% H_inv %*% MLEobj$states + DD %*% dd
	} else {
	  ## model expectation
	  fits$ex <- ZZ %*% H_inv %*% MLEobj$states
	}
	## Var in model fits
	VtT <- MARSSkfss(MLEobj)$VtT
	VV <- NULL
	for(tt in 1:TT) {
	  RZVZ <- coef(MLEobj, type="matrix")$R - ZZ%*%VtT[,,tt]%*%t(ZZ)
	  SS <- Ey$yxtT[,,tt] - Ey$ytT[,tt,drop=FALSE] %*% t(MLEobj$states[,tt,drop=FALSE])
	  VV <- cbind(VV,diag(RZVZ + SS%*%t(ZZ) + ZZ%*%t(SS)))
	  }
 	SE <- sqrt(VV)
 	## upper & lower (1-alpha)% CI
 	fits$up <- qnorm(1-alpha/2)*SE + fits$ex
 	fits$lo <- qnorm(alpha/2)*SE + fits$ex
 	return(fits)
}

## ----dfa-plot-dfa-fits, fig.height=9, fig.width=8, fig.cap='Data and fits from the DFA model.'----
## get model fits & CI's
mod_fit <- get_DFA_fits(dfa_1)
## plot the fits
ylbl <- phytoplankton
par(mfrow=c(N_ts,1), mai=c(0.5,0.7,0.1,0.1), omi=c(0,0,0,0))
for(i in 1:N_ts) {
  up <- mod_fit$up[i,]
  mn <- mod_fit$ex[i,]
  lo <- mod_fit$lo[i,]
  plot(w_ts,mn,xlab="",ylab=ylbl[i],xaxt="n",type="n", cex.lab=1.2,
       ylim=c(min(lo),max(up)))
  axis(1,12*(0:dim(dat_1980)[2])+1,yr_frst+0:dim(dat_1980)[2])
  points(w_ts,dat[i,], pch=16, col=clr[i])
  lines(w_ts, up, col="darkgray")
  lines(w_ts, mn, col="black", lwd=2)
  lines(w_ts, lo, col="darkgray")
}

## ----dfa-get_covars------------------------------------------------------
temp <- t(plank_dat[,"Temp",drop=FALSE])
TP <- t(plank_dat[,"TP",drop=FALSE])

## ----dfa-fit_DFA_covars, cache=TRUE, results='hide'----------------------
mod_list=list(m=3, R="diagonal and unequal")
dfa_temp <- MARSS(dat, model = mod_list, form = "dfa", z.score = FALSE,
                  control = con_list, covariates=temp)
dfa_TP <- MARSS(dat, model = mod_list, form = "dfa", z.score = FALSE,
                control = con_list, covariates=TP)
dfa_both <- MARSS(dat, model = mod_list, form = "dfa", z.score = FALSE,
                  control = con_list, covariates=rbind(temp,TP))

## ----dfa_model_selection-------------------------------------------------
print(cbind(model=c("no covars", "Temp", "TP", "Temp & TP"),
      AICc=round(c(dfa_1$AICc, dfa_temp$AICc, dfa_TP$AICc, dfa_both$AICc))),
      quote=FALSE)

## ----dfa-fit_dfa_dummy, cache=TRUE---------------------------------------
cos_t <- cos(2 * pi * seq(TT) / 12)
sin_t <- sin(2 * pi * seq(TT) / 12)
dd <- rbind(cos_t,sin_t)
dfa_seas <- MARSS(dat_1980, model = mod_list, form = "dfa", z.score=TRUE,
                  control = con_list, covariates=dd)
dfa_seas$AICc

## ----dfa-plot_dfa_temp_fits, fig.height=9, fig.width=8, fig.cap='Data and model fits for the DFA with covariates.'----
## get model fits & CI's
mod_fit <- get_DFA_fits(dfa_seas,dd=dd)
## plot the fits
ylbl <- phytoplankton
par(mfrow=c(N_ts,1), mai=c(0.5,0.7,0.1,0.1), omi=c(0,0,0,0))
for(i in 1:N_ts) {
  up <- mod_fit$up[i,]
  mn <- mod_fit$ex[i,]
  lo <- mod_fit$lo[i,]
  plot(w_ts,mn,xlab="",ylab=ylbl[i],xaxt="n",type="n", cex.lab=1.2,
       ylim=c(min(lo),max(up)))
  axis(1,12*(0:dim(dat_1980)[2])+1,yr_frst+0:dim(dat_1980)[2])
  points(w_ts,dat[i,], pch=16, col=clr[i])
  lines(w_ts, up, col="darkgray")
  lines(w_ts, mn, col="black", lwd=2)
  lines(w_ts, lo, col="darkgray")
}


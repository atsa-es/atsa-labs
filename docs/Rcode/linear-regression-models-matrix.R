## ----mlr-loadpackages, results='hide', warning=FALSE, message=FALSE------
library(stats)
library(MARSS)
library(datasets)

## ----mlr-stackloss.data--------------------------------------------------
data(stackloss, package="datasets")
dat = stackloss[1:4,] #subsetted first 4 rows
dat

## ----mlr-stackloss1, results='hide'--------------------------------------
#the dat data.frame is defined on the first page of the chapter
lm(stack.loss ~ Air.Flow, data=dat)

## ----mlr-model.matrix----------------------------------------------------
fit=lm(stack.loss ~ Air.Flow, data=dat)
Z=model.matrix(fit)
Z[1:4,]

## ----mlr-stackloss2------------------------------------------------------
y=matrix(dat$stack.loss, ncol=1)
Z=cbind(1,dat$Air.Flow) #or use model.matrix() to get Z
solve(t(Z)%*%Z)%*%t(Z)%*%y
coef(lm(stack.loss ~ Air.Flow, data=dat))

## ----mlr-form1_mult_exp_var----------------------------------------------
fit1.mult=lm(stack.loss ~ Air.Flow + Water.Temp + Acid.Conc., data=dat)

## ----mlr-model.matrix.mult.exp.var---------------------------------------
Z=model.matrix(fit1.mult)
Z

## ----mlr-stackloss3------------------------------------------------------
y=matrix(dat$stack.loss, ncol=1)
Z=cbind(1,dat$Air.Flow, dat$Water.Temp, dat$Acid.Conc)
#or Z=model.matrix(fit2)
solve(t(Z)%*%Z)%*%t(Z)%*%y
coef(fit1.mult)

## ----mlr-stack.loss.form1b.comp------------------------------------------
y=matrix(dat$stack.loss, nrow=1)
d=rbind(1, dat$Air.Flow, dat$Water.Temp, dat$Acid.Conc)
y%*%t(d)%*%solve(d%*%t(d))
coef(fit1.mult)

## ----mlr-vec-------------------------------------------------------------
A=matrix(1:6,nrow=2,byrow=TRUE)
vecA = matrix(A,ncol=1)

## ----mlr-stackloss.form2.solve, tidy=FALSE-------------------------------
#make your y and x matrices
y=matrix(dat$stack.loss, ncol=1)
x=matrix(c(1,dat$Air.Flow),ncol=1)
#make the Z matrix
n=nrow(dat) #number of rows in our data file
k=1
#Z has n rows and 1 col for intercept, and n cols for the n air data points
#a list matrix allows us to combine "characters" and numbers
Z=matrix(list(0),n,k*n+1) 
Z[,1]="alpha"
diag(Z[1:n,1+1:n])="beta" 
#this function creates that permutation matrix for you
P=MARSS:::convert.model.mat(Z)$free[,,1]
M=kronecker(t(x),diag(n))%*%P
solve(t(M)%*%M)%*%t(M)%*%y
coef(lm(dat$stack.loss ~ dat$Air.Flow))

## ----mlr-newstackloss----------------------------------------------------
dat = cbind(dat, reg=rep(c("n","s"),n)[1:n])
dat

## ----mlr-newstackloss.lm-------------------------------------------------
fit2 = lm(stack.loss ~ -1 + Air.Flow + reg, data=dat)
coef(fit2)

## ----mlr-newstackloss-lm-model-matrix------------------------------------
Z=model.matrix(fit2)
Z[1:4,]

## ----mlr-stackloss-form1-Z-----------------------------------------------
Z=cbind(dat$Air.Flow,c(1,0,1,0),c(0,1,0,1))
colnames(Z)=c("beta","regn","regs")

## ----mlr-stackloss.form1.Z.lm--------------------------------------------
Z=model.matrix(fit2)
Z[1:4,]

## ----mlr-stackloss.form1.ns.solve----------------------------------------
y=matrix(dat$stack.loss, ncol=1)
solve(t(Z)%*%Z)%*%t(Z)%*%y

## ----mlr-stackloss.form1.lm.coef-----------------------------------------
coef(fit2)

## ----mlr-stackloss.form2.ns----------------------------------------------
y=matrix(dat$stack.loss, ncol=1)
x=matrix(c(1,dat$Air.Flow),ncol=1)
n=nrow(dat)
k=1
#list matrix allows us to combine numbers and character strings
Z=matrix(list(0),n,k*n+1)
Z[seq(1,n,2),1]="alphanorth"
Z[seq(2,n,2),1]="alphasouth"
diag(Z[1:n,1+1:n])="beta"
P=MARSS:::convert.model.mat(Z)$free[,,1]
M=kronecker(t(x),diag(n))%*%P
solve(t(M)%*%M)%*%t(M)%*%y

## ----mlr-newstackloss3---------------------------------------------------
dat = cbind(dat, owner=c("s","a"))
dat

## ----mlr-newstackloss.lm3------------------------------------------------
coef(lm(stack.loss ~ -1 + Air.Flow:owner + reg, data=dat))

## ----mlr-stackloss.form1.Z.lm.beta---------------------------------------
fit3=lm(stack.loss ~ -1 + Air.Flow:owner + reg, data=dat)
Z=model.matrix(fit3)
Z[1:4,]

## ----mlr-stackloss.form1.owner.solve-------------------------------------
y=matrix(dat$stack.loss, ncol=1)
solve(t(Z)%*%Z)%*%t(Z)%*%y

## ----mlr-stackloss.form2.owners------------------------------------------
y=matrix(dat$stack.loss, ncol=1)
x=matrix(c(1,dat$Air.Flow),ncol=1)
n=nrow(dat)
k=1
Z=matrix(list(0),n,k*n+1)
Z[seq(1,n,2),1]="alpha.n"
Z[seq(2,n,2),1]="alpha.s"
diag(Z[1:n,1+1:n])=rep(c("beta.s","beta.a"),n)[1:n]
P=MARSS:::convert.model.mat(Z)$free[,,1]
M=kronecker(t(x),diag(n))%*%P
solve(t(M)%*%M)%*%t(M)%*%y

## ----mlr-newstackloss.qtr------------------------------------------------
dat = cbind(dat, qtr=paste(rep("qtr",n),1:4,sep=""))
dat

## ----mlr-newstackloss.lm.qtr---------------------------------------------
coef(lm(stack.loss ~ -1 + qtr, data=dat))

## ----mlr-newstackloss.lm.qtr2--------------------------------------------
coef(lm(stack.loss ~ qtr, data=dat))

## ----mlr-stackloss.form1.Z.lm.qtr1---------------------------------------
fit4=lm(stack.loss ~ -1 + qtr, data=dat)
Z=model.matrix(fit4)
Z[1:4,]

## ----mlr-stackloss.form1.Z.lm.qtr2---------------------------------------
fit5=lm(stack.loss ~ qtr, data=dat)
Z=model.matrix(fit5)
Z[1:4,]

## ----mlr-set-up-big-dataset----------------------------------------------
data(stackloss, package="datasets")
fulldat=stackloss
n=nrow(fulldat)
fulldat=cbind(fulldat, 
          owner=rep(c("sue","aneesh","joe"),n)[1:n], 
          qtr=paste("qtr",rep(1:4,n)[1:n],sep=""),
          reg=rep(c("n","s"),n)[1:n])

## ----mlr-complex.lm------------------------------------------------------
fit7 = lm(stack.loss ~ -1 + qtr + Air.Flow:qtr:owner, data=fulldat)

## ----mlr-complex.lm.Z, results='hide'------------------------------------
model.matrix(fit7)

## ----mlr-complex.form1.solve, results='hide'-----------------------------
Z=model.matrix(fit7)

## ----mlr-complex.form2.solve, tidy=FALSE, results='hide'-----------------
y=matrix(fulldat$stack.loss, ncol=1)
x=matrix(c(1,fulldat$Air.Flow),ncol=1)
n=nrow(fulldat)
k=1
Z=matrix(list(0),n,k*n+1)
#give the intercepts names based on qtr
Z[,1]=paste(fulldat$qtr)
#give the betas names based on qtr and owner
diag(Z[1:n,1+1:n])=paste("beta",fulldat$qtr,fulldat$owner,sep=".")
P=MARSS:::convert.model.mat(Z)$free[,,1]
M=kronecker(t(x),diag(n))%*%P
solve(t(M)%*%M)%*%t(M)%*%y

## ----mlr-confounded------------------------------------------------------
coef(lm(stack.loss ~ -1 + Air.Flow + reg + qtr, data=fulldat))

## ----mlr-confounded2-----------------------------------------------------
fit=lm(stack.loss ~ -1 + Air.Flow + reg + qtr, data=fulldat)
Z=model.matrix(fit)

## ----mlr-confounded23----------------------------------------------------
fulldat2=fulldat
fulldat2$reg2 = rep(c("n","n","n","n","s","s","s","s"),3)[1:21]
fit=lm(stack.loss ~ Air.Flow + reg2 + qtr, data=fulldat2)
coef(fit)

## ----mlr-homework-data, tidy=FALSE---------------------------------------
data(airquality, package="datasets")
#remove any rows with NAs omitted.
airquality=na.omit(airquality)
#make Month a factor (i.e., the Month number is a name rather than a number)
airquality$Month=as.factor(airquality$Month)
#add a region factor
airquality$region = rep(c("north","south"),60)[1:111]
#Only use 5 data points for the homework so you can show the matrices easily
homeworkdat = airquality[1:5,]

## ----mlr-hw1-------------------------------------------------------------
fit=lm(Ozone ~ Wind + Temp, data=homeworkdat)

## ----mlr-hw1b------------------------------------------------------------
fit=lm(Ozone ~ -1 + Wind + Temp, data=homeworkdat)

## ----mlr-hw4-------------------------------------------------------------
fit=lm(Ozone ~ -1 + region, data=homeworkdat)

## ----mlr-hw5-------------------------------------------------------------
fit=lm(Ozone ~ Temp:region, data=homeworkdat)

## ----mlr-hw8-------------------------------------------------------------
fit=lm(Ozone ~ -1 + Temp:region + Month, data=airquality)


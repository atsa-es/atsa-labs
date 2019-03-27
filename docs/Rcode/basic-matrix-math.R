## ----basicmat-matrix-----------------------------------------------------
matrix(1, 3, 4)


## ----basicmat-matrix0----------------------------------------------------
matrix(1:12, 3, 4)
matrix(1:12, 3, 4, byrow=TRUE)


## ----basicmat-matrix1----------------------------------------------------
matrix(1:4, ncol=1)


## ----basicmat-matrix2----------------------------------------------------
matrix(1:4, nrow=1)


## ----basicmat-matrix3----------------------------------------------------
A=matrix(1:6, 2,3)
A
dim(A)


## ----basicmat-matrix4----------------------------------------------------
dim(A)[1]
nrow(A)


## ----basicmat-matrix5----------------------------------------------------
A=array(1:6, dim=c(2,3,2))
A
dim(A)


## ----basicmat-matrix6----------------------------------------------------
A=matrix(1:4, 1, 4)
A
class(A)
B=data.frame(A)
B
class(B)
C=1:4
C
class(C)


## ----basicmat-mult, tidy=FALSE-------------------------------------------
A=matrix(1:6, 2, 3) #2 rows, 3 columns
B=matrix(1:6, 3, 2) #3 rows, 2 columns
A%*%B #this works
B%*%A #this works
try(B%*%B) #this doesn't


## ----basicmat-add, tidy=FALSE--------------------------------------------
A+A #works
A+t(B) #works
try(A+B) #does not work since A has 2 rows and B has 3


## ----basicmat-transpose, tidy=FALSE--------------------------------------
A=matrix(1:6, 2, 3) #2 rows, 3 columns
t(A) #is the transpose of A
try(A%*%A) #this won't work
A%*%t(A) #this will


## ----basicmat-subset1, tidy=FALSE----------------------------------------
A=matrix(1:9, 3, 3) #3 rows, 3 columns
#get the first and second rows of A
#it's a 2x3 matrix
A[1:2,]
#get the top 2 rows and left 2 columns
A[1:2,1:2]
#What does this do?
A[c(1,3),c(1,3)]
#This?
A[c(1,2,1),c(2,3)]


## ----basicmat-subset2, tidy=FALSE----------------------------------------
A=matrix(1:9, 3, 3)
A[1,ncol(A)]
#or
A[1,dim(A)[2]]


## ----basicmat-subset3, tidy=FALSE----------------------------------------
A=matrix(1:9, 3, 3)
#take the first 2 rows
B=A[1:2,]
#everything is ok
dim(B)
class(B)
#take the first row
B=A[1,]
#oh no! It should be a 1x3 matrix but it is not.
dim(B)
#It is not even a matrix any more
class(B)
#and what happens if we take the transpose?
#Oh no, it's a 1x3 matrix not a 3x1 (transpose of 1x3)
t(B)
#A%*%B should fail because A is (3x3) and B is (1x3)
A%*%B
#It works? That is horrible!


## ----basicmat-dropfalse, tidy=FALSE--------------------------------------
B=A[1,,drop=FALSE]
#Now it is a matrix as it should be
dim(B)
class(B)
#this fails as it should (alerting you to a problem!)
try(A%*%B)


## ----basicmat-replace, tidy=FALSE----------------------------------------
A=matrix(1, 3, 3)
A[1,1]=2
A


## ----basicmat-replace2, tidy=FALSE---------------------------------------
A=matrix(1, 3, 3)
A[1,]=2
A
A[1,]=1:3
A


## ----basicmat-replace3, tidy=FALSE---------------------------------------
A=matrix(1, 3, 3)
A[c(1,3),c(3,1)]=2
A


## ----basicmat-replace4, tidy=FALSE---------------------------------------
A=matrix(1, 3, 3)
A[1,3]=2
A[3,1]=2
A


## ----basicmat-diag, tidy=FALSE-------------------------------------------
diag(1,3) #put 1 on diagonal of 3x3 matrix
diag(2, 3) #put 2 on diagonal of 3x3 matrix
diag(1:4) #put 1 to 4 on diagonal of 4x4 matrix


## ----basicmat-diag2------------------------------------------------------
A=matrix(3, 3, 3)
diag(A)=1
A
A=matrix(3, 3, 3)
diag(A)=1:3
A
A=matrix(3, 3, 4)
diag(A[1:3,2:4])=1
A


## ----basicmat-diag4------------------------------------------------------
A=matrix(1:9, 3, 3)
diag(A)


## ----basicmat-diag3------------------------------------------------------
A=matrix(1:9, 3, 3)
I=diag(3) #shortcut for 3x3 identity matrix
A%*%I


## ----basicmat-solve------------------------------------------------------
A=diag(3,3)+matrix(1,3,3)
invA=solve(A)
invA%*%A
A%*%invA


## ----basicmat-chol2inv---------------------------------------------------
A=diag(3,3)+matrix(1,3,3)
invA=chol2inv(chol(A))
invA%*%A
A%*%invA


## ----basicmat-reset, echo=FALSE, include.source=FALSE--------------------


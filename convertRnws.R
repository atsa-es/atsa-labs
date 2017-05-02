#run translations
source("rnw_to_rmd.R")
basefile="Lab-basic-matrix/basic-matrix-math"
rnw.to.rmd(basefile,"basicmat")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-linear-regression/linear-regression-models-matrix"
rnw.to.rmd(basefile,"mlr")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-intro-to-ts/intro-ts-funcs"
rnw.to.rmd(basefile,"ts")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-intro-to-jags/intro-to-jags"
rnw.to.rmd(basefile,"jags")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-fitting-uni-ss-models/fitting-univariate-state-space"
rnw.to.rmd(basefile,"uss")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-fitting-multi-ss-models/multivariate-ss"
rnw.to.rmd(basefile,"mss")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))

source("rnw_to_rmd.R")
basefile="Lab-fitting-DLMs/DLM"
rnw.to.rmd(basefile,"dlm")
#replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""))


# source("rnw_to_rmd.R")
# basefile="test"
# rnw.to.rmd(basefile)

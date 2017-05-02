#replace math commands with their definitions
#Why do a replacement like this? See comments below
source("rnw_to_rmd.R")
basefiles=c(
  "Lab-basic-matrix/basic-matrix-math",
  "Lab-linear-regression/linear-regression-models-matrix",
  "Lab-intro-to-ts/intro-ts-funcs",
  "Lab-dynamic-factor-analysis/intro-to-dfa",
  "Lab-fitting-uni-ss-models/fitting-univariate-state-space",
  "Lab-fitting-multi-ss-models/multivariate-ss",
  "Lab-fitting-DLMs/DLM",
  "Lab-intro-to-jags/intro-to-jags",
  "Lab-intro-to-stan/fitting-models-with-stan"
)
for(basefile in basefiles){
  replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""), paste(basefile,"-clean.Rmd",sep=""))
}

####################################################
# A search via google will show the following solutions
# Add 'before_body' to your output.yml:
#this works but the defs.tex is incl in html and flashes on screen
# If the def file is long, the flash is very obvious.
#
# bookdown::gitbook:
# before: |
#   includes:
#   before_body: [tex/bracket-start.txt, tex/defs.tex, tex/bracket-end.txt]
# bookdown::pdf_book:
#   includes:
# before_body: tex/defs.tex
# 
# Another solution is to use the child arg in a chunk near the top
# The problem is that it only works in math, so $ $ and $$ $$, not in equation, align or gather environments.
# ```{r test-main, child = 'tex/defs.tex'}
# ```

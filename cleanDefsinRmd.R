#replace math commands with their definitions
#Why do a replacement like this? See comments below
require(stringr)
replace.defs = function(defsfile, inputfile, outputfile){
  defs=readLines(defsfile)
  content=readLines(inputfile)
  for(i in defs){
    start=str_locate(i,"newcommand[{]")[2]+1
    end=str_locate(i,"[}]")[1]-1
    tag=str_sub(i, start, end)
    tag=str_replace(tag, "\\\\","\\\\\\\\")
    start=str_locate_all(i,"[{]")[[1]][2,1]+1
    end=str_length(i)-1
    repval=str_sub(i, start, end)
    repval=str_replace_all(repval, "\\\\","\\\\\\\\")
    content=str_replace_all(content, tag, repval)
  }
  writeLines(content, outputfile)
}

basefiles=c(
  "Lab-basic-matrix/basic-matrix-math",
  "Lab-linear-regression/linear-regression-models-matrix",
  "Lab-intro-to-ts/intro-to-ts",
  "Lab-intro-to-ts/intro-ts-funcs-lab",
  "Lab-dynamic-factor-analysis/intro-to-dfa",
  "Lab-fitting-uni-ss-models/fitting-univariate-state-space",
  "Lab-fitting-multi-ss-models/multivariate-ss",
  "Lab-fitting-multi-ss-models/multivariate-ss-cov",
  "Lab-fitting-DLMs/DLM",
  "Lab-intro-to-jags/intro-to-jags",
  "Lab-intro-to-stan/fitting-models-with-stan",
  "Lab-box-jenkins-method/box-jenkins"
)
for(basefile in basefiles){
  filename=str_split(basefile,"/")[[1]][2]
  outputfile = paste("cleanedRmd/",filename,".Rmd",sep="")
  replace.defs("tex/defs.tex", paste(basefile,".Rmd",sep=""), outputfile)
}

#Create the R files
require(stringr)
for(basefile in basefiles){
  filename=str_split(basefile,"/")[[1]][2]
  outputfile = paste("docs/Rcode/",filename,".R",sep="")
  knitr::purl(paste(basefile,".Rmd",sep=""), output= outputfile)
}

#Create the Rmd files
require(stringr)
for(basefile in basefiles){
  filename=str_split(basefile,"/")[[1]][2]
  inputfile = paste("cleanedRmd/",filename,".Rmd",sep="")
  outputfile = paste("docs/Rmds/",filename,".Rmd",sep="")
  file.copy(inputfile, outputfile, overwrite=TRUE)
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

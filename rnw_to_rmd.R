## script to convert a Rnw file to Rmd

rnw.to.rmd <- function(file){
  require(stringr)
  content=readLines(file)
  content=str_replace_all(content, "<<","```{r ")
  content=str_replace_all(content, ">>=", "}")
  chaplines=which(str_detect(content, "chapter[{]"))
  for(i in chaplines){
    content[i]=str_replace(content[i],"\\\\chapter[{]","# ")
    content[i]=str_split(content[i],"[}]")[[1]][1]
  }
  for(rem in c("chaptermark[{]", "label[{]chap", "end[{]example", "SweaveOpts")){
    removelines=which(str_detect(content, rem))
    if(length(removelines)!=0) content=content[-1*removelines]
  }

  seclines=which(str_detect(content, "section[{]"))
  for(i in seclines){
    content[i]=str_replace(content[i],"\\\\section[{]","## ")
    content[i]=str_split(content[i],"[}]")[[1]][1]
  }
  subseclines=which(str_detect(content, "subsection[{]"))
  for(i in subseclines){
    content[i]=str_replace(content[i],"\\\\subsection[{]","### ")
    content[i]=str_split(content[i],"[}]")[[1]][1]
  }
  comments=which(str_detect(content, "%%%%%%%%%%") | str_detect(content, "%~~~~~~~~~"))
  if(length(comments)!=0) content=content[-1*comments]
  comments=which(str_detect(content, "%[/^]"))
  if(length(comments)!=0) content=content[-1*comments]
  for(i in c("clearpage","renewcommand","addcontentsline","newline","exend", "exbegin")){
    removelines=which(str_detect(content, i))
    if(length(removelines)!=0) content=content[-1*removelines]
  }
  endlines=which(str_detect(content, "<<reset"))
  if(length(endlines)!=0) content=content[-1*(endlines:length(content))]
  #homework
  hwsec=which(str_detect(content, "section[*][{]Problems"))
  content[hwsec]="## Problems"
  enumstart=which(str_detect(content, "begin[{]hwenumerate"))
  enumend=which(str_detect(content, "end[{]hwenumerate"))
  items=which(str_detect(content, "\\item"))
  items=items[items>enumstart & items<enumend]
  for(i in 1:length(items)){
    content[items[i]]=str_replace(content[items[i]],"\\\\item", paste(i,".",sep=""))
  }
  #enumerate
  enumstart=which(str_detect(content, "begin[{]enumerate"))
  enumend=which(str_detect(content, "end[{]enumerate"))
  items=which(str_detect(content, "\\item"))
  items=items[items>enumstart & items<enumend]
  for(i in 1:length(items)){
    content[items[i]]=str_replace(content[items[i]],"\\\\item", paste(i,". ",sep=""))
  }
  #itemize
  enumstart=which(str_detect(content, "begin[{]itemize"))
  enumend=which(str_detect(content, "end[{]itemize"))
  items=which(str_detect(content, "\\item"))
  items=items[items>enumstart & items<enumend]
  for(i in 1:length(items)){
    content[items[i]]=str_replace(content[items[i]],"\\\\item", "* ")
  }

  #change equation labels to bookdown format
  eqnlabs=which(str_detect(content,"\\\\label[{]eqn:"))
  for(i in eqnlabs){
    locs=str_locate(content[i],"\\\\label[{]eqn:")
    locsend=str_locate_all(content[i],"[}]")[[1]]
    thisend=locsend[locsend[,1]>locs[1,2]][1]
    str_sub(content[i],thisend,thisend)<-")"
    str_sub(content[i],locs[1,1],locs[1,2])<-"(\\#eq:"
  }

  #change equation refs to bookdown format
  eqnrefs=which(str_detect(content, "\\\\ref[{]eqn:"))
  for(i in eqnrefs){
    locs=str_locate_all(content[i],"\\\\ref[{]eqn:")[[1]]
    locsend=str_locate_all(content[i],"[}]")[[1]]
    for(j in 1:dim(locs)[1]){
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-")"
      str_sub(content[i],locs[j,1],locs[j,2])<-"\\@ref(eq:"
    }
  }
  #change section labels to bookdown format
  seclabs=which(str_detect(content,"\\\\label[{]sec:"))
  for(i in seclabs){
    locs=str_locate(content[i],"\\\\label[{]sec:")
    str_sub(content[i],locs[1,1],locs[1,2])<-"{#sec-"
  }
  val1 = "\\\\ref[{]sec:"; val2="[}]"
  valr1 = "\\@ref(sec-"; valr2 =")" 
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]] #REDO SINCE VALR2 IS LONGER
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  #change any leftoever refs to bookdown format
  val1 = "\\\\ref[{]"; val2="[}]"
  valr1 = "\\@ref("; valr2 =")" 
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]] #REDO SINCE VALR2 IS LONGER
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  val1 = "\\\\textbf[{]"; val2="[}]"
  valr1 = "**"; valr2 ="**" #valr2 must be same length as val2 part in []
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]] #REDO SINCE VALR2 IS LONGER
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  val1 = "\\\\citet[{]"; val2="[}]"
  valr1 = "@"; valr2 ="" 
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]]
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  val1 = "\\\\citep[{]"; val2="[}]"
  valr1 = "@["; valr2 ="]"
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]]
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  val1 = "\\\\verb@"; val2="@"
  valr1 = "`"; valr2 ="`" #valr2 must be same length as val2 part in []
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]]
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  val1 = "\\\\texttt[{]"; val2="[}]"
  valr1 = "`"; valr2 ="`" #valr2 must be same length as val2 part in []
  vals=which(str_detect(content, val1))
  for(i in vals){
    locs=str_locate_all(content[i],val1)[[1]]
    while(nrow(locs)>0){
      locsend=str_locate_all(content[i],val2)[[1]]
      j=1
      thisend=locsend[locsend[,1]>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-valr2
      locs=str_locate_all(content[i],val1)[[1]]
      str_sub(content[i],locs[j,1],locs[j,2])<-valr1
      locs=str_locate_all(content[i],val1)[[1]]
    }
  }
  content[content=="@"]="```"
  content=str_replace_all(content, "label=", "")
  content=str_replace_all(content, ", keep[.]source=TRUE", "")
  content=str_replace_all(content, ",keep[.]source=TRUE", "")
  content=str_replace_all(content, ", include[.]source=TRUE", "")
  content=str_replace_all(content, ",include[.]source=TRUE", "")
  content=str_replace_all(content, ", keep[.]source=FALSE", "")
  content=str_replace_all(content, ",keep[.]source=FALSE", "")
  content=str_replace_all(content, ", include[.]source=FALSE", "")
  content=str_replace_all(content, ",include[.]source=FALSE", "")
  content=str_replace_all(content, "=hide", "='hide'")
  outfile = paste0(str_split(file,"[.]")[[1]][1],".Rmd")
  cat(content, file=outfile, sep="\n")
}
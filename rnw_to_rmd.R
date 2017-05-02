## script to convert a Rnw file to Rmd
rnw.to.rmd=function(basefilename, sectag){
  require(stringr)
  require(stringi)
  
  content=readLines(paste(basefilename,".Rnw",sep=""))
  
  #clean up Sweave specific lines
  #for(i in c("clearpage","renewcommand","addcontentsline")){
  for(i in c("renewcommand","addcontentsline","SweaveOpts","options[(]prompt")){
    removeline=which(str_detect(content, i))
    if(length(removeline)!=0) content=content[-1*removeline]
  }
  content=str_replace_all(content, "``","\"")
  content=str_replace_all(content, "''","\"")
  
  content=str_replace_all(content, "<<label=","```{r ")
  content=str_replace_all(content, "<<","```{r ")
  content=str_replace_all(content, ">>=", "}")
  chunklines=which(str_detect(content, "```[{]r[ ]"))
  content[chunklines]=str_trim(content[chunklines])
  
  content=str_replace_all(content, "results=hide","results='hide'")
  content=str_replace_all(content, "keep.source=TRUE","tidy=FALSE")
  content=str_replace_all(content, "fig=FALSE","fig.show='hide'")

  #This Problems section is unique to Fish507 Rnw files
  #fix so that it is numbered
  hwsec=which(str_detect(content, "\\\\section[*][{]Problems"))
  content[hwsec]=str_replace(content[hwsec],"\\\\section[*][{]Problems","\\\\section{Problems")

  #chapter, section and subsection lines
  vals=c("chapter","section","subsection", "chapter[*]","section[*]","subsection[*]")
  for(j in 1:length(vals)){
    jval=vals[j]
    jlatex = paste("\\\\", jval,"[{]",sep="")
    #need a blank line before any headings
    jrmd=c("\n# ","\n## ","\n### ", "\n# ","\n## ","\n### ")[j]
    jlines=which(str_detect(content, jlatex))
    removeline=integer(0)
    for(i in jlines){
      content[i]=str_replace(content[i], jlatex, jrmd)
      islabel=FALSE
      if(str_detect(content[i],"\\\\label")){ #first left brac before \label
        islabel=TRUE
        labelloc=str_locate(content[i], "\\\\label")[1]
        leftbracloc=str_locate_all(content[i], "[}]")[[1]][,1]
        leftbracofhead=max(leftbracloc[leftbracloc<labelloc])
      }else{ #no label so last left brac
        leftbracofhead=max(str_locate_all(content[i], "[}]")[[1]][,1])
      }
      str_sub(content[i], leftbracofhead, leftbracofhead)<- " "
      #if the label was put below \chapter{ }, \section{}, etc, move up
      if(!str_detect(content[i],"\\\\label")&str_detect(content[i+1],"\\\\label")){
        islabel=TRUE
        content[i] = paste(content[i], content[i+1])
        removeline=c(removeline, i+1)
      }
      if(!islabel & !str_detect(jlatex,"[*]")){ #make one
        sectitlestart=stri_locate_all_fixed(content[i],jrmd)[[1]][1,2]+1
        sectitle=str_sub(content[i], sectitlestart, leftbracofhead-1)
        sectitle=str_trim(sectitle)
        sectitle=stri_replace_all_fixed(sectitle," ","-")
        sectitle=str_to_lower(sectitle)
        pos <- str_locate_all(sectitle, "[a-z-]")[[1]]
        sectitle=paste(str_sub(sectitle, pos),collapse="")
        tagval=c("chap","sec","sec")[j]
        content[i] = paste(content[i], "\\label{",tagval,":",sectag,"-",sectitle,"}", sep="")
      }
      if(str_detect(jlatex,"[*]")) content[i]=paste(content[i], "{-}")
    }
    if(length(removeline)!=0) content=content[-1*removeline]
  }
  
  #remove the chaptermarks
  removeline=which(str_detect(content, "chaptermark[{]"))
  if(length(removeline)!=0) content=content[-1*removeline]
  
  #comments
  comments=which(
    str_detect(content, "%%%%%%%%%%")|
      str_detect(content, "%========")|
      str_detect(content,"%---------")|
      str_detect(content,"% end of content")|
      stri_detect_fixed(content, "%^^^^^^^^")|
      stri_detect_fixed(content, "%~~~")
  )
  if(length(comments)!=0) content=content[-1*comments]
  comments=which(str_detect(content, "%"))
  comments=comments[str_locate(content[comments],"%")[,1]==1]
  content[comments]=paste("<!--", content[comments], "-->")
                 
  #verb -> R code and shaded
  #need to do first to get rid of the @ associated with verb
  content=str_replace_all(content, "\\\\verb@", "```")
  content=str_replace_all(content, "@", "```")
  
  #enumerate
  enumstarts=which(str_detect(content, "begin[{]enumerate"))
  enumends=which(str_detect(content, "end[{]enumerate"))
  if(length(enumstarts)!=0){
    for(i in enumstarts){
      enumstart=i
      enumend=min(enumends[enumends>enumstart])
      items=which(str_detect(content, "\\\\item"))
      items=items[items>enumstart & items<enumend]
      for(j in 1:length(items)){
        itemnum=paste(j,". ",sep="")
        if(stri_detect_fixed(content[enumstart],"label=\\alph*)")) itemnum="a. "
        content[items[j]]=str_replace(content[items[j]],"\\\\item", itemnum)
        content[items[i]]=str_trim(content[items[i]])
      }
    }
    #set to "" to make sure there is always a blank line before and after lists
    content[enumstarts]=""
    content[enumends]=""
  }

    #itemize
  enumstarts=which(str_detect(content, "begin[{]itemize"))
  enumends=which(str_detect(content, "end[{]itemize"))
  if(length(enumstarts)!=0){
    for(i in enumstarts){
      enumstart=i
      enumend=min(enumends[enumends>enumstart])
      items=which(str_detect(content, "\\\\item"))
      items=items[items>enumstart & items<enumend]
      for(i in 1:length(items)){
        content[items[i]]=str_replace(content[items[i]],"\\\\item", "* ")
        content[items[i]]=str_trim(content[items[i]])
      }
    }
    content[enumstarts]=""
    content[enumends]=""
  }
  
  #description: make this bulleted list
  enumstarts=which(str_detect(content, "begin[{]description"))
  enumends=which(str_detect(content, "end[{]description"))
  if(length(enumstarts)!=0){
    for(i in enumstarts){
      enumstart=i
      enumend=min(enumends[enumends>enumstart])
      items=which(str_detect(content, "\\\\item"))
      items=items[items>enumstart & items<enumend]
      for(i in 1:length(items)){
        content[items[i]]=str_replace(content[items[i]],"\\\\item", "* ")
        #remove the square brackets
        bracloc=str_locate(content[items[i]], "]")[1]
        str_sub(content[items[i]], bracloc, bracloc) <- " "
        bracloc=str_locate(content[items[i]], "\\[")[1]
        str_sub(content[items[i]], bracloc, bracloc) <- " "
        content[items[i]]=str_trim(content[items[i]])
      }
    }
    content[enumstarts]=""
    content[enumends]=""
  }
  
  
  #homework
  
  #remove the stars on numbers
  hwstars=which(str_detect(content, "stepcounter[{]enumi"))
  if(length(hwstars)!=0){
    content=content[-1*hwstars]
    content=str_replace(content, "\\\\item\\[\\\\theenumi\\\\\\*\\*]", "\\\\item")
  }
  #only one hwenumerate in a Rnw file
  enumstart=which(str_detect(content, "begin[{]hwenumerate"))
  if(length(enumstart)!=0){
    enumend=which(str_detect(content, "end[{]hwenumerate"))
    items=which(str_detect(content, "\\item"))
    items=items[items>enumstart & items<enumend]
    for(i in 1:length(items)){
      content[items[i]]=str_replace(content[items[i]],"\\\\item", paste(i,".",sep=""))
    }
    content=content[-1*c(enumstart,enumend)]
  }
  
  #bfs, emph
  vals=c("textbf", "emph")
  for(j in 1:length(vals)){
    jval=vals[j]
    jlatex = paste("\\\\", jval,"[{]",sep="")
    jrmd=c("**","*")[j]
    jlines=which(str_detect(content, jlatex))
    for(i in jlines){
      locs=str_locate_all(content[i],jlatex)[[1]]
      for(j in 1:dim(locs)[1]){
        #number of locs is changing since num of jlatex changing
        #use first row always and work through each one
        locs=str_locate_all(content[i],jlatex)[[1]][1,]
        locsend=str_locate_all(content[i],"[}]")[[1]][,1]
        thisend=locsend[locsend>locs[2]][1]
        str_sub(content[i],thisend,thisend)<-jrmd
        #recompute locs since jrmd is can be longer that 1 char
        locs=str_locate_all(content[i],jlatex)[[1]][1,]
        str_sub(content[i],locs[1],locs[2])<-jrmd
      }
    }
  }
  
  #url
  jlatex = "\\\\url[{]"
  jlines=which(str_detect(content, jlatex))
  for(i in jlines){
    numlocs=dim(str_locate_all(content[i],jlatex)[[1]])[1]
    for(j in 1:numlocs){ 
      #since I am changing the line, need to keep updating locs
      locs=str_locate_all(content[i],jlatex)[[1]][1,]
      locsend=str_locate_all(content[i],"[}]")[[1]][,1]
      thisend=locsend[locsend>locs[2]][1]
      str_sub(content[i],thisend,thisend)<-" "
      str_sub(content[i],locs[1],locs[2])<-" "
    }
  }
  #href
  jlatex = "\\\\href[{]"
  jlines=which(str_detect(content, jlatex))
  for(i in jlines){
    numlocs=dim(str_locate_all(content[i],jlatex)[[1]])[1]
    for(j in 1:numlocs){ 
      #since I am changing the line, need to keep updating locs
      locs=str_locate_all(content[i],jlatex)[[1]][1,]
      locsend=str_locate_all(content[i],"[}]")[[1]][,1]
      hrefend=locsend[locsend>locs[2]][1]
      hrefurl=str_sub(content[i],locs[2]+1,hrefend-1)
      nameend=locsend[locsend>hrefend][1]
      locsstart=str_locate_all(content[i],"[{]")[[1]][,1]
      namestart=locsstart[locsstart>hrefend][1]
      nameurl=str_sub(content[i], namestart+1, nameend-1)
      reptext=paste("[", nameurl, "](", hrefurl, ")", sep="")
      str_sub(content[i], locs[1], nameend) <- reptext
    }
  }

  #texttt is typewriter font; must be wrapped in $ $
  jlatex = "\\\\texttt[{]"
  jlines=which(str_detect(content, jlatex))
  for(i in jlines){
    locs=str_locate_all(content[i],jlatex)[[1]]
    for(j in 1:dim(locs)[1]){ 
      #since I am changing the line, need to keep updating locs
      #but number of texttt does not change so use [j,] in locs
      locs=str_locate_all(content[i],jlatex)[[1]]
      locsend=str_locate_all(content[i],"[}]")[[1]][,1]
      thisend=locsend[locsend>locs[j,2]][1]
      str_sub(content[i],thisend,thisend)<-"}$"
      #rerun since I changed locs with addition of $
      locs=str_locate_all(content[i],jlatex)[[1]]
      str_sub(content[i],locs[j,1],locs[j,2])<-"$\\texttt{"
    }
  }
  
  #change equation labels to bookdown format
  #first detect if equation (or align) and label put on same line
  vals=c("equation", "align", "gather")
  for(j in 1:length(vals)){
    jval=vals[j]
    jlatex = paste("\\\\begin[{]", jval, sep="")
    labeloneqnline=which(str_detect(content,jlatex)&str_detect(content,"\\\\label[{]eqn:"))
    if(length(labeloneqnline)!=0){ #need to move labels to their own line
      for(i in labeloneqnline){
        #content[i]=str_replace(content[i],"\\\\label","\n\\\\label")
        content[i]=stri_replace_all_fixed(content[i],"\\label","\n\\label")
      }
    }
  }
  #then do the replacements
  eqnlabs=which(str_detect(content,"\\\\label[{]eqn:"))
  for(i in eqnlabs){
    #there will be one per line only
    locs=str_locate(content[i],"\\\\label[{]eqn:") 
    locsend=str_locate_all(content[i],"[}]")[[1]][,1] #loc all the }
    thisend=locsend[locsend>locs[2]][1] #we want first one after the label
    eqnlabname=str_sub(content[i],str_locate(content[i],"\\\\label[{]")[2]+1,thisend-1)
    eqnlabname=str_trim(eqnlabname)
    #periods are not allowed; fix if there eqn name has them
    if(str_detect(eqnlabname,"[.]")){ 
      cleaneqnlabname=stri_replace_all_fixed(eqnlabname,".","-")
      content=stri_replace_all_fixed(content,eqnlabname,cleaneqnlabname)
    }
    str_sub(content[i],thisend,thisend)<-")"
    str_sub(content[i],locs[1],locs[2])<-"(\\#eq:"
  }
  
  
  #change equation refs to bookdown format
  vals=c("eqref","ref")
  for(j in 1:length(vals)){
    jval=vals[j]
    jlatex = paste("\\\\",jval,"[{]eqn:",sep="")
    eqnrefs=which(str_detect(content, jlatex))
    for(i in eqnrefs){
      numlocs=dim(str_locate_all(content[i],jlatex)[[1]])[1]
      for(j in 1:numlocs){
        #need to recompute locs since I change line length
        #locs is changing dim since few jlatex; always use first row
        locs=str_locate_all(content[i],jlatex)[[1]][1,]
        locsend=str_locate_all(content[i],"[}]")[[1]][,1]
        thisend=locsend[locsend>locs[2]][1] #first one > end of jlatex is good
        str_sub(content[i],thisend,thisend)<-")"
        str_sub(content[i],locs[1],locs[2])<-"\\@ref(eq:"
      }
    }
  }
  
  #change section and chapter labels to pandoc format
  for(j in c("sec","chap","subsec")){
    labs=which(str_detect(content,paste("\\label[{]",j,":",sep="")))
    for(i in labs){ #only one per line
      locs=str_locate(content[i],paste("\\\\label[{]",j,":",sep=""))
      str_sub(content[i],locs[1],locs[2])<-paste("{#",j,"-",sep="")
    }
  }
  
  #change table labels to bookdown
  for(j in c("tab")){
    labs=which(str_detect(content,paste("\\label[{]",j,":",sep="")))
    for(i in labs){ #only one per line
      locs=str_locate(content[i],paste("\\\\label[{]",j,":",sep=""))
      locsend=str_locate_all(content[i],"[}]")[[1]][,1] #loc all the }
      thisend=locsend[locsend>locs[2]][1] #we want first one after the label
      str_sub(content[i],thisend,thisend)<-")"
      str_sub(content[i],locs[1],locs[2])<-paste("(\\#",j,":",sep="")
    }
  }
  
  #change section and chapter refs to bookdown format
  for(k in c("sec","chap","subsec")){
    refs=which(str_detect(content, paste("\\\\ref[{]",k,":",sep="")))
    for(i in refs){
      numlocs=dim(str_locate_all(content[i],paste("\\\\ref[{]",k,":",sep=""))[[1]])[1]
      for(j in 1:numlocs){
        locs=str_locate_all(content[i],paste("\\\\ref[{]",k,":",sep=""))[[1]][1,]
        locsend=str_locate_all(content[i],"[}]")[[1]][,1]
        thisend=locsend[locsend>locs[2]][1]
        str_sub(content[i],thisend,thisend)<-")"
        str_sub(content[i],locs[1],locs[2])<-paste("\\@ref(",k,"-",sep="")
      }
    }
  }
  
  #Figures
  figstarts=which(str_detect(content, "begin[{]figure"))
  figends=which(str_detect(content, "end[{]figure"))
  removelines=c(figstarts,figends)
  if(length(figstarts)!=0){
    for(i in figstarts){
      figstart=i
      figend=min(figends[figends>figstart])
      centers=which(str_detect(content, "begin[{]center")|str_detect(content, "end[{]center"))
      centers=centers[centers>figstart & centers<figend]
      removelines=c(removelines, centers)
      labs=which(str_detect(content, "\\\\label[{]"))
      labs=labs[labs>figstart & labs<figend]
      #if the figure has a label, get it and then remove
      rnwlabname=NULL
      if(length(labs)!=0){
        labstart=str_locate(content[labs],"\\\\label[{]")
        labend=str_locate_all(content[labs],"[}]")[[1]][,1]
      labend=labend[labend>labstart[2]][1]
      #need the name later
      rnwlabname=str_sub(content[labs],labstart[2]+1,labend-1)
      rnwlabname=str_trim(rnwlabname) #this is figure label in rnw
      #get rid of the label
      str_sub(content[labs], labstart[1], labend) <- " "
      }
      #locate the figure definition line
      defline=which(str_detect(content, "```[{]r[ ]"))
      defline=defline[defline>figstart & defline<figend]
      #locate the caption if any
      capline=which(str_detect(content, "\\\\caption[{]"))
      capline=capline[capline>figstart & capline<figend]
      if(length(capline)!=0){
        removelines=c(removelines, capline)
        caplocstart=str_locate(content[capline],"[{]")[1] #first one
        caplocend=max(str_locate_all(content[capline],"[}]")[[1]][,1]) #last one
        caption=str_sub(content[capline],caplocstart+1,caplocend-1)
        
        labstart=str_locate(content[defline],"```[{]r[ ]")[2]
        labend=str_locate(content[defline],"[,]")[1]
        figlabel=str_sub(content[defline], labstart+1, labend-1)
        figlabel=str_trim(figlabel)
        figlabel=stri_replace_all_fixed(figlabel,".","-")
        content[figstart]=paste("\n(ref:",figlabel,") ",caption, "\n", sep="")
        removelines=removelines[removelines!=figstart]
        defend=str_locate(content[defline],"[}]")[1]
        str_sub(content[defline],defend,defend)<- paste(", fig.cap='(ref:",figlabel,")'}", sep="")
        #if there was a rnw figure label, it might not be correct. Fix
        if(!is.null(rnwlabname)){
          content=stri_replace_all_fixed(content, rnwlabname, paste("fig:",figlabel,sep=""))
        }
      }
      content[defline]=str_replace(content[defline],"height=","fig.height=")
      content[defline]=str_replace(content[defline],"width=","fig.width=")
      content[defline]=str_replace(content[defline],"fig[.]fig","fig")
      content[defline]=str_replace(content[defline],"out[.]fig","out")
    }
    content=content[-1*removelines]
  }
  #change fig refs to bookdown format
  refs=which(str_detect(content, "\\\\ref[{]fig:"))
  for(i in refs){
    numlocs=dim(str_locate_all(content[i],"\\\\ref[{]fig:")[[1]])[1]
    for(j in 1:numlocs){
      #need to recompute locs since changing line;
      #num locs changing since num of jlatex is changing; use first
      locs=str_locate_all(content[i],"\\\\ref[{]fig:")[[1]][1,]
      locsend=str_locate_all(content[i],"[}]")[[1]][,1]
      thisend=locsend[locsend>locs[2]][1]
      str_sub(content[i],thisend,thisend)<-")"
      str_sub(content[i],locs[1],locs[2])<-"\\@ref(fig:"
    }
  }

  writeLines(content, paste(basefilename,".Rmd",sep=""))
}

replace.defs = function(defsfile, inputfile, outputfile){
  require(stringr)
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
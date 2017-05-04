---
title: "AFTS Labbook"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## AFTS Labbook

To build the book
```{r tmp, eval=FALSE}
source("cleanDefsinRmd.R")
bookdown::render_book("index.Rmd", "bookdown::gitbook")
bookdown::render_book("index.Rmd", "bookdown::pdf_book")
```
You can use 'Build Book' under the build tab in RStudio but make sure to 
```{r eval=FALSE}
source("cleanDefsinRmd.R")
```
first.

## Key files

* index.Rmd: Yaml metadata for the book is at the top of file
* _output.yml output yaml is here
* _bookdown.yml has what Rmd to put in the book.  rmd_subdir: TRUE means to allow search across chapters
* style.css is the css file for the book.  Sets things like font and code block style.
* DESCRIPTION RStudio uses this to detect that this is a bookdown book.  Under Tools:Project Options:Build Tools set the project type to 'Website'.  Then the 'Build Book' option will appear under the Build tab.

## Directories

### docs

This is where bookdown put the html files.  It also has an Rcode and data folders.  `cleanDefsinRmd()` tangles the Rmds and put the R scripts in the Rcode folder.  You need to put your data files in the data folder so that the user can download them.  See the Rmd file for intro-ts-funcs.Rmd for an example.

### individual chapter folders

This is were your Rmd files for the chapter are kept.  `cleanDefsinRmd()` takes these, cleans and puts a copy in the cleanedRmd folder.  You need to edit cleanDefsinRmd.R, when you add new Rmd files to be added to the book.

### images

This has cover image.

### tex

This has tex files used for the PDF production.

### _bookdown_files

bookdown populates this.  It has cache.
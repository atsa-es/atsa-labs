# AFTS Labbook Info

* [Writing the rmarkdown files](#writing)
* [Special Rmd conventions for AFTS](#special)
* [Key files](#key-files)
* [Directories](#directories)
* [Building the book](#build)

## Writing the rmarkdown files {#writing}

### Code in text, package names and object names

Use ```foo``` (or ``foo``) for things you want in code font.  The following should be put font: anything you would see in the R console.  Typically, this is code snippets or references to an output value, like ```foo```.  But also use it for anything that you would see in the console.  So if you want to tell the reader what the residual variance is in the ``lm()`` summary output, use ``sigma2``.

functions: The function ```lm()``` is used for linear regression.  Put ``()`` after functions.

Packages: Put in bold face.  **stats** package.

Object names: Put in bold face.  This is a **ts** object.

### Code output in text

If you want the output of code, then decide if you want that output in code font or not.  ```r 1+1``` and ``r 1+1`` will put 2 in code font. `r 1+1` will put 2 in the font of the text.

### Math shortcuts

You can use the shortcuts in tex/defs.tex.  These are things like \AA for ``\mathbf{A}``.

### Label chunks uniquely with a unique tag for your chapter

Label all your chunks uniquely and do NOT use "." or ":" in your chunk names. "-" is ok.  This is because bookdown will sometimes make filenames from this name and ":" and "." are illegal in filenames.
So ``foo-foo`` is ok and ``foo.foo`` is not

### Chapter and section labelling

Label chapters like with 'chap-' and a tag specific to that chapter

 # This is chapter foo {#chap-foo}

Label sections like with 'sec-' and a tag specific to that chapter

 # This is section foo {#sec-foo-this-section}

### Cross-references

The cross-references all take the form `\@ref(label)`.

Chapters and sections: 

{#sec-ts-CO2-data}  --> Section`\@ref(sec-ts-CO2-data)`

{#chap-ts}  --> Chapter `\@ref(chap-ts)` 

Figures and figures:  Bookdown builds the figure label from the chunk label.

```{r ts-fig-foo}plot(1)``` --> Figure \@ref{fig:ts-fig-foo}

```{r ts-table-foo}kable(1)``` --> Table \@ref{tab:ts-fig-foo}

If you don't use kable(), then read up on table cross-referencing
https://bookdown.org/yihui/bookdown/tables.html

Equations: You must use the form 'eq:label' so an equation reference in the text looks like `\@ref(eq:label)`

To have an equation number that you can reference you need to label the equation.  To do this, you must use the equation, align or gather environments.

```
\begin{equation}
1+1
(\#eq:one)
\end{equation}
```

### Figure captions

You can pass these in `fig.cap='This is my caption.'` but if your caption is long or contains rmarkdown, then use a text reference. Here is an example

    (ref:foo) A scatterplot of the data `cars` using **base** R graphics. 

    ```{r foo, fig.cap='(ref:foo)'}
    plot(cars)  # a scatterplot
    ```

### R code you don't want put in the R scripts for users

`cleanDefsinRmd.R` will make R code files automatically from the Rmd files.  If you have chunks that you don't want in those files put `purl=FALSE` in the header.  So
```{r foo, purl=FALSE}
```

## Special conventions {#special}

Look at the other Rmd files and follow the conventions for the first page.  These have

* A link to the R code for the chapter in docs/Rcode folder.
* A section about the packages and data.  If short, this can be on page 1 of chapter.  If long, a separate section.
* Links to the data as RData files in docs/data folder.

At the top of the Rmd files, add a hidden chunk that sets the tag if you forget to label a chunk.  You cannot duplicate chunk names across all Rmd files, so the tag makes sure that doesn't happen.

    ```{r dfa-setup, include=FALSE, purl=FALSE}
    #in case you forget to add a chunk label
    knitr::opts_knit$set(unnamed.chunk.label = "dfa-")
    ```


## To build the book {#build}

    ```{r tmp, eval=FALSE}
    source("cleanDefsinRmd.R")
    bookdown::render_book("index.Rmd", "bookdown::gitbook")
    bookdown::render_book("index.Rmd", "bookdown::pdf_book")
    ```
    
You can use 'Build Book' under the build tab in RStudio but make sure to run `cleanDefsinRmd.R` first.  To see the 'Build Book' option on the build tab, go Tools:Project Options:Build Tools and set the project type to 'Website'.  

## Key files {#key-files}

* index.Rmd: First page.  Yaml metadata for the book is at the top of file
* _output.yml output yaml is here
* _bookdown.yml has what Rmd to put in the book.  rmd_subdir: TRUE means to allow search across chapters
* style.css is the css file for the book.  Sets things like font and code block style.
* DESCRIPTION RStudio uses this to detect that this is a bookdown book.  
* cleanDefsinRmd.R This is the script to populate the cleanedRmd folder with the Rmd files used in _bookdown.yml.  It replaces the mathdefs (like \AA), tangles the R code from the Rmd and puts in docs/Rcode.

## Directories {#directories}

Most of these you will see on GitHub.  A couple directories are only for your local machine.

### docs

This is where bookdown put the html files.  It also has an Rcode and data folders.  `cleanDefsinRmd()` tangles the Rmds and put the R scripts in the Rcode folder.  You need to put your data files in the data folder so that the user can download them.  See the Rmd file for intro-ts-funcs.Rmd for an example.

### individual chapter folders

This is were your Rmd files for the chapter are kept.  `cleanDefsinRmd()` takes these, cleans and puts a copy in the cleanedRmd folder.  You need to edit cleanDefsinRmd.R, when you add new Rmd files to be added to the book.

### images

This has cover image though not used anywhere (yet).

### tex

This has tex files used for the PDF production.

### _bookdown_files

bookdown populates this.  It has cache.

### libs (local machine only)

To build the book on your local machine, you'll install the bookdown package and build as described in [build the book](#build).  bookdown will create the libs folder in your project with jquery and gitbook folders.

### .gitignore

I have many files in my local repository that don't need to be on GitHub.  All the `AFTS` files are stuff generated if a book build fails, and the clean up fails.  Normally all this is in the docs folder.  The `#Misc` stuff is stuff I am working on and have not cleaned up yet.

Here is what my .gitignore looks like:

```
#RProj files
.Rproj.user/
AFTS-Labbook.Rproj
AFTS_cache/
AFTS_files/
AFTS.Rmd
AFTS.tex
AFTS.pdf
AFTS.log
AFTS.toc
libs

#Misc
*.Rnw
$/*.Rnw
Lab-estimating-B
Lab-basic-matrix/*.pdf
Lab-dynamic-factor-analysis/*.pdf
Lab-dynamic-factor-analysis/*-key*
Lab-fitting-DLMs/*_key*
Lab-fitting-DLMs/*.csv
Lab-fitting-DLMs/*.xlsx
Lab-fitting-multi-ss-models/*.pdf
Lab-fitting-multi-ss-models/*-cov*
Lab-fitting-multi-ss-models/*.R
Lab-fitting-uni-ss-models/*.r
Lab-fitting-uni-ss-models/*.Rnw
Lab-intro-to-jags/*.R
Lab-intro-to-stan/*.R
Lab-intro-to-ts/*_key*
Lab-intro-to-ts/*.csv
Lab-intro-to-ts/*.txt
Lab-linear-regression/*.pdf
Lab-linear-regression/*.Rnw
read-this-before-writing-rmarkdown.txt
marss-jags.txt

# Windows image file caches
Thumbs.db
ehthumbs.db

# Folder config file
Desktop.ini

# Recycle Bin used on file shares
$RECYCLE.BIN/

# Windows Installer files
*.cab
*.msi
*.msm
*.msp

# Windows shortcuts
*.lnk

# =========================
# Operating System Files
# =========================

# OSX
# =========================

.DS_Store
.AppleDouble
.LSOverride

# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk
```
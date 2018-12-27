# for some reasons, you should install this packages at first
options(encoding = 'UTF-8')
options("repos" = c(CRAN="https://mirrors.ustc.edu.cn/CRAN"))
require_packages = c(
  "AlgDesign",
  "ape",
  "arules",
  "BayesTree",
  "Ball", # for debug
  "bmp",
  "Cairo",
  "car",
  "chron",
  "crayon",
  "data.table",
  "DBI",
  "devtools",
  "downloader",
  "dplyr",
  "DT",
  "e1071",
  "emdbook",
  "evd",
  "expm",
  "fields",
  "fmsb",
  "foreign",
  "formatR",
  "formattable",
  "fortunes",
  "gafit",
  "gcookbook",
  "getopt",
  "GGally",
  "ggiraph",
  "ggmap",
  "ggplot2",
  "glmnet",
  "googleVis",
  "gridExtra",
  "gsubfn",
  "gtable",
  "gvlma",
  "gWidgets",
  "Hmisc",
  "htmltools",
  "IDPmisc",
  "igraph",
  "IRdisplay",
  "jpeg",
  "kableExtra",
  "knitr",
  "kohonen",
  "lars",
  "lattice",
  "lubridate",
  "magic",
  "magrittr",
  "MASS",
  "mcmc",
  "microbenchmark",
  "miniUI",
  "mosaic",
  "mvnormtest",
  "nnet",
  "nortest",
  "officer",
  "openxlsx",
  "optparse",
  "outliers",
  "pheatmap",
  "pixmap",
  "plotrix",
  "plyr",
  "png",
  "pool",
  "pracma",
  "pROC",
  "psych",
  "qualityTools",
  "quantmod",
  "R.matlab",
  "R.utils",
  "R6",
  "Rcpp",
  "repr",
  "readxl",
  "reshape2",
  "RgoogleMaps",
  "rhandsontable",
  "rJava",
  "rjson",
  "rmarkdown",
  "rms",
  "RMySQL",
  "robust",
  "robustbase",
  "RODBC",
  "rredis",
  "rsconnect",
  "Rserve",
  "RSQLite",
  "rstudioapi",
  "rticles",
  "RUnit",
  "rvest",
  "rworldmap",
  "scatterplot3d",
  "sciplot",
  "shiny",
  "shinyAce",
  "shinyBS",
  "shinycssloaders",
  "shinydashboard",
  "shinyjs",
  "shinythemes",
  "sjmisc",
  "sos",
  "sound",
  "spam",
  "sqldf",
  "stringi",
  "stringr",
  "tidyverse",
  "treemapify",
  "vars",
  "vcd",
  "venneuler",
  "wordcloud",
  "xlsx",
  "XML",
  "xts",
  "zip",
  "zoo"
)

install_packages = setdiff(require_packages,unname(installed.packages()[,1]))
if(length(install_packages)){install.packages(install_packages)}
# install from github
library(devtools)
devtools::install_github("rstudio/addinexamples")
devtools::install_github("mkuhn/dict")
devtools::install_github("thomasp85/ggforce")
devtools::install_github("GuangchuangYu/DOSE")
devtools::install_github("GuangchuangYu/enrichplot")
devtools::install_github("GuangchuangYu/clusterProfiler")
                       
# bioconductor
# source('https://bioconductor.org/biocLite.R')
if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")
options(BioC_mirror="https://mirrors.ustc.edu.cn/bioc")
## modern install 
BiocManager::install("GDCRNATools", suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
BiocManager::install(c("DESeq2" , "edgeR"), suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##)
BiocManager::install(c("fgsea","org.Mm.eg.db", "org.Hs.eg.db","GEOquery", "limma", "simpleaffy", "AnnotationDbi", "biomartr"),suppressUpdates=TRUE, suppressAutoUpdate=TRUE)

BiocManager::install("RTCGA", suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
BiocManager::install("RTCGA.clinical", suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ## 14Mb
BiocManager::install('RTCGA.rnaseq', suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##  (612.6 MB)
BiocManager::install("RTCGA.mRNA", suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##  (85.0 MB)
BiocManager::install('RTCGA.mutations', suppressUpdates=TRUE, suppressAutoUpdate=TRUE)  ## (103.8 MB)
# legacy install
# Install the main RTCGA package
#BiocManager::biocLite("RTCGA", suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
# Install the clinical and mRNA gene expression data packages
#BiocManager::biocLite("RTCGA.clinical", suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ## 14Mb
#BiocManager::biocLite('RTCGA.rnaseq', suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##  (612.6 MB)
#BiocManager::biocLite("RTCGA.mRNA", suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##  (85.0 MB)
#BiocManager::biocLite('RTCGA.mutations', suppressUpdates=TRUE, suppressAutoUpdate=TRUE)  ## (103.8 MB)

# for some reasons, you should install this packages at first
options(encoding = 'UTF-8')
options("repos" = c(CRAN="http://mirrors.ustc.edu.cn/CRAN"))

require_packages = c(
  "AlgDesign",
  "ape",
  "arules",
  "BayesTree",
  "bmp",
  "Cairo",
  "car",
  "chron",
  "crayon",
  "data.table",
  "DBI",
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
  "RUnit",
  "rvest",
  "rworldmap",
  "scatterplot3d",
  "sciplot",
  "shiny",
  "shinyAce",
  "shinyBS",
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
source('https://bioconductor.org/biocLite.R')
options(BioC_mirror='http://mirrors.ustc.edu.cn/bioc')
install_github('davidgohel/ggiraph')
install_github("hadley/readxl")
install_github("hadley/tidyverse")
install_github('rstudio/addinexamples')
install_github('andrewsali/shinycssloaders')
install_github("rstudio/rticles")
install_github("rstudio/pool")
install_github("mkuhn/dict")
install_github('thomasp85/ggforce')

biocLite("fgsea", suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
install_github("GuangchuangYu/DOSE")
install_github("GuangchuangYu/enrichplot")
install_github("GuangchuangYu/clusterProfiler")
biocLite(c('org.Mm.eg.db', 
          'GEOquery', 
          'limma', 
          'simpleaffy', 
          'AnnotationDbi', 
          'biomartr'), suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
biocLite(c("DESeq2" , "edgeR"), suppressUpdates=TRUE, suppressAutoUpdate=TRUE)



# TCGA
# Install the main RTCGA package
biocLite("RTCGA")
# Install the clinical and mRNA gene expression data packages
biocLite("RTCGA.clinical") ## 14Mb
biocLite('RTCGA.rnaseq') ##  (612.6 MB)
biocLite("RTCGA.mRNA") ##  (85.0 MB)
biocLite('RTCGA.mutations')  ## (103.8 MB)

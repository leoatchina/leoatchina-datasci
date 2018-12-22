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
install_github('davidgohel/ggiraph')
install_github("hadley/readxl")
install_github("hadley/tidyverse")
install_github('rstudio/addinexamples')
install_github('andrewsali/shinycssloaders')
install_github("rstudio/rticles")
install_github("rstudio/pool")
install_github("mkuhn/dict")
install_github('thomasp85/ggforce')
install_github("GuangchuangYu/DOSE")
install_github("GuangchuangYu/enrichplot")
install_github("GuangchuangYu/clusterProfiler")
                       
# bioconductor
# source('https://bioconductor.org/biocLite.R')
if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")
options(BioC_mirror='http://mirrors.ustc.edu.cn/bioc')
## modern install 
BiocManager::install("GDCRNATools", suppressUpdates=TRUE, suppressAutoUpdate=TRUE)
BiocManager::install(c("DESeq2" , "edgeR"), suppressUpdates=TRUE, suppressAutoUpdate=TRUE) ##)
BiocManager::install(c('fgsea','org.Mm.eg.db', 'org.Hs.eg.db','GEOquery', 'limma', 'simpleaffy', 'AnnotationDbi', 'biomartr'),suppressUpdates=TRUE, suppressAutoUpdate=TRUE)

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

# for some reasons, you should install this packages at first
options(encoding = 'UTF-8')
options("repos" = c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
options(BioC_mirror="https://mirrors.tuna.tsinghua.edu.cn/bioconductor")

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
                     "languageserver",
                     "lubridate",
                     "magic",
                     "magrittr",
                     "MASS",
                     "mcmc",
                     "microbenchmark",
                     "mice",
                     "miniUI",
                     "mosaic",
                     "mvnormtest",
                     "nnet",
                     "NMF",
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
                     "robust",
                     "robustbase",
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
                     "servr",
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
                     # "qualityTools",
                     # "gWidgets",
                     # "RMySQL",
                     # "RODBC",
install_packages = setdiff(require_packages,unname(installed.packages()[,1]))
if(length(install_packages)){install.packages(install_packages)}

bioPackages = c(
    "GDCRNATools",
    "R.utils", "data.table",
    "maftools",
    "GEOquery",
    "FactoMineR", "factoextra", "ggfortify",
    "pheatmap",
    "ggplot2",
    "limma", "DESeq2", "edgeR",
    "clusterProfiler", "org.Hs.eg.db", "org.Mm.eg.db",
    "pathview",
    "sigminer",
    "RTCGA", "RTCGA.rnaseq", "RTCGA.clinical", "RTCGA.mutations",
    "RTCGA.mRNA", "RTCGA.miRNASeq", "RTCGA.RPPA", "RTCGA.CNV", "RTCGA.methylation"
)

# %%
CRANpackages <- row.names(available.packages())

lapply(bioPackages, function(bioPackage){
         if (!require(bioPackage, character.only = T)){
           if (bioPackage %in% CRANpackages){
             install.packages(bioPackage)
           }else{
             if (!requireNamespace("BiocManager", quietly = TRUE))
               install.packages("BiocManager")
             BiocManager::install(bioPackage, update = TRUE, ask = FALSE)
           }
         }
})

# install from github
library(devtools)
devtools::install_github("rstudio/addinexamples")
devtools::install_github("mkuhn/dict")
devtools::install_github("thomasp85/ggforce")
devtools::install_github("GuangchuangYu/DOSE")
devtools::install_github("GuangchuangYu/enrichplot")
devtools::install_github("GuangchuangYu/clusterProfiler")
devtools::install_github(c("yihui/servr", "hafen/rmote"))

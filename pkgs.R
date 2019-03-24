# for some reasons, you should install this packages at first
options(encoding = 'UTF-8')
options(repos  = "https://mirrors.ustc.edu.cn/CRAN")
options(BioC_mirror = "https://mirrors.ustc.edu.cn/bioc")
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
                 
bioPackages = 
  c( 
    "GDCRNATools", ##
    "dplyr", "stringi", "purrr", ## 
    "R.utils", "data.table", ## unzip and read table
    "GEOquery", ## download
    "FactoMineR", "factoextra", "ggfortify", ## PCA
    "pheatmap", ## heatmap
    "ggplot2", ## Volcano plot
    "limma", "DESeq2", "edgeR", ## DEG
    "clusterProfiler", "org.Hs.eg.db", "org.Mm.eg.db", ## annotation
    "pathview", ## kegg
    "RTCGA.rnaseq","RTCGA.clinical","RTCGA.mutations",
    "RTCGA.mRNA","RTCGA.miRNASeq","RTCGA.RPPA","RTCGA.CNV","RTCGA.methylation"
  )
lapply( bioPackages, 
  function(bioPackage) {
    if ( !require( bioPackage, character.only = T ) ) {
      CRANpackages = available.packages()
      ## install packages by CRAN
      if ( bioPackage %in% rownames( CRANpackages ) ) {
        install.packages( bioPackage )
      }else{
        ## install packages by bioconductor
        ## R version >= 3.5 ===> BiocManager
        if ( as.character( sessionInfo()$R.version$minor ) >= 3.5 ) {
          if (!requireNamespace("BiocManager", quietly = TRUE))
            install.packages("BiocManager")
          BiocManager::install(bioPackage, update = TRUE, ask = FALSE)
        }else{
          ## R version < 3.5 ===> BiocInstaller
          if (!requireNamespace("BiocInstaller", quietly = TRUE))
            source( "https://bioconductor.org/biocLite.R" )
          BiocInstaller::biocLite( bioPackage, ask = FALSE)
        }
      }
    }
  }
)

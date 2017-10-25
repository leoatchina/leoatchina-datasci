## config Rstudio-server
.bashrc
```
  export PATH=/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  export JAVA_HOME=/opt/anaconda3/jre
```
在console中
```
  options(encoding = "UTF-8")
  source("https://bioconductor.org/biocLite.R")
  options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")
  options("repos" = c(CRAN="http://mirrors.ustc.edu.cn/anaconda/CRAN/"))
  options(download.file.method = "libcurl")
```

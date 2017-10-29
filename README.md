# Rstudio-server and AnacondaLab in a docker
## 说明
leoatchina的jupyter dockerfile，集成了rstudio-server和anacondalab
## 启动后可能要的配置 
.bashrc,放到根目录
```
export PATH=/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export JAVA_HOME=/usr/lib/jvm/java
export TERM=xterm-256color
```
console
```
Sys.setenv(PATH="/opt/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
Sys.setenv(JAVA_HOME="/usr/lib/jvm/java")
options(encoding = "UTF-8")
source("https://bioconductor.org/biocLite.R")
options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")
options("repos" = c(CRAN="http://mirrors.tuna.tsinghua.edu.cn/anaconda/CRAN/"))
options(download.file.method = "curl")
```

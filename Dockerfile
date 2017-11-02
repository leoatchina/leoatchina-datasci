FROM ubuntu:latest
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
## update system
RUN apt-get update  -y && apt-get upgrade -y &&  \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:neovim-ppa/stable -y && \
    apt-get update  -y && \
    apt-get install -y apt-utils gdebi-core && \
    apt-get install -y libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev apt-transport-https && \
    apt-get install -y wget curl unzip bzip2 git htop supervisor xclip silversearcher-ag && \ 
    apt-get install -y build-essential gfortran libcairo2-dev libxt-dev && \
    apt-get install -y libapparmor1 libedit2 libc6 psmisc rrdtool && \
    apt-get install -y neovim ctags zsh && \
    apt-get install -y libzmq3-dev libtool && \
    apt-get clean && apt-get purge && rm -rf /tmp/*
# PATH
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -o Anaconda3.sh && \
    bash Anaconda3.sh -b -p /opt/anaconda3 && rm Anaconda3.sh && \ 
    conda clean  -a -y
## 重要的channel 放后面
RUN conda config --add channels bioconda && \
    conda config --add channels r && \
    conda config --add channels conda-forge && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --set show_channel_urls yes

## install R
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  E084DAB9
RUN apt-get update -y && \
    apt-cache -q search r-cran-* | awk '$1 !~ /^r-cran-r2jags$/ { p = p" "$1 } END{ print p }' | \
    xargs apt-get install -y r-base && \
    apt-get clean && apt-get purge && rm -rf /tmp/*
## rice
RUN pip --no-cache-dir install rice
## rstudio-server
ENV RSTUDIO_WHICH_R=/usr/bin/R
RUN cd /tmp && \
    curl https://s3.amazonaws.com/rstudio-server/current.ver -o /tmp/rstudio.ver && \
    curl http://download2.rstudio.org/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb -o /tmp/rstudio.deb && \
    gdebi --non-interactive  /tmp/rstudio.deb && \
    apt-get clean && apt-get purge && rm -rf /tmp/*
## install java
# RUN apt-get install openjdk-8-jdk -y && \
#     apt-get clean && apt-get purge && rm -rf /tmp/*
# 
# RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java
# ENV JAVA_HOME=/usr/lib/jvm/java
# RUN R CMD javareconf

## install something for http and https
RUN conda install redis redis-py celery pika  -y && \
    conda clean -a -y
    
## R kernel for anaconda3
RUN Rscript -e "options(encoding = 'UTF-8');\
    source('https://bioconductor.org/biocLite.R');\
    options(BioC_mirror='http://mirrors.ustc.edu.cn/bioc/');\
    options(download.file.method = 'libcurl');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    install.packages(c('rstudioapi', 'miniUI'), type = 'source');\
    install.packages('devtools');\
    install.packages('RCurl');\
    install.packages('crayon');\
    install.packages('repr');\
    library(devtools);\
    install_github('rstudio/addinexamples');\
    install_github('armstrtw/rzmq');\
    install_github('takluyver/IRkernel');\
    install.packages('IRdisplay');\
    install.packages('pbdZMQ');\
    IRkernel::installspec();\
    system('rm -rf /tmp/*') "

## Download and install Shiny Server
RUN cd /tmp && \
    curl https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -o version.txt && \
    VERSION=$(cat version.txt)  && \
    curl https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb -o shiny-server-latest.deb && \
    gdebi -n shiny-server-latest.deb && \
    rm -rf * 

RUN Rscript -e "options(encoding = 'UTF-8');\
    options(download.file.method = 'libcurl');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    install.packages(c('shiny', 'rmarkdown', 'rsconnect','RSQLite','RMySQL')) ;\
    install.packages( c('shinydashboard','DT','reshape2')); \
    install.packages( c('shinyBS','GGally','shinyAce','knitr')); \
    install.packages( c('rmarkdown','shinyjs' )); \
    system('rm -rf /tmp/*') "

# configuration
## users
RUN useradd jupyter -d /home/jupyter && echo jupyter:jupyter | chpasswd
WORKDIR /home/jupyter
## config dir
RUN mkdir -p /etc/rstudio /etc/shiny-server /opt/config /opt/log /opt/shiny-server
RUN chmod -R 777 /opt/config /opt/log
# RUN cp -R /usr/local/lib/R/site-library/shiny/examples/* /opt/shiny-server/


COPY rserver.conf /etc/rstudio/
COPY shiny-server.conf /etc/shiny-server
COPY jupyter_notebook_config.py /opt/config
COPY jupyter_lab_config.py /opt/config
COPY supervisord.conf /opt/config

CMD ["/usr/bin/supervisord","-c","/opt/config/supervisord.conf"]

## share
EXPOSE 15672 8888 8787 3838
VOLUME ["/home/jupyter","/mnt","/disks","/oss","/work","/data"]

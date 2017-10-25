FROM ubuntu:latest
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
## update system
RUN apt-get update --fix-missing -y && apt-get upgrade -y &&  \
    apt-get -y install apt-utils libapparmor1 libcurl4-openssl-dev \
    libxml2 libxml2-dev libssl-dev gdebi-core apt-transport-https \
    wget curl unzip bzip2 git vim supervisor && \ 
    apt-get clean && apt-get purge
RUN cd /tmp && curl http://mirrors.ustc.edu.cn/anaconda/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -O && \
    bash Anaconda3-5.0.0.1-Linux-x86_64.sh -b -p /opt/anaconda3 && rm Anaconda3-5.0.0.1-Linux-x86_64.sh
ENV PATH=/opt/anaconda3/bin:$PATH
## 重要的channel 放后面
RUN conda config --add channels bioconda && \
    conda config --add channels r && \
    conda config --add channels conda-forge && \
    conda config --add channels http://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --set show_channel_urls yes
## R
RUN conda install -c r r-essentials -y && \
    conda clean -a -y

## install complile tools 
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install build-essential -y --fix-missing && \
    apt-get install gfortran -y && \
    apt-get install libcairo2-dev libxt-dev -y && \
    apt-get clean && apt-get purge
## install R
RUN echo "deb http://mirrors.ustc.edu.cn/CRAN/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  E084DAB9
RUN apt-get update -y && \
    apt-cache -q search r-cran-* | awk '$1 !~ /^r-cran-r2jags$/ { p = p" "$1 } END{ print p }' | \
    xargs apt-get install -y r-base && \
    apt-get clean && apt-get purge
## rstudio-server
RUN cd /tmp && \
    curl https://s3.amazonaws.com/rstudio-server/current.ver -o /tmp/rstudio.ver && \
    curl http://download2.rstudio.org/rstudio-server-$(cat /tmp/rstudio.ver)-amd64.deb -o /tmp/rstudio.deb && \
    gdebi --non-interactive  /tmp/rstudio.deb && \
    rm /tmp/rstudio.deb && \
    rm /tmp/rstudio.ver && \
    apt-get clean && apt-get purge
## rice
RUN pip  --no-cache-dir install rice 

## install java
RUN apt-get install openjdk-8-jdk -y && \
    apt-get clean && apt-get purge
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java
ENV JAVA_HOME=/usr/lib/jvm/java

## config R 
RUN R -e 'options(encoding = "UTF-8"); \
        source("https://bioconductor.org/biocLite.R"); \
        options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/"); \
        options("repos" = c(CRAN="http://mirrors.ustc.edu.cn/anaconda/CRAN/")); \
        options(download.file.method = "libcurl")'
        ###如果rstudio-server里不能下载pkgs，download.file.method改成curl或者wget

## install others

## install something for https or http
# RUN conda install redis redis-py celery pika \
#     conda clean -a -y

# configuration
## ENV for java
RUN R CMD javareconf
## env for rstudio-server
ENV RSTUDIO_WHICH_R=/usr/bin/R
RUN mkdir -p /etc/rstudio
## config dir
COPY rserver.conf /etc/rstudio
COPY jupyter_notebook_config.py /opt/
COPY jupyter_lab_config.py /opt/
COPY supervisord.conf /opt/
## users
RUN useradd jupyter -d /home/jupyter && echo jupyter:jupyter | chpasswd
WORKDIR /home/jupyter
## share
EXPOSE 15672 8888 8787 80
VOLUME ["/home/jupyter","/mnt","/disks","/oss","/work"]
CMD ["/usr/bin/supervisord","-c","/opt/supervisord.conf"]

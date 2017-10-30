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
    apt-get clean && apt-get purge && rm -rf /tmp/*
# PATH
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -O && \
    bash Anaconda3-5.0.0.1-Linux-x86_64.sh -b -p /opt/anaconda3 && rm Anaconda3-5.0.0.1-Linux-x86_64.sh && \
## 重要的channel 放后面
    conda config --add channels bioconda && \
    conda config --add channels r && \
    conda config --add channels conda-forge && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --set show_channel_urls yes && \
    conda clean  -a -y

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
RUN apt-get install openjdk-8-jdk -y && \
    apt-get clean && apt-get purge && rm -rf /tmp/*

RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java
ENV JAVA_HOME=/usr/lib/jvm/java

## install something for http and https
RUN conda install redis redis-py celery pika  -y && \
    conda clean -a -y

RUN conda install zeromq -y && \
    conda clean -a -y
RUN apt-get install -y libzmq3-dev libtool && \
    apt-get clean && apt-get purge && rm -rf /tmp/*
# configuration
## ENV for java
RUN R CMD javareconf
## config dir
RUN mkdir -p /etc/rstudio/
COPY rserver.conf /etc/rstudio/
COPY jupyter_notebook_config.py /opt/
COPY jupyter_lab_config.py /opt/
COPY supervisord.conf /opt/
## users
RUN useradd jupyter -d /home/jupyter && echo jupyter:jupyter | chpasswd
WORKDIR /home/jupyter
CMD ["/usr/bin/supervisord","-c","/opt/supervisord.conf"]

## share
EXPOSE 15672 8888 8787 80
VOLUME ["/home/jupyter","/mnt","/disks","/oss","/work","/data"]

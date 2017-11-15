FROM ubuntu:latest
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
## update system
RUN apt-get update  -y && apt-get upgrade -y &&  \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:neovim-ppa/stable && \
    apt-get update  -y && \
    apt-get install -y apt-utils gdebi-core && \
    apt-get install -y libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev apt-transport-https && \
    apt-get install -y wget curl unzip bzip2 git htop supervisor xclip silversearcher-ag && \ 
    apt-get install -y build-essential gfortran libcairo2-dev libxt-dev && \
    apt-get install -y libapparmor1 libedit2 libc6 psmisc rrdtool && \
    apt-get install -y libzmq3-dev libtool && \
    apt-get install -y neovim ctags zsh && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && apt-get purge && apt-get autoremove && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* 
# PATH
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -o Anaconda3.sh && \
    bash Anaconda3.sh -b -p /opt/anaconda3 && rm Anaconda3.sh && \ 
    conda clean  -a -y
## 重要的channel 放后面
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/mro/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --set show_channel_urls yes

## install R
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://mirrors.ustc.edu.cn/CRAN/bin/linux/ubuntu xenial/'
RUN apt-get update -y && \
    apt-cache -q search r-cran-* | awk '$1 !~ /^r-cran-r2jags$/ { p = p" "$1 } END{ print p }' | xargs \
    apt-get install -y r-base r-base-dev && \
    cd /tmp && \
    curl https://s3.amazonaws.com/rstudio-server/current.ver -o rstudio.ver && \
    curl http://download2.rstudio.org/rstudio-server-$(cat rstudio.ver)-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    curl https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -o shiny.txt && \
    curl https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$(cat shiny.txt)-amd64.deb -o shiny.deb && \
    gdebi -n shiny.deb && \
    apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* 

## rice
RUN pip --no-cache-dir install rice

## R kernel for anaconda3
RUN Rscript -e "options(encoding = 'UTF-8');\
    source('https://bioconductor.org/biocLite.R');\
    options(BioC_mirror='http://mirrors.ustc.edu.cn/bioc/');\
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
    install.packages(c('shiny', 'rmarkdown', 'rsconnect','RSQLite','RMySQL')) ;\
    install.packages( c('shinydashboard','DT','reshape2')); \
    install.packages( c('shinyBS','GGally','shinyAce','knitr')); \
    install.packages( c('rmarkdown','shinyjs' )); \
    system('rm -rf /tmp/*') "


RUN apt-get update -y && apt-get install bing ifconfig -y && \
    apt-get clean && apt-get purge && apt-get autoremove && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* 

# configuration
## system local config
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
## git shortcuts
RUN git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative" && \
    git config --global alias.st status && \
    git config --global alias.co checkout && \
    git config --global alias.ci commit && \
    git config --global alias.br branch && \
    git config --global alias.rs reset
## users
RUN useradd jupyter -d /home/jupyter && echo jupyter:jupyter | chpasswd
WORKDIR /home/jupyter/
## config dir
RUN mkdir -p /etc/rstudio /etc/shiny-server /opt/config /opt/log /opt/shiny-server && \
    chmod -R 777 /opt/config /opt/log
COPY rserver.conf /etc/rstudio/
COPY shiny-server.conf /etc/shiny-server/
COPY jupyter_notebook_config.py /opt/config/
COPY jupyter_lab_config.py /opt/config/
COPY supervisord.conf /opt/config/
## start server
CMD ["/usr/bin/supervisord","-c","/opt/config/supervisord.conf"]
## share
EXPOSE 8888 8787 7777 3838
VOLUME ["/home/jupyter","/mnt","/disks","/oss","/data"]


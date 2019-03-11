FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
RUN apt-get update -y && apt-get upgrade -y &&  \
    apt-get install -y apt-utils gdebi-core net-tools iputils-ping && \
    apt-get install -y wget curl unzip bzip2 git htop supervisor xclip silversearcher-ag cmake sudo ctags \
    libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev apt-transport-https  libncurses5-dev \
    build-essential gfortran libcairo2-dev libxt-dev automake bash-completion \
    libapparmor1 libedit2 libc6 psmisc rrdtool libzmq3-dev libtool software-properties-common \
    bioperl libdbi-perl \
    tree vim \ 
    locales && locale-gen en_US.UTF-8 && \
    cpan -i Try::Tiny && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
# PATH, if not set here, conda clean not works in the next RUN
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && \
    version=$(curl -s https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/ | grep Linux | grep _64 | tail -1 |cut -d"\"" -f2) && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/$version -o Anaconda3.sh && \
    bash Anaconda3.sh -b -p /opt/anaconda3 && rm Anaconda3.sh && \
    conda clean  -a -y
## 使用清华的源
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/mro/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --set show_channel_urls yes
## install R
RUN add-apt-repository ppa:marutter/rrutter3.5  && \
    add-apt-repository ppa:ubuntugis/ppa -y && \
    apt-get update -y && \
    apt-get install -y r-api-3.5 && \
    apt-get install -y libv8-3.14-dev libudunits2-dev libgdal1i libgdal1-dev \
                       libproj-dev gdal-bin proj-bin libgdal-dev libgeos-dev && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## install rstudio
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/rstudio-server-1.1.463-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## R kernel for anaconda3, and shiny
RUN Rscript -e "options(encoding = 'UTF-8');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    install.packages(c('devtools', 'RCurl', 'crayon', 'repr', 'IRdisplay', 'pbdZMQ'));\
    library(devtools); \
    install_github('takluyver/IRkernel');\
    IRkernel::installspec();\
    system('rm -rf /tmp/*') "
# java8
RUN conda install -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda java-jdk && conda clean -a -y && R CMD javareconf
# pip install something
ADD pip.conf /root/.pip/
RUN pip install neovim mysql-connector-python python-language-server urllib3 && \
    rm -rf /root/.cache/pip/* /tmp/* && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
# configuration
## .oh-my-zsh
ADD .inputrc /root/
ADD .bashrc /root/
ADD .configrc /root/
## system local config
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
## users
RUN useradd rserver -d /home/rserver && mkdir /jupyter
WORKDIR /jupyter
## config dir
RUN mkdir -p /etc/rstudio /etc/shiny-server /opt/config /opt/log /opt/shiny-server && chmod -R 777 /opt/config /opt/log
ADD rserver.conf /etc/rstudio/
ADD shiny-server.conf /etc/shiny-server/
ADD jupyter_lab_config.py /opt/config/
ADD supervisord.conf /opt/config/
## set up passwd in entrypoin.sh
ADD passwd.py /opt/config/
ENV PASSWD=jupyter
ADD entrypoint.sh /opt/config/
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
## share
EXPOSE 8888 8787 7777 3838
VOLUME ["/home/rserver","/jupyter","/mnt"]

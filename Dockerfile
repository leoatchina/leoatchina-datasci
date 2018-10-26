FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
RUN apt-get update  -y && apt-get upgrade -y &&  \
    apt-get install -y apt-utils gdebi-core net-tools iputils-ping && \
    apt-get install -y wget curl unzip bzip2 git htop supervisor xclip silversearcher-ag cmake zsh sudo ctags \
    libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev apt-transport-https  libncurses5-dev \
    build-essential gfortran libcairo2-dev libxt-dev automake autoconf \
    libapparmor1 libedit2 libc6 psmisc rrdtool libzmq3-dev libtool software-properties-common \
    locales && locale-gen en_US.UTF-8 && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## vim8
RUN add-apt-repository ppa:jonathonf/vim && \
    apt update -y && apt install vim -y && \
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
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu xenial/'

RUN apt-get update -y && \
    #apt-cache -q search r-cran-* | awk '$1 !~ /^r-cran-r2jags$/ { p = p" "$1 } END{ print p }' | xargs \
    apt-get install -y r-base r-base-dev && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## install rstudio
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/rstudio-server-1.1.456-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## install shinny
RUN cd /tmp && \ 
    curl https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.6.875-amd64.deb -o shiny.deb && \
    gdebi -n shiny.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
## R kernel for anaconda3, and shiny
RUN Rscript -e "options(encoding = 'UTF-8');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    install.packages(c('devtools', 'RCurl', 'crayon', 'repr', 'IRdisplay', 'crayon', 'pbdZMQ'));\
    library(devtools); \
    install_github('takluyver/IRkernel');\
    IRkernel::installspec();\
    install.packages(c('shiny', 'shinyjs', 'shinyBS', 'shinydashboard', 'shinyAce' )); \
    install.packages(c('GGally', 'knitr',  'rmarkdown', 'rsconnect','RSQLite', 'RMySQL', 'DT', 'reshape2')) ;\
    system('rm -rf /tmp/*') "

## install into /opt/anaconda3
ADD pip.conf /root/.pip/
RUN pip install neovim mysql-connector-python python-language-server urllib3 && \
    rm -rf /root/.cache/pip/* /tmp/*
## install something for R packages
RUN add-apt-repository ppa:ubuntugis/ppa -y && \
    add-apt-repository ppa:lazygit-team/release -y && \
    apt-get update -y && \
    apt-get install -y libv8-3.14-dev libudunits2-dev libgdal1i libgdal1-dev \
                       libproj-dev gdal-bin proj-bin libgdal-dev libgeos-dev lazygit && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
# java8
RUN apt-get update -y && apt-get upgrade -y && add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && apt-get update -y && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
# configuration
## .oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
ADD .zshrc /root/
ADD .bashrc /root/
ADD .aliases /root/
ADD .vimrc.local /root/
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
## install texlive
## texlive for laxtex
#RUN cd /tmp && \
    #wget https://github.com/jgm/pandoc/releases/download/2.2.3.2/pandoc-2.2.3.2-1-amd64.deb && \
    #dpkg -i pandoc-2.2.3.2-1-amd64.deb && \
    #apt-get update -y && \
    #apt-get install texlive-full -y && \
    #apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

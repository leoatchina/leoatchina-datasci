FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
# installation
## update system
RUN apt-get update  -y && apt-get upgrade -y &&  \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:jonathonf/vim && \
    apt-get update  -y && \
    apt-get install -y wget curl unzip bzip2 git htop supervisor xclip silversearcher-ag && \ 
    apt-get install -y apt-utils gdebi-core && \
    apt-get install -y libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev apt-transport-https && \
    apt-get install -y build-essential gfortran libcairo2-dev libxt-dev && \
    apt-get install -y libapparmor1 libedit2 libc6 psmisc rrdtool && \
    apt-get install -y libzmq3-dev libtool && \
    apt-get install -y cmake ctags zsh sudo && \
    apt-get install -y net-tools iputils-ping && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    apt-get install -y vim python3-dev python3-pip sudo && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ADD pip.conf /root/.pip/
# PATH
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && \
    version=$(curl -s https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/ | grep Linux | grep _64 | tail -1 |cut -d"\"" -f2) && \
    curl --limit-rate 4M https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/$version -o Anaconda3.sh && \
    bash Anaconda3.sh -b -p /opt/anaconda3 && rm Anaconda3.sh && \
    conda clean  -a -y
## 使用清华的源
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
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## install rstudio
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/rstudio-server-1.1.442-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## install shinny
RUN cd /tmp && \ 
    curl https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.6.875-amd64.deb -o shiny.deb && \
    gdebi -n shiny.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## pandoc
RUN cd /tmp && \
    wget https://github.com/jgm/pandoc/releases/download/2.2.1/pandoc-2.2.1-1-amd64.deb  && \
    dpkg -i pandoc-2.2.1-1-amd64.deb && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## textlive
RUN apt-get update -y && \
    apt-get install texlive-full -y && \
    apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## softwares for lint check
RUN pip3 --no-cache-dir install pylint flake8 pep8 jedi neovim mysql-connector-python python-language-server && \
    pip3 install --upgrade pip && \
    rm -rf /root/.cache/pip/* /tmp/*

# configuration
## system local config
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
## users
RUN useradd rserver -d /home/rserver &&  mkdir /jupyter
WORKDIR /jupyter
## config dir
RUN mkdir -p /etc/rstudio /etc/shiny-server /opt/config /opt/log /opt/shiny-server && chmod -R 777 /opt/config /opt/log
ADD rserver.conf /etc/rstudio/
ADD shiny-server.conf /etc/shiny-server/
ADD jupyter_notebook_config.py /opt/config/
ADD jupyter_lab_config.py /opt/config/
ADD supervisord.conf /opt/config/
## set up passwd in entrypoin.sh
ADD passwd.py /opt/config/
ENV PASSWD=jupyter
ADD entrypoint.sh /opt/config/
ENTRYPOINT ["/opt/config/entrypoint.sh"]
## .oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
ADD .zshrc /root/
ADD .bashrc /root/
## share
EXPOSE 8888 8787 7777 3838
VOLUME ["/home/rserver","/jupyter","/mnt","/disks"]
# install_require_pkgs.R is the packages for R
ADD install_require_pkgs.R /opt/config/

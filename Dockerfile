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

# PATH, if not set here, conda clean not works in the next RUN
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && \
    version=$(curl -s https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/ | grep Linux | grep _64 | tail -1 |cut -d"\"" -f2) && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/$version -o Anaconda3.sh && \
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
    add-apt-repository 'deb [arch=amd64,i386] https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu xenial/'

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
## R kernel for anaconda3, and shiny
RUN Rscript -e "options(encoding = 'UTF-8');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    source('https://bioconductor.org/biocLite.R');\
    options(BioC_mirror='http://mirrors.ustc.edu.cn/bioc/');\
    install.packages(c('devtools', 'RCurl', 'crayon', 'repr'));\
    install.packages(c('shiny', 'shinyjs', 'shinyBS', 'shinydashboard', 'rmarkdown', 'rsconnect','RSQLite','RMySQL', 'DT', 'reshape2')) ;\
    install.packages(c('shinyBS','GGally','shinyAce','knitr', 'IRdisplay', 'pbdZMQ')); \
    library(devtools);\
    install_github('armstrtw/rzmq');\
    install_github('takluyver/IRkernel');\
    IRkernel::installspec();\
    system('rm -rf /tmp/*') "

## texlive for laxtex 
RUN cd /tmp && \
    wget https://github.com/jgm/pandoc/releases/download/2.2.3.2/pandoc-2.2.3.2-1-amd64.deb && \
    dpkg -i pandoc-2.2.3.2-1-amd64.deb && \
    apt-get update -y && \
    apt-get install texlive-full -y && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## install into /opt/anaconda3
ADD pip.conf /root/.pip/
RUN pip install neovim mysql-connector-python python-language-server && \
    rm -rf /root/.cache/pip/* /tmp/*

## install bioconda tools
RUN conda install -y -c bioconda sra-tools trimmomatic cutadapt fastqc multiqc trim-galore star hisat2 bowtie2 \
    subread htseq bedtools deeptools salmon bwa samtools bcftools vcftools -y && \
    conda clean  -a -y

## vim8 without "+lua", "+python", "+python3"
RUN cd /tmp && \
    wget https://github.com/vim/vim/archive/v8.1.0329.tar.gz  && \
    tar xvzf v8.1.0329.tar.gz && \
    cd vim-8.1.0329 && \
    ./configure --enable-multibyte \
                --enable-cscope \
                --with-features=huge \
                --enable-largefile \
                --disable-netbeans  \
                --enable-fail-if-missing && \
    make -j8 && make install && \
    apt-get autoremove && apt-get clean && apt-get purge && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

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

FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
COPY sources.list /etc/apt/sources.list
RUN apt update -y && apt upgrade -y && \
    apt install -y wget curl net-tools iputils-ping apt-transport-https openssh-server \
    unzip bzip2 apt-utils gdebi-core tmux \
    git htop supervisor xclip cmake sudo \
    libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev libncurses5-dev libncursesw5-dev libjansson-dev \
    build-essential gfortran libcairo2-dev libxt-dev automake bash-completion \
    libapparmor1 libedit2 libc6 psmisc rrdtool libzmq3-dev libtool software-properties-common \
    bioperl libdbi-perl tree python-dev python3-dev \ 
    locales && locale-gen en_US.UTF-8 && \
    cpan -i Try::Tiny && \
    add-apt-repository ppa:jonathonf/vim -y && \
    apt update -y &&  \
    apt install -y vim && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# configuration
COPY .bashrc .inputrc .configrc /root/
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
RUN mkdir -p /opt/rc && cp /root/.bashrc /root/.inputrc /root/.configrc /opt/rc
# bash && ctags
RUN cd /tmp && \ 
    wget https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz && \
    tar xvzf bash-5.0.tar.gz && \
    cd bash-5.0 && \
    ./configure && \
    make && \
    make install && \
    cd /tmp && \
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb && \
    dpkg -i ripgrep_11.0.1_amd64.deb && \
    cd /tmp && \
    git clone --depth 1 https://github.com/universal-ctags/ctags.git && cd ctags && \
    ./autogen.sh && ./configure && make && make install && \
    cd /tmp && \
    curl http://ftp.vim.org/ftp/gnu/global/global-6.6.3.tar.gz -o global.tar.gz && \
    tar xvzf global.tar.gz && cd global-6.6.3 && \
    ./configure --with-sqlite3 && make && make install && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# node and yarn 
RUN apt install -y nodejs nodejs-legacy npm && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install -g n && n stable && \
    npm install -g yarn && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# R
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/' && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    add-apt-repository ppa:ubuntugis/ppa -y && \
    apt update -y && \
    apt install -y r-base-dev r-base r-base-core r-recommended && \
    apt install -y libv8-3.14-dev libudunits2-dev libgdal1i libgdal1-dev libproj-dev gdal-bin proj-bin libgdal-dev libgeos-dev libclang-dev && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# rstudio
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# PATH, if not set here, conda cmd not work 
ENV PATH=/opt/anaconda3/bin:$PATH
# anaconda3
RUN cd /tmp && \
    version=$(curl -s https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/ | grep Linux | grep _64 | tail -1 | awk -F'"' '/^<a href/ {print $2}') && \
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
RUN conda install -c bioconda java-jdk && \
		conda clean -a -y && R CMD javareconf && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
## R kernel for anaconda3
RUN Rscript -e "options(encoding = 'UTF-8');\
    options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    install.packages(c('devtools', 'RCurl', 'crayon', 'repr', 'IRdisplay', 'pbdZMQ', 'IRkernel'));\
    IRkernel::installspec();\
    system('rm -rf /tmp/*') "
# coder server
RUN cd /tmp && \
    curl -L https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz -o code-server.tar.gz && \
    tar xvzf code-server.tar.gz && \
    mv code-server1.1156-vsc1.33.1-linux-x64 /opt/code-server && \
    rm -rf /tmp/*.*
# pip install something
COPY pip.conf /root/.pip/
RUN pip install PyHamcrest && \
    pip install --upgrade pip && \
    pip install neovim mysql-connector-python python-language-server mock radian requests pygments && \
    pip install flake8 --ignore-installed && \
    rm -rf /root/.cache/pip/* /tmp/* && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
## system local config
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
## users
RUN useradd rserver -d /home/rserver && mkdir /jupyter && mkdir /var/run/sshd
WORKDIR /jupyter
## config dir
RUN mkdir -p /etc/rstudio /opt/config /opt/log  && chmod -R 777 /opt/config /opt/log
## set up passwd in entrypoin.sh
ENV PASSWD=jupyter
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
## share
EXPOSE 8888 8787 8443 8822
VOLUME ["/home/rserver","/jupyter"]

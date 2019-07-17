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
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xvzf libiconv.tar.gz && cd libiconv-1.16 && \
    ./configure && make && make install && \
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
# anaconda3  
RUN cd /tmp && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2019.03-Linux-x86_64.sh -o anaconda3.sh && \
    bash anaconda3.sh -b -p /opt/anaconda3 && rm -r /tmp/* && \
    ln -s /opt/anaconda3/bin/conda /usr/bin/conda && \
    conda clean  -a -y
# core packages
RUN conda update conda-build && \
    conda clean -a -y
RUN conda update --all && \
    conda clean -a -y 
RUN conda install -c conda-forge neovim mysql-connector-python python-language-server mock pygments flake8 nodejs yarn && \
    conda clean -a -y 
# jupyterlab
RUN conda update -c conda-forge jupyterlab && \
    conda clean -a -y 
# java
RUN conda install -c bioconda/label/cf201901 java-jdk && \
    ln -s /opt/anaconda3/bin/java /usr/bin/java && \
		R CMD javareconf && \
    conda clean -a -y 
## R kernel for anaconda3  
#RUN Rscript -e "options(encoding = 'UTF-8');\
    #options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'));\
    #install.packages(c('devtools', 'RCurl', 'crayon', 'repr', 'IRdisplay', 'pbdZMQ', 'IRkernel'));\
    #IRkernel::installspec();\
    #system('rm -rf /tmp/*') "
# coder server
RUN cd /tmp && \
    curl -L https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz -o code-server.tar.gz && \
    tar xvzf code-server.tar.gz && \
    mv code-server1.1156-vsc1.33.1-linux-x64 /opt/code-server && \
    rm -rf /tmp/*.*
RUN apt install -y xvfb libswt-gtk-4-java && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
## fzf rdy
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
## system local config
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
## users
RUN useradd rserver -d /home/rserver
# configuration
COPY .bashrc .inputrc /root/
RUN /root/.fzf/install --all
RUN mkdir -p /opt/rc && cp -R /root/.bashrc /root/.inputrc /root/.fzf.bash /root/.fzf /opt/anaconda3/share/jupyter /opt/rc/
RUN mkdir -p /etc/rstudio /work /opt/config /opt/log  && chmod -R 777 /opt/config /opt/log
ENV PASSWD=jupyter
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
## share ports and dirs 
EXPOSE 8888 8787 8443 8822
WORKDIR /work
VOLUME ["/home/rserver","/work"]

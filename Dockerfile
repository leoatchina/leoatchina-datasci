FROM ubuntu:20.04
MAINTAINER leoatchina,leoatchina@outlook.com
ADD sources.list /etc/apt/sources.list
WORKDIR /var/build
ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y && apt upgrade -y && \
    apt install -y wget curl net-tools iputils-ping \
      zip unzip bzip2 apt-utils screen \
      htop xclip cmake sudo tree jq time && \
    apt install -y software-properties-common language-pack-zh-hans locales && locale-gen en_US.UTF-8 && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

RUN add-apt-repository ppa:ubuntugis/ppa -y && apt update -y && \
    apt install -y --fix-missing \
      supervisor gdebi-core python2.7-dev \
      libjansson-dev libcairo2-dev libxt-dev librdf0 librdf0-dev \
      libudunits2-dev libproj-dev libapparmor1 libedit2 libc6 apt-transport-https && \
    apt install -y --fix-missing \
      git ripgrep \
      gdal-bin proj-bin \
      psmisc rrdtool libzmq3-dev \
      libtool libevent-dev \
      libx11-dev libxext-dev \
      libgdal-dev libgeos-dev \
      libclang-dev cscope libncurses5-dev && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

# ctags gtags tmux
RUN cd /tmp && \
    git clone --depth=1 https://gitclone.com/github.com/universal-ctags/ctags.git && cd ctags && \
    ./autogen.sh && ./configure --prefix=/usr/local && make && make install && \
    cd /tmp && \
    git clone --depth=1 https://gitclone.com/github.com/tmux/tmux.git && cd tmux && \
    ./autogen.sh && ./configure --prefix=/usr/local && make && make install && \
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && \
    cd libiconv-1.16 && ./configure --prefix=/usr/local && make && make install && \
    cd /tmp && \
    curl https://www.openssl.org/source/openssl-1.1.0l.tar.gz -o openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd openssl-1.1.0l && ./config --prefix=/usr/local && make && make install && \
    cd /tmp && \
    wget https://ftp.gnu.org/pub/gnu/global/global-6.6.8.tar.gz && \
    tar xzf global-6.6.8.tar.gz && \
    cd global-6.6.8 && ./configure --prefix=/usr/local --with-sqlite3 && make && make install && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

    # openssh-server nginx bioperl libdbi-perl
# code-server
RUN cd /tmp && \
    curl -L https://github.do/https://github.com/coder/code-server/releases/download/v4.3.0/code-server-4.3.0-linux-amd64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server-4.3.0-linux-amd64 /opt/code-server && \
    rm -rf /tmp/*.*

# R language
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' && \
    apt update -y && apt upgrade -y && \
    apt install -y r-base-dev r-base r-base-core r-recommended && \
    apt install -y openjdk-8-jdk xvfb libswt-gtk-4-java && \
    R CMD javareconf && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /tmp && \
    curl https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2022.02.2-485-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

# miniconda3
ENV PATH=/opt/miniconda3/bin:$PATH
RUN cd /tmp && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3.sh && \
    bash miniconda3.sh -b -p /opt/miniconda3 && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && conda clean -a -y
RUN conda install -n base -c conda-forge mamba && \
    mamba install -n base -c conda-forge xeus-python libxml2 \
              libxslt libssh2 krb5 bat jupyterlab nodejs yarn ranger-fm && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && conda clean -a -y

RUN /opt/miniconda3/bin/pip install --no-cache-dir pynvim neovim-remote flake8 pygments python-language-server ueberzug && \
    /opt/miniconda3/bin/jupyter labextension install @jupyterlab/debugger && \
    /opt/miniconda3/bin/jupyter lab build && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && conda clean -a -y

# vim
RUN apt install vim -y && \
    mamba install -n base -c conda-forge vim && \
    ln -sf /opt/miniconda3/bin/vim /usr/bin && \
    cd /usr/local && \
    curl -L https://github.do/https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-linux64.tar.gz -o nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    ln -sf /usr/local/nvim-linux64/bin/nvim /usr/bin && \
    rm nvim-linux64.tar.gz && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && conda clean -a -y

# configuration
RUN mkdir -p /etc/rstudio /opt/config /opt/log /opt/rc && chmod -R 755 /opt/config /opt/log
COPY .bashrc .inputrc .bash_profile .configrc /opt/rc/
# users ports and dirs and configs
RUN echo "export LC_ALL='C.UTF-8'" >> /etc/profile
ENV LANG C.UTF-8
ENV WKUSER=datasci
ENV PASSWD=datasci
ENV COUNTRY=CN
ENV PROVINCE=ZJ
ENV CITY=HZ
ENV ORGANIZE=SELF
ENV WEB=leatchina.data.sci
ENV IP=0.0.0.0
ENV CHOWN=1
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
EXPOSE 8888 8787 80 22
# config file
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/

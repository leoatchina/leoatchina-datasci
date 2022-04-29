FROM ubuntu:20.04
MAINTAINER leoatchina,leoatchina@outlook.com
ADD sources.list /etc/apt/sources.list
RUN apt update -y && apt upgrade -y && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN apt install -y wget curl net-tools iputils-ping locales nginx \
    unzip bzip2 apt-utils screen \
    git htop xclip cmake sudo tree jq \
    software-properties-common \
    build-essential gfortran automake bash-completion \
    libapparmor1 libedit2 libc6 \
    psmisc rrdtool libzmq3-dev \
    libtool apt-transport-https libevent-dev language-pack-zh-hans && \
    locale-gen en_US.UTF-8 && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN add-apt-repository ppa:ubuntugis/ppa -y && \
    apt update -y && \
    apt install -y bioperl libdbi-perl \
    supervisor gdebi-core \
    openssh-server python2.7-dev \
    libjansson-dev libcairo2-dev libxt-dev librdf0 librdf0-dev \
    libv8-3.14-dev libudunits2-dev libproj-dev \
    gdal-bin proj-bin \
    libgdal-dev libgeos-dev libclang-dev cscope libncurses5-dev -y && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# ctags && cscope && gtags
RUN cd /tmp && \
    curl https://github.com//universal-ctags/ctags/archive/refs/tags/p5.9.20210822.0.tar.gz -o ctags.tar.gz && \
    tar xzf ctags.tar.gz && cd ctags*  && ./autogen.sh && ./configure --prefix=/usr && make && make install && \
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && cd libiconv-1.16 && ./configure --prefix=/usr && make && make install && \
    cd /tmp && \
    curl https://www.openssl.org/source/openssl-1.1.0l.tar.gz -o openssl.tar.gz && \
    tar xzf openssl.tar.gz && cd openssl-1.1.0l && ./config --prefix=/usr && make && make install && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/' && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
    apt update -y && apt upgrade -y && \
    apt install -y r-base-dev r-base r-base-core r-recommended && \
    apt install -y openjdk-8-jdk xvfb libswt-gtk-4-java && \
    R CMD javareconf && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /tmp && \
    curl https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.4.1717-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
ENV PATH=/opt/miniconda3/bin:$PATH
RUN cd /tmp && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3.sh && \
    bash miniconda3.sh -b -p /opt/miniconda3 && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && \
    conda clean -a -y
RUN conda install -n base -c conda-forge mamba && \
    mamba install -n base -c conda-forge git tmux xeus-python time libxml2 libxslt libssh2 krb5 ripgrep zsh bat jupyterlab nodejs yarn ranger-fm && \
    ln -sf /opt/miniconda3/bin/rg     /usr/bin && \
    ln -sf /opt/miniconda3/bin/zsh    /usr/bin && \
    ln -sf /opt/miniconda3/bin/git    /usr/bin && \
    ln -sf /opt/miniconda3/bin/tmux   /usr/bin && \
    ln -sf /opt/miniconda3/bin/ranger /usr/bin && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && \
    conda clean -a -y
RUN apt install libx11-dev libxext-dev -y && \
    /opt/miniconda3/bin/pip install --no-cache-dir pynvim neovim-remote flake8 pygments python-language-server ueberzug && \
    /opt/miniconda3/bin/jupyter labextension install @jupyterlab/debugger && \
    /opt/miniconda3/bin/jupyter lab build && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && \
    conda clean -a -y
# vim
RUN apt install vim -y && \
    conda install -n base -c conda-forge vim && \
    ln -sf /opt/miniconda3/bin/vim /usr/bin && \
    cd /usr/local && \
    curl -L https://github.91chifun.workers.dev/https://github.com//neovim/neovim/releases/download/v0.5.1/nvim-linux64.tar.gz -o nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    ln -sf /usr/local/nvim-linux64/bin/nvim /usr/bin && \
    rm nvim-linux64.tar.gz && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/* && \
    conda clean -a -y
# code-server
RUN cd /tmp && \
    curl -L https://github.91chifun.workers.dev/https://github.com//cdr/code-server/releases/download/v3.12.0/code-server-3.12.0-linux-amd64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server-3.12.0-linux-amd64 /opt/code-server && \
    rm -rf /tmp/*.*
# configuration
RUN mkdir -p /etc/rstudio /opt/config /opt/log /opt/rc && chmod -R 755 /opt/config /opt/log
COPY .bashrc .inputrc .bash_profile .configrc /opt/rc/
## users ports and dirs and configs
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
EXPOSE 8888 8787 8686 8585
## config file
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/

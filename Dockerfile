FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
ADD sources.list /etc/apt/sources.list
RUN apt update -y && apt upgrade -y && \
    mkdir -p /root/.cpan && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN apt install -y wget curl net-tools iputils-ping locales  \
    unzip bzip2 apt-utils \
    tmux screen \
    git htop xclip cmake sudo tree jq \
    build-essential gfortran automake bash-completion \
    libapparmor1 libedit2 libc6 \
    psmisc rrdtool libzmq3-dev libtool apt-transport-https \
    && locale-gen en_US.UTF-8 && \
    apt install -y software-properties-common && \
    add-apt-repository ppa:ubuntugis/ppa -y && \
    apt update -y && \
    apt install -y bioperl libdbi-perl \
    supervisor \
    gdebi-core \
    openssh-server \
    libjansson-dev \
    libcairo2-dev libxt-dev \
    libv8-3.14-dev libudunits2-dev libproj-dev gdal-bin proj-bin libgdal-dev libgeos-dev libclang-dev && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
    #cpan -i Try::Tiny && \
# bash && ctags && cscope && gtags
RUN apt install cscope libncurses5-dev -y && \
    cd /tmp && \ 
    curl https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz -o bash-5.0.tar.gz && \
    tar xzf bash-5.0.tar.gz && cd bash-5.0 && ./configure && make && make install && \
    cd /tmp && \
    git clone --depth 1 https://github.com/universal-ctags/ctags.git && \
    cd ctags && ./autogen.sh && ./configure && make && make install && \
    cd /tmp && \
    curl http://ftp.vim.org/ftp/gnu/global/global-6.6.3.tar.gz -o global.tar.gz && \
    tar xzf global.tar.gz && cd global-6.6.3 && ./configure --with-sqlite3 && make && make install && \
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && cd libiconv-1.16 && ./configure && make && make install && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/' && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
    apt update -y && apt upgrade -y && \
    apt install -y r-base-dev r-base r-base-core && \
    apt install openjdk-8-jdk xvfb libswt-gtk-4-java -y && \
    R CMD javareconf && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.5033-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN apt update && \
    apt install -y language-pack-zh-hans && locale-gen zh_CN.UTF-8 && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
ADD .condarc /root
ENV PATH=/opt/miniconda3/bin:$PATH
RUN cd /tmp && \
    rm -f /bin/bash && ln -s /usr/local/bin/bash /bin/bash && \ 
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3.sh && \
    bash miniconda3.sh -b -p /opt/miniconda3 && \
    /opt/miniconda3/bin/pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple pynvim python-language-server neovim-remote flake8 pygments && \
    conda update -n base -c defaults conda pip && \
    conda install -n base -c conda-forge time libxml2 libxslt libssh2 krb5 ripgrep nodejs yarn lazygit jupyterlab=2.0.0 && \
    conda clean -a -y && \
    mkdir /opt/rc && \
    mv /opt/miniconda3/share/jupyter /opt/rc && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /tmp && \
    git clone --depth 1 https://github.com/vim/vim.git && \
    cd vim && \
    export LDFLAGS='-L/opt/miniconda3/lib -Wl,-rpath,/opt/miniconda3/lib' && \
    ./configure --with-features=huge \ 
      --enable-cscope \
      --enable-multibyte \
      --enable-python3interp=yes \
      --with-python3-config-dir=/opt/miniconda3/lib/python3.7/config-3.7m-x86_x64-linux-gnu \
      --prefix=/usr/local && \
    make -j16 && make install && \
    ln -s /usr/local/bin/vim /opt/miniconda3/bin/vim && \
    rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# nvim
RUN cd /usr/local && \
    curl -L https://github.com/neovim/neovim/releases/download/v0.4.3/nvim-linux64.tar.gz -o nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    rm nvim-linux64.tar.gz && \
    ln -s /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim

# coder server
RUN cd /tmp && \
    curl -L https://github.com/cdr/code-server/releases/download/2.1698/code-server2.1698-vsc1.41.1-linux-x86_64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server2.1698-vsc1.41.1-linux-x86_64 /opt/code-server && \
    rm -rf /tmp/*.*

# configuration
RUN mkdir -p /etc/rstudio /opt/config /opt/log && chmod -R 755 /opt/config /opt/log
COPY .bashrc .inputrc /opt/rc/
## users ports and dirs and configs
RUN echo "export.UTF-8" >> /etc/profilesource /etc/profile
RUN echo "export LC_ALL='C.UTF-8'" >> /etc/profile
ENV LANG C.UTF-8
ENV WKUID=1000
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

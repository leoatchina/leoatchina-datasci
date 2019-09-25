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
    cpan -i Try::Tiny && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# bash && ctags
RUN cd /tmp && \ 
    curl https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz -o bash-5.0.tar.gz && \
    tar xzf bash-5.0.tar.gz && \
    cd bash-5.0 && \
    ./configure && \
    make && \
    make install && \
    cd /tmp && \
    git clone --depth 1 https://github.com/universal-ctags/ctags.git && cd ctags && \
    ./autogen.sh && ./configure && make && make install && \
    cd /tmp && \
    curl http://ftp.vim.org/ftp/gnu/global/global-6.6.3.tar.gz -o global.tar.gz && \
    tar xzf global.tar.gz && cd global-6.6.3 && \
    ./configure --with-sqlite3 --disable-gtagscscope && make && make install && \
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && cd libiconv-1.16 && \
    ./configure && make && make install && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /tmp && \ 
    curl https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
ENV PATH=/opt/miniconda3/bin:$PATH
RUN cd /tmp && \
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda3.sh && \
    bash miniconda3.sh -b -p /opt/miniconda3 && \
    conda update -n base -c defaults conda && \
    /opt/miniconda3/bin/conda clean -a -y && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN 
    conda install neovim python-language-server flake8 pygments && \
    conda install -n base -c conda-forge r-base r-essentials libssh2 krb5 jupyterlab=1.1.4 vim ripgrep nodejs yarn && \
    apt install xvfb libswt-gtk-4-java -y && \
    /opt/miniconda3/bin/conda clean -a -y && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# nvim
RUN cd /usr/local && \
    curl -L https://github.com/neovim/neovim/releases/download/v0.4.2/nvim-linux64.tar.gz -o nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    rm nvim-linux64.tar.gz && \
    ln -s /usr/local/nvim-linux64/bin/nvim /usr/bin/nvim
# coder server
RUN cd /tmp && \
    curl -L https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server1.1156-vsc1.33.1-linux-x64 /opt/code-server && \
    rm -rf /tmp/*.*
# configuration
RUN mkdir -p /etc/rstudio /opt/config /opt/log /opt/rc && chmod -R 755 /opt/config /opt/log
COPY .bashrc .inputrc /root/
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && rm -rf /root/.fzf/.git && /root/.fzf/install --all && \
    mv /root/.bashrc /root/.inputrc /root/.fzf.bash /root/.fzf /opt/rc/
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
## share ports and dirs 
ENV WKUSER=datasci
ENV PASSWD=datasci
ENV WKUID=1000
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
EXPOSE 8888 8787 8443 8822

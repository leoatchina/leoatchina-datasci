FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
RUN apt update -y && apt upgrade -y && \
    apt install -y wget curl net-tools iputils-ping apt-transport-https openssh-server \
    unzip bzip2 apt-utils gdebi-core tmux \
    git htop supervisor xclip cmake sudo \
    libapparmor1 libcurl4-openssl-dev libxml2 libxml2-dev libssl-dev libncurses5-dev libncursesw5-dev libjansson-dev \
    build-essential gfortran libcairo2-dev libxt-dev automake bash-completion \
    libapparmor1 libedit2 libc6 psmisc rrdtool libzmq3-dev libtool software-properties-common \
    bioperl libdbi-perl tree jq \ 
    locales && locale-gen en_US.UTF-8 && \
    cpan -i Try::Tiny && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# bash && ctags
RUN cd /tmp && \ 
    curl https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz -o bash-5.0.tar.gz && \
    tar xzf bash-5.0.tar.gz && \
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
    tar xzf global.tar.gz && cd global-6.6.3 && \
    ./configure --with-sqlite3 && make && make install && \
    cd /tmp && \
    curl https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && cd libiconv-1.16 && \
    ./configure && make && make install && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# R
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/' && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
    add-apt-repository ppa:ubuntugis/ppa -y && \
    apt update -y && \
    apt upgrade -y && \
    apt install -y r-base-dev r-base r-base-core  && \
    apt install -y libv8-3.14-dev libudunits2-dev libgdal1i libgdal1-dev libproj-dev gdal-bin proj-bin libgdal-dev libgeos-dev libclang-dev && \
    apt install openjdk-8-jdk xvfb libswt-gtk-4-java -y && \
    R CMD javareconf && \
    cd /tmp && \ 
    curl https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
# anaconda3
ENV PATH=/opt/anaconda3/bin:$PATH
RUN cd /tmp && \
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2019.07-Linux-x86_64.sh -o anaconda.sh && \
    bash anaconda.sh -b -p /opt/anaconda3 && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple pyqt5==5.12 pyqtwebengine==5.12 && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple neovim python-language-server flake8 dash && \
    /opt/anaconda3/bin/conda clean -a -y && \
    apt autoremove && apt clean && apt purge && rm -rf /tmp/* /var/tmp/* /root/.cpan/*
RUN cd /usr/local && \
    curl -L https://github.com/neovim/neovim/releases/download/v0.3.8/nvim-linux64.tar.gz -o nvim-linux64.tar.gz && \
    tar xzf nvim-linux64.tar.gz && \
    rm nvim-linux64.tar.gz && \
    ln -s /usr/local/nvim-linux64/bin/nvim /usr/bin/vim
# coder server
RUN cd /tmp && \
    curl -L https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server1.1156-vsc1.33.1-linux-x64 /opt/code-server && \
    rm -rf /tmp/*.*
# configuration
RUN mkdir -p /etc/rstudio /opt/config /opt/log /opt/rc && chmod -R 755 /opt/config /opt/log
COPY .bashrc .inputrc /root/
COPY rserver.conf /etc/rstudio/
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && rm -rf /root/.fzf/.git
RUN /root/.fzf/install --all
RUN mv /root/.bashrc /root/.inputrc /root/.fzf.bash /root/.fzf /opt/rc/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
## share ports and dirs 
ENV WKUSER=datasci
ENV PASSWD=datasci
ENV WKUID=1000
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
EXPOSE 8888 8787 8443 8822

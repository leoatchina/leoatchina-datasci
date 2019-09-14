FROM ubuntu:16.04
MAINTAINER leoatchina,leoatchina@gmail.com
RUN sed -i 's/archive.ubuntu/mirrors.163/g' /etc/apt/sources.list 
# @todo: install the software neeeded by nvida/cuda 
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
RUN conda update -n base -c defaults conda && \
    conda install -y -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge jupyterlab=1.1.3 && \
    curl -sL https://deb.nodesource.com/setup_10.x |  bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && apt upgrade -y && apt install nodejs yarn -y && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install ipysheet && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab-drawio && \ 
    jupyter labextension install jupyterlab-kernelspy && \
    jupyter labextension install jupyterlab-spreadsheet && \ 
    jupyter labextension install @mflevine/jupyterlab_html && \ 
    jupyter labextension install @krassowski/jupyterlab_go_to_definition && \ 
    jupyter labextension install @telamonian/theme-darcula && \
    jupyter labextension install @mohirio/jupyterlab-horizon-theme && \
    jupyter lab build && \
    mkdir -p /opt/rc && mv /opt/anaconda3/share/jupyter /opt/rc && \
    conda clean -a -y && \
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
# fzf 
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && rm -rf /root/.fzf/.git
# configuration
COPY .bashrc .inputrc /root/
RUN /root/.fzf/install --all
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
    echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
RUN mv /root/.bashrc /root/.inputrc /root/.fzf.bash /root/.fzf /opt/rc/
RUN mkdir -p /etc/rstudio /opt/config /opt/log  && chmod -R 755 /opt/config /opt/log
COPY rserver.conf /etc/rstudio/
# @todo, use entrypoint/supervisor to create user of current, and run jupyterlab, codeserver as current user
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
## share ports and dirs 
ENV WKUSER=datasci
ENV PASSWD=datasci
ENV WKUID=1000
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
EXPOSE 8888 8787 8443 8822

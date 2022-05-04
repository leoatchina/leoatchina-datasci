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
      vim rsync gdebi-core python2.7-dev git ripgrep zsh locate bison flex && \
    apt install -y --fix-missing \
      gdal-bin proj-bin psmisc rrdtool libzmq3-dev \
      libjansson-dev libcairo2-dev libxt-dev librdf0 librdf0-dev \
      libudunits2-dev libproj-dev libapparmor1 libedit2 libc6 apt-transport-https \
      libtool libevent-dev \
      libx11-dev libxext-dev \
      libgdal-dev libgeos-dev \
      libclang-dev cscope libncurses5-dev && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

# neovim ctags gtags tmux
RUN cd /tmp && \
    git clone --depth=1 https://gitclone.com/github.com/universal-ctags/ctags.git && cd ctags && \
    ./autogen.sh && ./configure --prefix=/usr && make && make install && \
    cd /tmp && \
    git clone --depth=1 https://gitclone.com/github.com/tmux/tmux.git && cd tmux && \
    ./autogen.sh && ./configure --prefix=/usr && make && make install && \
    cd /tmp && \
    curl -L https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz -o libiconv.tar.gz && \
    tar xzf libiconv.tar.gz && \
    cd libiconv-1.16 && ./configure --prefix=/usr && make && make install && \
    cd /tmp && \
    curl -L https://www.openssl.org/source/openssl-1.1.1n.tar.gz -o openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd openssl-1.1.1n && ./config --prefix=/usr && make && make install && \
    cd /tmp && \
    curl -L https://ftp.gnu.org/pub/gnu/global/global-6.6.8.tar.gz -o global.tar.gz && \
    tar xzf global.tar.gz && \
    cd global-6.6.8 && ./configure --prefix=/usr --with-sqlite3 && make && make install && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

# config dirs
RUN mkdir -p /opt/config /opt/log /opt/rc && chmod -R 755 /opt/config /opt/log

# code-server
RUN cd /tmp && \
    curl -L https://github.do/https://github.com/coder/code-server/releases/download/v4.3.0/code-server-4.3.0-linux-amd64.tar.gz -o code-server.tar.gz && \
    tar xzf code-server.tar.gz && \
    mv code-server-4.3.0-linux-amd64 /opt/code-server && \
    rm -rf /tmp/*.*
ENV PASSWD=datasci
EXPOSE 8080
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
COPY entrypoint.sh /opt/config/

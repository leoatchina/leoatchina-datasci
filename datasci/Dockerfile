FROM leoatchina/ubuntu20.04
RUN apt install -y openssh-server nginx bioperl libdbi-perl && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

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


# configuration
COPY .bashrc .inputrc .bash_profile .configrc /opt/rc/
RUN mkdir -p /etc/rstudio
# users ports and dirs and configs
RUN echo "export LC_ALL='C.UTF-8'" >> /etc/profile
ENV LANG C.UTF-8
ENV COUNTRY=CN
ENV PROVINCE=ZJ
ENV CITY=HZ
ENV ORGANIZE=SELF
ENV WEB=leatchina.data.sci
ENV IP=0.0.0.0
ENV CHOWN=1

EXPOSE 8888 8787 8080 22
ENTRYPOINT ["bash", "/opt/config/entrypoint.sh"]
# config file
COPY rserver.conf /etc/rstudio/
COPY jupyter_lab_config.py supervisord.conf passwd.py entrypoint.sh /opt/config/
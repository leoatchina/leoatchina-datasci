FROM leoatchina/ubuntu20.04

RUN apt install -y supervisor openssh-server nginx bioperl libdbi-perl && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' && \
    apt update -y && apt upgrade -y && \
    apt install -y r-base-dev r-base r-base-core r-recommended && \
    apt install -y openjdk-8-jdk xvfb libswt-gtk-4-java && \
    R CMD javareconf && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

RUN cd /tmp && \
    curl https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.07.2-576-amd64.deb -o rstudio.deb && \
    gdebi -n rstudio.deb && \
    apt autoremove -y && apt clean -y && apt purge -y && rm -rf /tmp/* /var/tmp/* /root/.cpan/*

# configuration
COPY .bashrc .inputrc .bash_profile .configrc .condarc /opt/rc/
RUN mkdir -p /etc/rstudio
# users ports and dirs and configs
RUN echo "export LC_ALL='C.UTF-8'" >> /etc/profile
ENV WKUSER=datasci
ENV LANG C.UTF-8
ENV COUNTRY=CN
ENV PROVINCE=ZJ
ENV CITY=HZ
ENV ORGANIZE=SELF
ENV WEB=leatchina.datasci
ENV IP=0.0.0.0
ENV CHOWN=1
EXPOSE 8787 8080 22
# config file
COPY rserver.conf /etc/rstudio/
COPY supervisord.conf entrypoint.sh /opt/config/

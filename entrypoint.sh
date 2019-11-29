#!/bin/sh
# check name 
if [[ $WKUSER == root ]]; then
    echo "WKUSER must not be root"
    exit 1
fi
if [ $WKUID -lt 1000 ]; then
    echo "WKUID must not be less than 1000"
    exit 1
fi

if [ ! -n "${WKGID+1}" ]; then
    WKGID=$WKUID
fi

if [ $WKGID -lt 1000 ]; then
    echo "WKGID must not be less than 1000"
    exit 1
fi

# set config files
cp -n /opt/rc/.bashrc /opt/rc/.inputrc root/
cp -n /opt/rc/.bashrc /opt/rc/.inputrc /home/$WKUSER/
chown $WKUID:$WKGID /home/$WKUSER/.bashrc /home/$WKUSER/.inputrc

# rsync jupyter back
rsync -rvh -u /opt/rc/jupyter /opt/miniconda3/share
for d in $(find /opt/miniconda3/share/jupyter -type d); do chmod 777 $d; done
for f in $(find /opt/miniconda3/share/jupyter -type f); do chmod 666 $f; done

# user set
groupadd $WKUSER -g $WKGID
useradd $WKUSER -u $WKUID -g $WKGID -m -d /home/$WKUSER -s /bin/bash -p $WKUSER
chown -R $WKUSER:$WKUSER /home/$WKUSER/
echo $WKUSER:$PASSWD | chpasswd
[[ -v ROOTPASSWD ]] && echo root:$ROOTPASSWD | chpasswd || echo root:$PASSWD | chpasswd

# set ssl encyption
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/config/jupyterlab.key -out /opt/config/jupyterlab.csr -subj "/C=GB/ST=ZHEJIANG/L=HANGZHOU/O=Global Security/OU=IT Department/CN=jupyterlab"
# @todo solve https
chmod 666 /opt/config/jupyterlab.key
chmod 666 /opt/config/jupyterlab.csr

# config privilege 
chmod 777 /root /opt/miniconda3/pkgs
rm -rf /opt/miniconda3/pkgs/*

# Rstudio-server
echo "Sys.setenv(PATH='/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/opt/miniconda3/bin')" >> /usr/lib/rstudio-server/R/ServerOptions.R

# sshd server 
mkdir -p /var/run/sshd
rm -r /etc/ssh/ssh*key
sed -i 's/Port 22/Port 8585/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
dpkg-reconfigure openssh-server 

# code-server
echo "[program:code-server]" >>/opt/config/supervisord.conf
export PASSWORD=$PASSWD
echo "command=/opt/code-server/code-server /home/$WKWUSER --auth password --host 0.0.0.0 --port 8686 --cert /opt/config/jupyterlab.csr --cert-key /opt/config/jupyterlab.key \
 --locale en-US \
 --extensions-dir /home/$WKUSER/.config/vscode/extensions \
 --user-data-dir  /home/$WKUSER/.config/vscode/config">>/opt/config/supervisord.conf
echo "user=$WKUSER" >>/opt/config/supervisord.conf
echo "stdout_logfile = /opt/log/code-server.log" >>/opt/config/supervisord.conf

# jupyter config
SHA1=$(/opt/miniconda3/bin/python /opt/config/passwd.py $PASSWD)
echo "c.ContentsManager.root_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py
echo "c.NotebookApp.notebook_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py  # Notebook启动目录
echo "c.NotebookApp.password = '$SHA1'" >> /opt/config/jupyter_lab_config.py

unset ROOTPASSWD
unset PASSWD

echo ""
echo "========================= starting services with USER $WKUSER whose UID is $WKUID ================================"
# rstudio
systemctl enable rstudio-server
service rstudio-server restart
# start with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

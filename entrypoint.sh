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

# user set
groupadd $WKUSER -g $WKGID
useradd $WKUSER -u $WKUID -g $WKGID -m -d /home/$WKUSER -s /bin/bash -p $WKUSER
echo $WKUSER:$PASSWD | chpasswd
[[ -v ROOTPASSWD ]] && echo root:$ROOTPASSWD | chpasswd || echo root:$PASSWD | chpasswd
if [ $CHOWN -gt 0 ]; then
    chown -R $WKUSER:$WKUSER /home/$WKUSER/
    for d in $(find /opt/miniconda3/share/jupyter -type d); do chmod 777 $d; done
    for f in $(find /opt/miniconda3/share/jupyter -type f); do chmod 666 $f; done
fi

# set ssl encyption
mkdir /opt/ssl
rm -rf /opt/ssl/*.*
## create for all
openssl genrsa -out "/opt/ssl/jupyterlab.key" 4096
openssl req -new -key "/opt/ssl/jupyterlab.key" -out "/opt/ssl/jupyterlab.csr" -sha256 \
    -subj "/C=$COUNTRY/ST=$PROVINCE/L=$CITY/O=$ORGANIZE/CN=$WEB"
cat > /opt/ssl/jupyterlab.cnf << EOF
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOF
openssl x509 -req -days 3650 -in "/opt/ssl/jupyterlab.csr" -signkey "/opt/ssl/jupyterlab.key" \
    -sha256 -out "/opt/ssl/jupyterlab.crt" -extfile "/opt/ssl/jupyterlab.cnf" \
    -extensions root_ca

## create for web
openssl genrsa -out "/opt/ssl/${WEB}.key" 4096
openssl req -new -key "/opt/ssl/${WEB}.key" -out "/opt/ssl/${WEB}.csr" -sha256 -subj "/C=$COUNTRY/ST=$PROVINCE/L=$CITY/O=$ORGANIZE/CN=$WEB"

cat > /opt/ssl/${WEB}.cnf << EOF
[server]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
extendedKeyUsage=serverAuth
keyUsage = critical, digitalSignature, keyEncipherment
subjectAltName = DNS:${WEB}, IP:${IP}
subjectKeyIdentifier=hash
EOF
openssl x509 -req -days 3600 -in "/opt/ssl/${WEB}.csr" -sha256 -CA "/opt/ssl/jupyterlab.crt" -CAkey "/opt/ssl/jupyterlab.key" \
    -CAcreateserial -out "/opt/ssl/${WEB}.crt" -extfile "/opt/ssl/${WEB}.cnf" -extensions server

chmod 666 /opt/ssl/*.*

# privilege 
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
echo "command=/opt/code-server/code-server /home/$WKWUSER \
--auth password \
--port 8686 \
--host 0.0.0.0 \
--cert /opt/ssl/${WEB}.crt \
--cert-key /opt/ssl/${WEB}.key \
--user-data-dir /home/$WKUSER/.config/vscode/config \
--extensions-dir /home/$WKUSER/.config/vscode/extensions \
--locale en-US">>/opt/config/supervisord.conf
echo "user=$WKUSER" >>/opt/config/supervisord.conf
echo "stdout_logfile = /opt/log/code-server.log" >>/opt/config/supervisord.conf

# jupyter config
chmod 666 /opt/config/jupyter_lab_config.py
SHA1=$(/opt/miniconda3/bin/python /opt/config/passwd.py $PASSWD)
echo "c.ContentsManager.root_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py
echo "c.NotebookApp.notebook_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py  # Notebook启动目录
echo "c.NotebookApp.password     = '$SHA1'" >> /opt/config/jupyter_lab_config.py

unset ROOTPASSWD
unset PASSWD

echo ""
echo "========================= starting services with USER $WKUSER whose UID is $WKUID ================================"
# rstudio
systemctl enable rstudio-server
service rstudio-server restart
# start with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

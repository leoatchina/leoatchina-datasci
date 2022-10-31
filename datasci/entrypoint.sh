#!/bin/sh
# check name
if [[ $WKUSER == root ]]; then
    echo "WKUSER must not be root"
    exit 1
fi
if [ -n "${WKUID+1}" ];then
    echo "WKUID is $WKUID"
else
		WKUID=$UID
    echo "WKUID is set to $WKUID"
fi
if [ $WKUID -lt 1000 ]; then
    echo "WKUID must not be less than 1000"
    exit 1
fi

if [ ! -n "${WKGID+1}" ]; then
    WKGID=$WKUID
fi
if [ $WKGID -lt 0 ]; then
    echo "WKGID must not be less than 0"
    exit 1
fi

# user set
groupadd $WKUSER -g $WKGID
useradd $WKUSER -u $WKUID -g $WKGID -m -d /home/$WKUSER -s /bin/bash -p $WKUSER
echo $WKUSER:$PASSWD | chpasswd
[[ -v ROOTPASSWD ]] && echo root:$ROOTPASSWD | chpasswd || echo root:$PASSWD | chpasswd

# set config files
cp -n /opt/rc/.bashrc /opt/rc/.configrc /opt/rc/.inputrc /opt/rc/.bash_profile /root/
cp -n /opt/rc/.bashrc /opt/rc/.configrc /opt/rc/.inputrc /opt/rc/.bash_profile /home/$WKUSER/
chown $WKUID:$WKGID /home/$WKUSER /home/$WKUSER/.bashrc /home/$WKUSER/.inputrc /home/$WKUSER/.bash_profile

# THREADS
export THREADS=`grep proc /proc/cpuinfo | wc -l`
echo "============================== This server has $THREADS threads ========================================="
if [ $CHOWN -gt 0 ]; then
    echo "Changing the ownership of the mapped home dir to $WKUSER, it may cost long time, please wait."
    find /home/$WKUSER -print0 | xargs -0 -P $THREADS -i chown -R $WKUSER:$WKUSER {}
fi

# set ssl encyption
mkdir -p /opt/ssl
rm -rf /opt/ssl/*.*
# create ssl config key
openssl genrsa -out "/opt/ssl/datasci.key" 4096
openssl req -new -key "/opt/ssl/datasci.key" -out "/opt/ssl/datasci.csr" -sha256 \
    -subj "/C=$COUNTRY/ST=$PROVINCE/L=$CITY/O=$ORGANIZE/CN=$WEB"
cat > /opt/ssl/datasci.cnf << EOF
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOF
openssl x509 -req -days 3650 -in "/opt/ssl/datasci.csr" -signkey "/opt/ssl/datasci.key" \
    -sha256 -out "/opt/ssl/datasci.crt" -extfile "/opt/ssl/datasci.cnf" \
    -extensions root_ca

# create key  for web
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
openssl x509 -req -days 3600 -in "/opt/ssl/${WEB}.csr" -sha256 -CA "/opt/ssl/datasci.crt" -CAkey "/opt/ssl/datasci.key" \
    -CAcreateserial -out "/opt/ssl/${WEB}.crt" -extfile "/opt/ssl/${WEB}.cnf" -extensions server
chmod 666 /opt/ssl/*.*

# Rstudio-server
mkdir -p /usr/lib/rstudio-server/R
echo "Sys.setenv(PATH='/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/opt/miniconda3/bin')" >> /usr/lib/rstudio-server/R/ServerOptions.R
# sshd server, allow x11 forword
mkdir -p /var/run/sshd
rm -r /etc/ssh/ssh*key
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config
echo 'X11UseLocalhost no' >> /etc/ssh/sshd_config
dpkg-reconfigure openssh-server

# code-server
echo "export PASSWORD=$PASSWD" > /opt/config/start-codeserver.sh
echo "/opt/code-server/code-server /home/$WKUSER \
--auth password \
--port 8080 \
--host 0.0.0.0 \
--user-data-dir /home/$WKUSER/.config/code-server/config \
--extensions-dir /home/$WKUSER/.config/code-server/extensions \
--locale en-US">>/opt/config/start-codeserver.sh
chmod 777 /opt/config/start-codeserver.sh

echo "[program:codeserver]" >> /opt/config/supervisord.conf
echo "autostart=true" >> /opt/config/supervisord.conf
echo "command=su - $WKUSER -c '/bin/bash /opt/config/start-codeserver.sh'" >> /opt/config/supervisord.conf

unset ROOTPASSWD
unset PASSWD

echo ""
echo "========================= starting services with USER $WKUSER whose UID is $WKUID ================================"
# rstudio-server
systemctl enable rstudio-server
service rstudio-server restart
# start sshd with supervisor and codeserver
/usr/bin/supervisord -c /opt/config/supervisord.conf

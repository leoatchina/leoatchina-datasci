#!/bin/sh
SHA1=$(python /opt/config/passwd.py $PASSWD)

echo "c.NotebookApp.password = '$SHA1'">>/opt/config/jupyter_lab_config.py
echo rserver:$PASSWD | chpasswd

/usr/bin/supervisord -c /opt/config/supervisord.conf

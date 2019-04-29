#!/bin/sh
SHA1=$(python /opt/config/passwd.py $PASSWD)
# passwd for jupyter
echo "c.NotebookApp.password = '$SHA1'">>/opt/config/jupyter_lab_config.py
# passwd for rserver
echo rserver:$PASSWD | chpasswd
# passwd for code-server
echo "command=/opt/code-server/code-server -P '$PASSWD' -d /jupyter/.config/.vscode -e /root/.config/.vscode-extentions">>/opt/config/supervisord.conf
/usr/bin/supervisord -c /opt/config/supervisord.conf

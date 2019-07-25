#!/bin/sh
# cp config files
if [[ $WKUSER == root ]]; then
    echo "WKUSER must not be root"
    exit 1
fi
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /root/
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /home/$WKUSER/
rsync -rvh --update /opt/rc/jupyter/ /opt/anaconda3/share/jupyter/   # the custom files position

adduser $WKUSER
echo $WKUSER:$PASSWD | chpasswd
echo root:$PASSWD | chpasswd

# config privilege 
chmod 777 /root /opt/anaconda3/pkgs
find /opt/anaconda3/share/jupyter/ -type d | xargs chmod 777
chown -R $WKUSER:$WKUSER /home/$WKUSER/
chmod 755 /home/$WKUSER
for d in $(find /root -maxdepth 1 -name ".*" -type d); do find $d -type d | xargs chmod 777 ; done
for d in $(find /home/$WKUSER -maxdepth 1 -name ".*" -type d); do chown -R $WKUSER $d ; done

# sshd server 
mkdir -p /var/run/sshd
sed -i 's/Port 22/Port 8822/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# jupyter
SHA1=$(/opt/anaconda3/bin/python /opt/config/passwd.py $PASSWD)
echo "c.ContentsManager.root_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py
echo "c.NotebookApp.notebook_dir = '/home/$WKUSER'" >> /opt/config/jupyter_lab_config.py  # Notebook启动目录
echo "c.NotebookApp.password = '$SHA1'" >> /opt/config/jupyter_lab_config.py
echo "user=$WKUSER" >>/opt/config/supervisord.conf
echo -e "\n" >>/opt/config/supervisord.conf

# code-server
echo "[program:code-server]" >>/opt/config/supervisord.conf
echo "command=/opt/code-server/code-server /home/$WKUSER -P '$PASSWD' -d /home/$WKUSER/.config/.vscode -e /home/$WKUSER/.config/.vscode-extentions">>/opt/config/supervisord.conf
echo "user=$WKUSER" >>/opt/config/supervisord.conf
echo "stdout_logfile = /opt/log/code-server.log" >>/opt/config/supervisord.conf

# start server with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

#!/bin/sh
# cp config files
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /root/
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /home/$USER/
rsync -rvh --update /opt/rc/jupyter/ /opt/anaconda3/share/jupyter/   # the custom files position

# config 777
chmod -R 777 /root
mkdir -p /home/$USER/.local/share/jupyter/runtime
chown -R $USER:$USER /home/$USER/.local
mkdir -p /home/$USER/.cache/code-server
chown -R $USER:$USER /home/$USER/.cache
mkdir -p /home/$USER/.config
chown -R $USER:$USER /home/$USER/.config

# sshd server 
mkdir -p /var/run/sshd
sed -i 's/Port 22/Port 8822/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# add USER
useradd $USER -d /home/$USER 
echo $USER:$PASSWD | chpasswd
echo root:$PASSWD | chpasswd

# jupyter
SHA1=$(/opt/anaconda3/bin/python /opt/config/passwd.py $PASSWD)
echo "c.NotebookApp.notebook_dir = u'/home/$USER'" >> /opt/config/jupyter_lab_config.py  # Notebook启动目录
echo "c.NotebookApp.password = '$SHA1'">>/opt/config/jupyter_lab_config.py
echo "user=$USER" >>/opt/config/supervisord.conf

# code-server
echo "[program:code-server]" >>/opt/config/supervisord.conf
echo "command=/opt/code-server/code-server /home/$USER -P '$PASSWD' -d /home/$USER/.config/.vscode -e /home/$USER/.config/.vscode-extentions">>/opt/config/supervisord.conf
echo "user=$USER" >>/opt/config/supervisord.conf
echo "stdout_logfile = /opt/log/code-server.log" >>/opt/config/supervisord.conf

# start server with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

#!/bin/sh
# cp config files
if [[ $USER == root ]]; then
    echo "USER must not be root"
    exit 1
fi
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /root/
cp -R /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /opt/rc/.fzf /home/$USER/
rsync -rvh --update /opt/rc/jupyter/ /opt/anaconda3/share/jupyter/   # the custom files position

# add USER
adduser $USER
echo $USER:$PASSWD | chpasswd
echo root:$PASSWD | chpasswd

# config privilege 
chmod  777 /root
find /opt/anaconda3/share/jupyter/ -type d | xargs chmod 777
chown -R $USER:$USER /home/$USER/

# sshd server 
mkdir -p /var/run/sshd
sed -i 's/Port 22/Port 8822/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# jupyter
SHA1=$(/opt/anaconda3/bin/python /opt/config/passwd.py $PASSWD)
echo "c.ContentsManager.root_dir = '/home/$USER'" >> /opt/config/jupyter_lab_config.py
echo "c.NotebookApp.notebook_dir = '/home/$USER'" >> /opt/config/jupyter_lab_config.py  # Notebook启动目录
echo "c.NotebookApp.password = '$SHA1'" >> /opt/config/jupyter_lab_config.py
echo "user=$USER" >>/opt/config/supervisord.conf
echo -e "\n" >>/opt/config/supervisord.conf

# code-server
echo "[program:code-server]" >>/opt/config/supervisord.conf
echo "command=/opt/code-server/code-server /home/$USER -P '$PASSWD' -d /home/$USER/.config/.vscode -e /home/$USER/.config/.vscode-extentions">>/opt/config/supervisord.conf
echo "user=$USER" >>/opt/config/supervisord.conf
echo "stdout_logfile = /opt/log/code-server.log" >>/opt/config/supervisord.conf

# start server with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

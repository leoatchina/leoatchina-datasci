#!/bin/sh
# check name 
if [[ $WKUSER == root ]]; then
    echo "WKUSER must not be root"
    exit 1
fi
if [ $WKUID -lt 1000 ]; then
    echo "WKUID must be greater than 999"
    exit 1
fi
# set config files
cp /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /root/
cp -R /opt/rc/.fzf /root/
cp /opt/rc/.bashrc /opt/rc/.inputrc /opt/rc/.fzf.bash /home/$WKUSER/
cp -R /opt/rc/.fzf /home/$WKUSER
# rsync for jupyterlab
rsync -rvh --update /opt/rc/jupyter/ /opt/anaconda/share/jupyter/

# user set
useradd $WKUSER -u $WKUID -m -d /home/$WKUSER -s /bin/bash -p $WKUSER
chown -R $WKUSER:$WKUSER /home/$WKUSER/
echo $WKUSER:$PASSWD | chpasswd
[[ -v ROOTPASSWD ]] && echo root:$ROOTPASSWD | chpasswd || echo root:$PASSWD | chpasswd
unset ROOTPASSWD

# config privilege 
chmod 777 /root /opt/anaconda/pkgs
find /opt/anaconda/share/jupyter/ -type d | xargs chmod 777
for d in $(find /root -maxdepth 1 -name ".*" -type d); do find $d -type d | xargs chmod 777 ; done
for d in $(find /root -maxdepth 1 -name ".*" -type d); do find $d -type f | xargs chmod 666 ; done
for d in $(find /home/$WKUSER -maxdepth 1 -name ".*"); do chown -R $WKUSER:$WKUSER $d ; done

# sshd server 
mkdir -p /var/run/sshd
rm -r /etc/ssh/ssh*key
sed -i 's/Port 22/Port 8822/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
dpkg-reconfigure openssh-server 

# jupyter
SHA1=$(/opt/anaconda/bin/python /opt/config/passwd.py $PASSWD)
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

echo ""
echo "========================= starting services with USER $WKUSER whose UID is $WKUID ================================"
# rstudio
systemctl enable rstudio-server
service rstudio-server restart
# start with supervisor
/usr/bin/supervisord -c /opt/config/supervisord.conf

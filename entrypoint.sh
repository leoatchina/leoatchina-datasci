# code-server
echo "export PASSWORD=$PASSWD" > /opt/config/start-codeserver.sh
echo "/opt/code-server/code-server /root \
--auth password \
--port 8080 \
--host 0.0.0.0 \
--user-data-dir /root/.config/code-server/config \
--extensions-dir /root/.config/code-server/extensions \
--locale en-US" >> /opt/config/start-codeserver.sh
unset PASSWD
bash /opt/config/start-codeserver.sh

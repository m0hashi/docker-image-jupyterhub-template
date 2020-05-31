UNAME=$1
PW=`openssl rand -base64 14`
#adduser $UNAME && \
useradd -m -g jupyterhub $UNAME -s /bin/bash&& \
echo "${UNAME}:${PW}" | sudo  chpasswd  && \
echo "ユーザ作成に成功しました. パスワードは

${PW}

です。以下のコマンドでユーザを切り替えてください

su - ${UNAME}" && \
runuser -l ${UNAME} -c "mkdir ~/.ssh  && chmod -R 600 .ssh && \
echo 'PATH=/opt/conda/bin/:$PATH' >> ~/.bashrc && \
echo '. /opt/conda/etc/profile.d/conda.sh' >> ~/.bashrc && \
echo 'conda activate base' >> ~/.bashrc 
"
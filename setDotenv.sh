#!/bin/bash
if [ ! -d "./data/nginx" ]; then
  echo 'nginx'
  mkdir -p ./data/nginx
fi
if [ ! -f ".env" ]; then
  touch .env
  echo 'JUPYTERHUB_FQDN=wwww.example.com' >> .env
fi
source .env 
JUPYTERHUB_FQDN=$JUPYTERHUB_FQDN #$JUPYTERHUB_FQDN is defined in .env
cat ./data/templates/app.conf | sed s/JUPYTERHUB_FQDN/$JUPYTERHUB_FQDN/g > ./data/nginx/app.conf

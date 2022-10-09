#!/bin/bash

source /home/deploy/.bashrc
read -e -p "Enter the domain of the deploy: " DOMAIN

# nginx (allow acces to port 80)
sudo apt install nginx -y
sudo ufw allow 80
cd /etc/nginx/sites-available
sudo rm default
read -e -p "Enter the project name (example piupiuwer): " PROJECT_NAME
read -e -p "Enter the app port: " APP_PORT
sudo touch $PROJECT_NAME
echo "server {
  listen 80 default_server;
  listen [::]:80 default_server;

  server_name $DOMAIN;

  location / {
    proxy_pass http://localhost:$APP_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }
}" | sudo tee -a $PROJECT_NAME
cd ../sites-enabled
sudo rm default
sudo ln -s /etc/nginx/sites-available/$PROJECT_NAME $PROJECT_NAME
sudo service nginx reload
sudo service nginx restart

# restart docker container on server problems unless it is directly stopped
sudo docker update --restart=unless-stopped $CONTAINER_ID

# start app with pm2
npm install -g pm2
cd /home/deploy/$DIR_NAME
pm2 start dist/shared/infra/http/server.js
COMMAND=$(pm2 startup systemd)
echo $COMMAND | grep sudo | bash

# configure the ssl
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
echo "Enter your polijunior email, yes twice and then the press enter on the domain"
sudo certbot --nginx
sudo ufw allow 443

# the end
echo "The deploy is ready! :)"

exit
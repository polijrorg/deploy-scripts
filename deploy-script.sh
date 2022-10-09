#!/bin/bash

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc

# install node
nvm install node
node -v

source ~/.bashrc

# install yarn
curl -o- -L https://yarnpkg.com/install.sh | bash
source ~/.bashrc
yarn -v

# cloning backend repo
read -e -p "Enter the backend repo link: " REPO_LINK
git clone $REPO_LINK
DIR_NAME=$(echo $REPO_LINK | sed -E 's/.*\///g')
cd $DIR_NAME

# install dependencies and build
yarn
yarn build

# change permissions to use docker
sudo usermod -aG docker $USER
bash

# create and run docker container
read -e -p "Enter the new postgresql username: " POSTGRESQL_USERNAME
read -e -p "Enter the new postgresql password: " POSTGRESQL_PASSWORD
read -e -p "Enter the new postgresql database name: " POSTGRESQL_DATABASE
read -e -p "Enter the new postgresql database port: " POSTGRESQL_PORT
CONTAINER_ID=$(docker run -d --name postgresql -e POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD -e POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME -e POSTGRESQL_DATABASE=$POSTGRESQL_DATABASE -p $POSTGRESQL_PORT:5432 bitnami/postgresql:latest)

# create .env
read -e -p "Enter the app port: " APP_PORT
UUID=$(uuidgen)
touch .env
echo "PORT=$APP_PORT\nTOKEN_HASH=$UUID\nDATABASE_URL=\"postgresql://$POSTGRESQL_USERNAME:$POSTGRESQL_PASSWORD@localhost:$POSTGRESQL_PORT/$POSTGRESQL_DATABASE?schema=public\"" > .env
read -e -p ".env created with PORT, generated TOKEN_HASH and DATABASE_URL (for prisma). Do you want to edit it [y|n]? " EDIT
if [ $EDIT = "y" ]; then
  vim .env
fi

# migrate prisma
yarn prisma migrate deploy

# nginx (allow acces to port 80)
sudo apt install nginx -y
sudo ufw allow 80
sudo su
cd /etc/nginx/sites-available
read -e -p "Enter the project name: " PROJECT_NAME
touch $PROJECT_NAME
echo "server {
  listen 80 default_server;
  listen [::]:80 default_server;

  server_name _;

  location / {
    proxy_pass http://localhost:$APP_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }
}" > $PROJECT_NAME
cd ../sites-enabled
rm default
ln -s /etc/nginx/sites-available/$PROJECT_NAME $PROJECT_NAME
service nginx reload
service nginx restart
exit

# restart docker container on server problems unless it is directly stopped
docker update --restart=unless-stopped $CONTAINER_ID

# start app with pm2
npm install -g pm2
cd ~
cd 
pm2 start dist/shared/infra/http/server.js
COMMAND=$(pm2 startup systemd)
echo $COMMAND | grep sudo | bash

# configure the ssl
read -e -p "Now, it's time to configure the domain. When configured, enter the domain: " DOMAIN
sed -i "s/server_name _;/server_name $DOMAIN;/" /etc/nginx/sites-available/$PROJECT_NAME
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
echo "Enter your polijunior email, yes twice and then the press enter on the domain"
sudo certbot --nginx
sudo ufw allow 443

# the end
echo "The deploy is ready! :)"
GOODBYE="
  _____                 _ _                _ 
 / ____|               | | |              | |
| |  __  ___   ___   __| | |__  _   _  ___| |
| | |_ |/ _ \ / _ \ / _\` | '_ \| | | |/ _ \\ |
| |__| | (_) | (_) | (_| | |_) | |_| |  __/_|
 \_____|\___/ \___/ \__,_|_.__/ \__, |\___(_)
                                 __/ |       
                                |___/ 
"
echo $GOODBYE

exit
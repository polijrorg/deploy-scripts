# nginx (allow acces to port 80)
sudo apt install nginx -y
sudo ufw allow 80
cd /etc/nginx/sites-available
read -e -p "Enter the project name: " PROJECT_NAME
sudo touch $PROJECT_NAME
sudo echo "server {
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
sudo rm default
sudo ln -s /etc/nginx/sites-available/$PROJECT_NAME $PROJECT_NAME
sudo service nginx reload
sudo service nginx restart

# restart docker container on server problems unless it is directly stopped
docker update --restart=unless-stopped $CONTAINER_ID

# start app with pm2
npm install -g pm2
read -e -p "Enter the name of the project root (example: piupiuwer-back): " DIR_NAME
cd ~/$DIR_NAME
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
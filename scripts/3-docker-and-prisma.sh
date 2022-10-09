#!/bin/bash

source /home/deploy/.bashrc

cd /home/deploy/$DIR_NAME

# create and run docker container
read -e -p "Enter the new postgresql username: " POSTGRESQL_USERNAME
read -e -p "Enter the new postgresql password: " POSTGRESQL_PASSWORD
read -e -p "Enter the new postgresql database name: " POSTGRESQL_DATABASE
read -e -p "Enter the new postgresql database port: " POSTGRESQL_PORT
CONTAINER_ID=$(sudo docker run -d --name postgresql -e POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD -e POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME -e POSTGRESQL_DATABASE=$POSTGRESQL_DATABASE -p $POSTGRESQL_PORT:5432 bitnami/postgresql:latest)
echo "export CONTAINER_ID=$CONTAINER_ID" >> /home/deploy/.bashrc


# create .env
read -e -p "Enter the app port: " APP_PORT
echo "export APP_PORT=$APP_PORT" >> /home/deploy/.bashrc
UUID=$(uuidgen)
touch .env
echo "PORT=$APP_PORT
TOKEN_HASH=$UUID
DATABASE_URL=\"postgresql://$POSTGRESQL_USERNAME:$POSTGRESQL_PASSWORD@localhost:$POSTGRESQL_PORT/$POSTGRESQL_DATABASE?schema=public\"
" > .env
read -e -p ".env created with PORT, generated TOKEN_HASH and DATABASE_URL (for prisma). Do you want to edit it [y|n]? " EDIT
if [ $EDIT = "y" ]; then
  vim .env
fi

# migrate prisma
yarn prisma migrate deploy

echo "Script Finished!"


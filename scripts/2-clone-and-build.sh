#!/bin/bash

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source /home/deploy/.bashrc

# install node
nvm install node
source /home/deploy/.bashrc
node -v


# install yarn
npm i -g yarn
source /home/deploy/.bashrc
yarn -v

# cloning backend repo
read -e -p "Enter the backend repo link: " REPO_LINK
git clone $REPO_LINK
DIR_NAME=$(echo $REPO_LINK | sed -E 's/.*\///g')
"export DIRNAME=$DIR_NAME" >> echo /home/deploy/.bashrc
cd $DIR_NAME

# install dependencies and build
yarn
yarn build

# change permissions to use docker
GARBAGE=$(sudo groupadd docker)
sudo usermod -aG docker deploy

echo "Script Finished!"


#!/bin/bash

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc

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
cd $DIR_NAME

# install dependencies and build
yarn
yarn build

# change permissions to use docker
sudo usermod -aG docker $USER

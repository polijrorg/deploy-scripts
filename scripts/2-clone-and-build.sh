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
source ~/.bashrc

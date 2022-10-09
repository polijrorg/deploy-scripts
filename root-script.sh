#!/bin/bash

apt update && apt upgrade -y
adduser deploy
read -e -p "Enter the new user username: " USERNAME
usermod -aG sudo $USERNAME

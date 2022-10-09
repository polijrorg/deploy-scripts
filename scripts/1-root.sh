#!/bin/bash

apt update && apt upgrade -y
adduser deploy
usermod -aG sudo deploy

echo "Script Finished!"

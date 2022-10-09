#!/bin/bash

apt update && apt upgrade
adduser deploy
usermod -aG sudo deploy

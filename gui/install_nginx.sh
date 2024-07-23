#!/bin/bash
# Function to install nginx
clear
echo "Installing nginx..."
sudo apt-get install nginx -y && sudo ufw allow ssh && sudo ufw allow 'Nginx Full' && sudo ufw enable

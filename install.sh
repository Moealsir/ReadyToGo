#!/bin/bash

# update and upgrade
echo ""
echo "Updating and upgrading..."
sudo apt-get update
# sudo apt-get upgrade -y
clear

# install git
echo ""
echo "Installing git..."
sudo apt-get install git -y
clear

# install curl
echo ""
echo "Installing curl..."
sudo apt-get install curl -y
clear

# install latest version of nodejs
echo ""
echo "Installing nodejs..."
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
nvm install --lts
nvm use --lts
clear

# install latest version of npm
echo ""
echo "Installing npm..."
sudo npm install -g npm
clear

# install sshpass 
echo ""
echo "Installing sshpass..."
sudo apt-get install sshpass -y

# install trash-cli
echo ""
echo "Installing trash-cli..."
sudo apt-get install trash-cli -y
clear

# install python3
echo ""
echo "Installing python3..."
sudo apt-get install python3 -y
clear

# install pm2 
echo ""
npm install pm2@latest -g
pm2 startup
pm2 save
clear

# install mysql
echo ""
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql.service

# cp dir_navigator.sh to /usr/local/bin
echo ""
echo "Copying dir_navigator.sh to /bin..."
sudo cp dir_navigator.sh /bin/
clear


# create gituser gitmail token variables
read -p "Enter your Github username: " gituser
read -p "Enter your Github email: " gitmail
read -p "Enter your Github token: " token

# Add the variables to ~/.bashrc
echo "Adding gituser, gitmail, and token to ~/.bashrc..."

{
    echo ""
    echo "# GitHub credentials"
    echo "export gituser=\"$gituser\""
    echo "export gitmail=\"$gitmail\""
    echo "export token=\"$token\""
    echo ""
} >> ~/.bashrc

#add file to_bash content to ~/.bashrc
cat to_bash >> ~/.bashrc


# ask user if want to install and setup nginx if yes set it up
read -p "Do you want to install and setup nginx? (y/n): " nginx
if [ "$nginx" == "y" ]; then
    echo "Installing nginx..."
    sudo apt-get install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo ufw allow 'Nginx Full'
    sudo ufw enable
    clear
fi
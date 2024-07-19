#!/bin/bash

# update and upgrade
echo "Updating and upgrading..."
sudo apt-get update
sudo apt-get upgrade -y
clear

# install git
echo "Installing git..."
sudo apt-get install git -y
clear

# install curl
echo "Installing curl..."
sudo apt-get install curl -y
clear

# install latest version of nodejs
echo "Installing nodejs..."
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
nvm install --lts
nvm use --lts
clear

# install latest version of npm
echo "Installing npm..."
sudo npm install -g npm
clear

# install sshpass 
echo "Installing sshpass..."
sudo apt-get install sshpass -y

# install trash-cli
echo "Installing trash-cli..."
sudo apt-get install trash-cli -y
clear

# install python3
echo "Installing python3..."
sudo apt-get install python3 -y
clear

# install pm2 
npm install pm2@latest -g
pm2 startup
pm2 save
clear

# cp dir_navigator.sh to /usr/local/bin
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
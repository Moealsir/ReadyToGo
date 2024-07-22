#!/bin/bash

# Update and upgrade
# echo ""
# echo "Updating and upgrading..."
# sudo apt-get update
# # sudo apt-get upgrade -y
# clear

# # Install specific version of Node.js and npm
# echo ""
# echo "Installing Node.js v20.15.1 and npm v10.7.0..."
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# sudo apt install -y nodejs
# clear



# # Install pm2
# echo ""
# echo "Installing pm2..."
# npm install pm2@latest -g
# npm install -g npm@10.8.2
# clear

# # Install MySQL
# echo ""
# echo "Installing MySQL..."
# sudo apt update
# sudo apt install mysql-server -y
# sudo systemctl start mysql.service
# clear

# Copy dir_navigator.sh to /usr/local/bin
echo ""
echo "Copying dir_navigator.sh to /usr/local/bin..."
sudo cp dir_navigator.sh /usr/local/bin/
clear


# Add file to_bash content to ~/.bashrc
cat to_bash >> ~/.bashrc

# Create gituser, gitmail, token variables
read -p "Enter your GitHub username: " gituser
read -p "Enter your GitHub email: " gitmail
read -sp "Enter your GitHub token: " token
echo  # To add a new line after entering the token

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

# # Ask user if they want to install and set up nginx
# read -p "Do you want to install and setup nginx? (y/n): " nginx
# if [ "$nginx" == "y" ]; then
#     echo "Installing nginx..."
#     sudo apt-get install nginx -y
#     sudo ufw allow http
#     sudo ufw allow https
#     sudo systemctl start nginx
#     sudo systemctl enable nginx
#     sudo ufw allow 'Nginx Full'
#     sudo ufw enable
#     sudo ufw allow ssh
#     clear
# fi

echo "Setup complete."

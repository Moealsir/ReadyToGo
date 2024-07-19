#!/bin/bash

# Update and upgrade
echo ""
echo "Updating and upgrading..."
sudo apt-get update
# sudo apt-get upgrade -y
clear

# Install git
echo ""
echo "Installing git..."
sudo apt-get install git -y
clear

# Install curl
echo ""
echo "Installing curl..."
sudo apt-get install curl -y
clear

# Install nvm (Node Version Manager)
echo ""
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
clear

# Install specific version of Node.js and npm
echo ""
echo "Installing Node.js v20.15.1 and npm v10.7.0..."
nvm install 20.15.1
nvm use 20.15.1
npm install -g npm@10.7.0
clear

# Install sshpass
echo ""
echo "Installing sshpass..."
sudo apt-get install sshpass -y
clear

# Install trash-cli
echo ""
echo "Installing trash-cli..."
sudo apt-get install trash-cli -y
clear

# Install python3
echo ""
echo "Installing python3..."
sudo apt-get install python3 -y
clear

# Install pm2
echo ""
echo "Installing pm2..."
npm install pm2@latest -g
pm2 startup
pm2 save
clear

# Install MySQL
echo ""
echo "Installing MySQL..."
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql.service
clear

# Copy dir_navigator.sh to /usr/local/bin
echo ""
echo "Copying dir_navigator.sh to /usr/local/bin..."
sudo cp dir_navigator.sh /usr/local/bin/
clear

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

# Add file to_bash content to ~/.bashrc
cat to_bash >> ~/.bashrc

# Ask user if they want to install and set up nginx
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

echo "Setup complete."

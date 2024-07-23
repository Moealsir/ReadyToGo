#!/bin/bash

LOGFILE="setup.log"
ERRORFILE="setup_error.log"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $message" | tee -a "$LOGFILE"
}

# Function to log errors
log_error() {
    local error_message=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") : ERROR : $error_message" | tee -a "$ERRORFILE"
}

# Function to update and upgrade the system
update_and_upgrade() {
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        return 1
    fi
    clear
}

# Function to install Node.js and npm
install_nodejs_npm() {
    log_message "Installing Node.js v20.15.1 and npm v10.7.0..."
    if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
        log_error "Failed to download and run Node.js setup script"
        return 1
    fi
    if ! sudo apt install -y nodejs; then
        log_error "Failed to install Node.js and npm"
        return 1
    fi
    clear
}

# Function to install PM2
install_pm2() {
    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        return 1
    fi
    clear
}

# Function to install MySQL
install_mysql() {
    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        return 1
    fi
    clear
}

# Function to copy dir_navigator.sh to /usr/local/bin
copy_dir_navigator() {
    log_message "Copying dir_navigator.sh to /usr/local/bin..."
    if ! sudo cp dir_navigator.sh /usr/local/bin/; then
        log_error "Failed to copy dir_navigator.sh"
        return 1
    fi
    clear
}

# Function to add to_bash content to ~/.bashrc
add_to_bashrc() {
    log_message "Adding to_bash content to ~/.bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to ~/.bashrc"
        return 1
    fi
}

# Function to create gituser, gitmail, token variables and add them to ~/.bashrc
add_github_credentials() {
    read -p "Enter your GitHub username: " gituser
    read -p "Enter your GitHub email: " gitmail
    read -sp "Enter your GitHub token: " token
    echo  # To add a new line after entering the token

    log_message "Adding gituser, gitmail, and token to ~/.bashrc..."
    {
        echo ""
        echo "# GitHub credentials"
        echo "export gituser=\"$gituser\""
        echo "export gitmail=\"$gitmail\""
        echo "export token=\"$token\""
        echo ""
    } >> ~/.bashrc
}

# Function to install nginx
install_nginx() {
    log_message "Installing nginx..."
    if ! sudo apt-get install nginx -y || ! sudo ufw allow ssh || ! sudo ufw allow 'Nginx Full' || ! sudo ufw enable; then
        log_error "Failed to install and configure nginx"
        return 1
    fi
    clear
}

# Main script execution
update_and_upgrade
install_nodejs_npm
install_pm2
install_mysql
copy_dir_navigator
add_to_bashrc
add_github_credentials
install_nginx

log_message "Setup complete."
log_message "Run command source ~/.bashrc"

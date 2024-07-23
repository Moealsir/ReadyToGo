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
    clear
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        return 1
    fi
    # Uncomment the line below if you want to perform the upgrade
    # if ! sudo apt-get upgrade -y; then
    #     log_error "Failed to upgrade packages"
    #     return 1
    # fi
}

# Function to install Node.js and npm
install_nodejs_npm() {
    clear
    log_message "Installing Node.js v20.15.1 and npm v10.7.0..."
    if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
        log_error "Failed to download and run Node.js setup script"
        return 1
    fi
    if ! sudo apt install -y nodejs; then
        log_error "Failed to install Node.js and npm"
        return 1
    fi
}

# Function to install PM2
install_pm2() {
    clear
    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        return 1
    fi
}

# Function to install MySQL
install_mysql() {
    clear
    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        return 1
    fi
}

# Function to copy dir_navigator.sh to /usr/local/bin
copy_dir_navigator() {
    clear
    log_message "Copying dir_navigator.sh to /usr/local/bin..."
    if ! sudo cp dir_navigator.sh /usr/local/bin/; then
        log_error "Failed to copy dir_navigator.sh"
        return 1
    fi
}

# Function to add authorized keys
add_authorized_keys() {
    clear
    log_message "Adding authorized keys..."
    if ! mkdir -p ~/.ssh || ! touch ~/.ssh/authorized_keys || ! chmod 700 ~/.ssh || ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to create ~/.ssh/authorized_keys"
        return 1
    fi
    cp authorized_keys ~/.ssh/authorized_keys
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
    clear
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
    clear
    log_message "Installing nginx..."
    if ! sudo apt-get install nginx -y || ! sudo ufw allow ssh || ! sudo ufw allow 'Nginx Full' || ! sudo ufw enable; then
        log_error "Failed to install and configure nginx"
        return 1
    fi
}

# Function to add swap space
add_swap() {
    clear
    read -p "Enter the size of swap space in GB: " size

    # Check if the input is a positive integer
    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        log_error "Error: The size must be a positive integer."
        return 1
    fi

    log_message "Adding swap space of ${size}G..."

    # Create the swap file
    if ! sudo fallocate -l "${size}G" /swapfile; then
        log_error "Failed to create swapfile"
        return 1
    fi

    if ! sudo chmod 600 /swapfile; then
        log_error "Failed to set permissions on swapfile"
        return 1
    fi

    if ! sudo mkswap /swapfile; then
        log_error "Failed to format swapfile"
        return 1
    fi

    if ! sudo swapon /swapfile; then
        log_error "Failed to enable swapfile"
        return 1
    fi

    if ! sudo cp /etc/fstab /etc/fstab.bak; then
        log_error "Failed to backup /etc/fstab"
        return 1
    fi

    if ! grep -q '/swapfile' /etc/fstab || ! echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; then
        log_error "Failed to add swapfile entry to /etc/fstab"
        return 1
    fi

    if ! echo "
vm.swappiness=10
vm.vfs_cache_pressure=50
" | sudo tee -a /etc/sysctl.conf; then
        log_error "Failed to add sysctl parameters"
        return 1
    fi

    if ! sudo sysctl -p; then
        log_error "Failed to apply new sysctl settings"
        return 1
    fi

    log_message "Swap file created, configured, and sysctl settings updated successfully."

    free -h
}

# Function to prompt user for confirmation before proceeding
prompt_user() {
    read -p "Press Enter to proceed to the next step..."
}

# Function to check versions of installed software
check_versions() {
    clear
    log_message "Checking versions of installed software..."

    local node_version=$(node -v)
    local npm_version=$(npm -v)
    local pm2_version=$(pm2 -v)
    local mysql_version=$(mysql --version)
    local nginx_version=$(nginx -v 2>&1)
    
    clear
    log_message "Node.js version: $node_version"
    log_message "npm version: $npm_version"
    log_message "PM2 version: $pm2_version"
    log_message "MySQL version: $mysql_version"
    log_message "Nginx version: $nginx_version"

    echo "Installed versions:"
    echo "Node.js: $node_version"
    echo "npm: $npm_version"
    echo "PM2: $pm2_version"
    echo "MySQL: $mysql_version"
    echo "Nginx: $nginx_version"
}

# Main script execution
update_and_upgrade
prompt_user
install_nodejs_npm
prompt_user
install_pm2
prompt_user
add_swap
prompt_user
install_mysql
prompt_user
copy_dir_navigator
prompt_user
add_to_bashrc
prompt_user
add_authorized_keys
prompt_user
add_github_credentials
prompt_user
install_nginx
prompt_user


log_message "Setup complete."
check_versions

log_message "Please run source ~/.bashrc"

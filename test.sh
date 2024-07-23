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

# Define colors
pink='\033[1;35m'
reset='\033[0m'

# Functions for each tool/module

update_and_upgrade() {
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
}

install_pm2() {
    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        return 1
    fi
}

install_mysql() {
    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        return 1
    fi
}

copy_dir_navigator() {
    log_message "Copying dir_navigator.sh to /usr/local/bin..."
    if ! sudo cp dir_navigator.sh /usr/local/bin/; then
        log_error "Failed to copy dir_navigator.sh"
        return 1
    fi
}

add_authorized_keys() {
    log_message "Adding authorized keys..."
    if ! mkdir -p ~/.ssh || ! touch ~/.ssh/authorized_keys || ! chmod 700 ~/.ssh || ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to create ~/.ssh/authorized_keys"
        return 1
    fi
    cp authorized_keys ~/.ssh/authorized_keys
}

add_to_bashrc() {
    log_message "Adding to_bash content to ~/.bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to ~/.bashrc"
        return 1
    fi
}

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

install_nginx() {
    log_message "Installing nginx..."
    if ! sudo apt-get install nginx -y || ! sudo ufw allow ssh || ! sudo ufw allow 'Nginx Full' || ! sudo ufw enable; then
        log_error "Failed to install and configure nginx"
        return 1
    fi
}

add_swap() {
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

check_versions() {
    log_message "Checking versions of installed software..."

    local node_version=$(node -v)
    local npm_version=$(npm -v)
    local pm2_version=$(pm2 -v)
    local mysql_version=$(mysql --version)
    local nginx_version=$(nginx -v 2>&1)
    
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

# Function to select and execute chosen tools/modules
execute_choices() {
    local choices=$1
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

# Define colors
pink='\033[1;35m'
reset='\033[0m'

# Functions for each tool/module

update_and_upgrade() {
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
}

install_pm2() {
    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        return 1
    fi
}

install_mysql() {
    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        return 1
    fi
}

copy_dir_navigator() {
    log_message "Copying dir_navigator.sh to /usr/local/bin..."
    if ! sudo cp dir_navigator.sh /usr/local/bin/; then
        log_error "Failed to copy dir_navigator.sh"
        return 1
    fi
}

add_authorized_keys() {
    log_message "Adding authorized keys..."
    if ! mkdir -p ~/.ssh || ! touch ~/.ssh/authorized_keys || ! chmod 700 ~/.ssh || ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to create ~/.ssh/authorized_keys"
        return 1
    fi
    cp authorized_keys ~/.ssh/authorized_keys
}

add_to_bashrc() {
    log_message "Adding to_bash content to ~/.bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to ~/.bashrc"
        return 1
    fi
}

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

install_nginx() {
    log_message "Installing nginx..."
    if ! sudo apt-get install nginx -y || ! sudo ufw allow ssh || ! sudo ufw allow 'Nginx Full' || ! sudo ufw enable; then
        log_error "Failed to install and configure nginx"
        return 1
    fi
}

add_swap() {
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

check_versions() {
    log_message "Checking versions of installed software..."

    local node_version=$(node -v)
    local npm_version=$(npm -v)
    local pm2_version=$(pm2 -v)
    local mysql_version=$(mysql --version)
    local nginx_version=$(nginx -v 2>&1)
    
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

# Function to select and execute chosen tools/modules
execute_choices() {
    local choices=$1

    for choice in $choices; do
        case $choice in
            1) update_and_upgrade ;;
            2) install_nodejs_npm ;;
            3) install_pm2 ;;
            4) install_mysql ;;
            5) copy_dir_navigator ;;
            6) add_authorized_keys ;;
            7) add_to_bashrc ;;
            8) add_github_credentials ;;
            9) install_nginx ;;
            10) add_swap ;;
            11) check_versions ;;
            *) echo "Invalid option $choice. Skipping." ;;
        esac
    done
}

# Main script
clear
echo -e "${pink}Setup Tool Selector${reset}"
echo "Select the tools/modules you want to install (e.g., 1 2 5 10):"
read -p "Enter your choices separated by spaces: " user_choices

# Execute selected choices
execute_choices "$user_choices"

log_message "Setup complete."
echo "Please run 'source ~/.bashrc' if ~/.bashrc was modified."

            1) update_and_upgrade ;;
            2) install_nodejs_npm ;;
            3) install_pm2 ;;
            4) install_mysql ;;
            5) copy_dir_navigator ;;
            6) add_authorized_keys ;;
            7) add_to_bashrc ;;
            8) add_github_credentials ;;
            9) install_nginx ;;
            10) add_swap ;;
            11) check_versions ;;
            *) echo "Invalid option $choice. Skipping." ;;
        esac
    done
}

# Main script
clear
echo -e "${pink}Setup Tool Selector${reset}"
echo "Select the tools/modules you want to install (e.g., 1 2 5 10):"
read -p "Enter your choices separated by spaces: " user_choices

# Execute selected choices
execute_choices "$user_choices"

log_message "Setup complete."
echo "Please run 'source ~/.bashrc' if ~/.bashrc was modified."

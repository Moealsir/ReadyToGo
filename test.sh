#!/bin/bash

LOGFILE="setup.log"
ERRORFILE="setup_error.log"
STATEFILE="setup_state.txt"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $message" | tee -a "$LOGFILE"
}

# Function to log errors
log_error() {
    local error_message=$1
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") : \033[1;31mERROR : $error_message\033[0m" | tee -a "$ERRORFILE"
}

# Define colors
pink='\033[1;35m'    # Pink
green='\033[0;32m'   # Green
orange='\033[0;33m'  # Orange
reset='\033[0m'      # Reset color

# Initialize state file
initialize_state() {
    if [ ! -f "$STATEFILE" ]; then
        touch "$STATEFILE"
    fi
}

# Update the state file with the executed choice
update_state() {
    local choice=$1
    echo "$choice" >> "$STATEFILE"
}

# Check if a choice has been executed
is_executed() {
    local choice=$1
    grep -q "^$choice$" "$STATEFILE"
}

# Functions for each tool/module
update_and_upgrade() {
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        return 1
    else
        log_message "Package list updated successfully."
    fi
}

install_nodejs_npm() {
    if is_executed "2"; then
        log_message "Node.js and npm already installed. Skipping."
        return
    fi

    log_message "Installing Node.js v20.15.1 and npm v10.7.0..."

    # Step 1: Add Node.js repository for version 20.x
    log_message "Adding Node.js repository..."
    if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
        log_error "Failed to download and run Node.js setup script"
        echo -e "${orange}Failed to add Node.js repository${reset}"
        return 1
    fi

    # Step 2: Install Node.js and npm
    log_message "Installing Node.js and npm..."
    if ! sudo apt install -y nodejs; then
        log_error "Failed to install Node.js and npm"
        echo -e "${orange}Failed to install Node.js and npm${reset}"
        return 1
    fi

    # Step 3: Verify installation
    node_version=$(node -v)
    npm_version=$(npm -v)

    log_message "Node.js version: $node_version"
    log_message "npm version: $npm_version"

    # Step 4: Update state file
    update_state "2"

    log_message "Node.js and npm installed successfully."
}

install_pm2() {
    if is_executed "3"; then
        log_message "pm2 already installed. Skipping."
        return
    fi

    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        echo -e "${orange}Failed to install pm2${reset}"
        return 1
    else
        log_message "pm2 installed successfully."
    fi
    update_state "3"
}

install_mysql() {
    if is_executed "5"; then
        log_message "MySQL already installed. Skipping."
        return
    fi

    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        echo -e "${orange}Failed to install and start MySQL${reset}"
        return 1
    else
        log_message "MySQL installed and started successfully."
    fi
    update_state "5"
}

copy_dir_navigator() {
    log_message "Copying dir_navigator.sh to /usr/local/bin..."
    if ! sudo cp dir_navigator.sh /usr/local/bin/; then
        log_error "Failed to copy dir_navigator.sh"
        echo -e "${orange}Failed to copy dir_navigator.sh${reset}"
        return 1
    else
        log_message "dir_navigator.sh copied successfully."
    fi
}

add_authorized_keys() {
    if is_executed "6"; then
        log_message "Authorized keys already added. Skipping."
        return
    fi

    log_message "Adding authorized keys..."
    if ! mkdir -p ~/.ssh || ! touch ~/.ssh/authorized_keys || ! chmod 700 ~/.ssh || ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to create ~/.ssh/authorized_keys"
        echo -e "${orange}Failed to create ~/.ssh/authorized_keys${reset}"
        return 1
    fi
    cp authorized_keys ~/.ssh/authorized_keys
    log_message "Authorized keys added successfully."
    update_state "6"
}

add_to_bashrc() {
    if is_executed "7"; then
        log_message "GitHub credentials already added to ~/.bashrc. Skipping."
        return
    fi

    log_message "Adding to_bash content to ~/.bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to ~/.bashrc"
        echo -e "${orange}Failed to append to_bash content to ~/.bashrc${reset}"
        return 1
    fi
    copy_dir_navigator
    add_github_credentials
    log_message "to_bash content added to ~/.bashrc successfully."
    update_state "7"
}

add_github_credentials() {
    if is_executed "7"; then
        log_message "GitHub credentials already added to ~/.bashrc. Skipping."
        return
    fi

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

    update_state "7"
}

install_nginx() {
    if is_executed "8"; then
        log_message "Nginx already installed. Skipping."
        return
    fi

    log_message "Installing nginx..."
    if ! sudo apt-get install nginx -y || ! sudo ufw allow ssh || ! sudo ufw allow 'Nginx Full' || ! sudo ufw enable; then
        log_error "Failed to install and configure nginx"
        echo -e "${orange}Failed to install and configure nginx${reset}"
        return 1
    else
        log_message "Nginx installed and configured successfully."
    fi
    update_state "8"
}

add_swap() {
    if is_executed "4"; then
        log_message "Swap space already added. Skipping."
        return
    fi

    read -p "Enter the size of swap space in GB: " size

    # Check if the input is a positive integer
    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        log_error "Error: The size must be a positive integer."
        echo -e "${orange}Error: The size must be a positive integer.${reset}"
        return 1
    fi

    log_message "Adding swap space of ${size}G..."

    # Create the swap file
    if ! sudo fallocate -l "${size}G" /swapfile; then
        log_error "Failed to create swapfile"
        echo -e "${orange}Failed to create swapfile${reset}"
        return 1
    fi

    if ! sudo chmod 600 /swapfile; then
        log_error "Failed to set permissions on swapfile"
        echo -e "${orange}Failed to set permissions on swapfile${reset}"
        return 1
    fi

    if ! sudo mkswap /swapfile; then
        log_error "Failed to format swapfile"
        echo -e "${orange}Failed to format swapfile${reset}"
        return 1
    fi

    if ! sudo swapon /swapfile; then
        log_error "Failed to enable swapfile"
        echo -e "${orange}Failed to enable swapfile${reset}"
        return 1
    fi

    if ! sudo cp /etc/fstab /etc/fstab.bak; then
        log_error "Failed to backup /etc/fstab"
        echo -e "${orange}Failed to backup /etc/fstab${reset}"
        return 1
    fi

    if ! grep -q '/swapfile' /etc/fstab || ! echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; then
        log_error "Failed to add swapfile entry to /etc/fstab"
        echo -e "${orange}Failed to add swapfile entry to /etc/fstab${reset}"
        return 1
    fi

    if ! echo "
vm.swappiness=10
vm.vfs_cache_pressure=50
" | sudo tee -a /etc/sysctl.conf; then
        log_error "Failed to add sysctl parameters"
        echo -e "${orange}Failed to add sysctl parameters${reset}"
        return 1
    fi

    if ! sudo sysctl -p; then
        log_error "Failed to apply new sysctl settings"
        echo -e "${orange}Failed to apply new sysctl settings${reset}"
        return 1
    fi

    log_message "Swap file created, configured, and sysctl settings updated successfully."

    free -h
    update_state "4"
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

# Function to process ranges and individual numbers
process_choices() {
    local choices=$1
    local result=""

    # Split input by spaces and iterate over each part
    for part in $choices; do
        # Handle ranges (e.g., 1-3)
        if [[ $part =~ ^([0-9]+)-([0-9]+)$ ]]; then
            start=${BASH_REMATCH[1]}
            end=${BASH_REMATCH[2]}
            if [[ $start -le $end ]]; then
                for ((i=start; i<=end; i++)); do
                    result+="$i "
                done
            else
                log_error "Invalid range: $part. Skipping."
            fi
        # Handle individual numbers
        elif [[ $part =~ ^[0-9]+$ ]]; then
            result+="$part "
        else
            log_error "Invalid input: $part. Skipping."
        fi
    done

    echo "$result"
}

# Function to select and execute chosen tools/modules
execute_choices() {
    local choices=$1
    processed_choices=$(process_choices "$choices")

    for choice in $processed_choices; do
        case $choice in
            1) update_and_upgrade ;;
            2) install_nodejs_npm ;;
            3) install_pm2 ;;
            4) add_swap ;;
            5) install_mysql ;;
            6) add_authorized_keys ;;
            7) add_to_bashrc ;;
            8) install_nginx ;;
            9) check_versions ;;
            *) log_error "Invalid option $choice. Skipping." ;;
        esac
    done
}

# Function to display menu
display_menu() {
    clear
    echo -e "${pink}Setup Tool Selector${reset}"
    echo "Select the tools/modules you want to install by entering the corresponding numbers separated by spaces (or 'q' to quit):"
    for i in {1..8}; do
        if is_executed "$i"; then
            echo -e "${green}${i}) ${descriptions[$i]}${reset}"
        else
            echo "${i}) ${descriptions[$i]}"
        fi
    done
    echo -n "Enter your choices: "
}

# Define tool descriptions
declare -A descriptions
descriptions=(
    [1]="Update and Upgrade"
    [2]="Install Node.js and npm"
    [3]="Install pm2"
    [4]="Add Swap Space"
    [5]="Install MySQL"
    [6]="Add Authorized Keys"
    [7]="Add GitHub Credentials to ~/.bashrc"
    [8]="Install Nginx"
    [9]="Check Installed Versions"
)

# Main script loop
initialize_state

while true; do
    display_menu
    read -r user_choices

    # Check if the user wants to quit
    if [[ "$user_choices" == "q" ]]; then
        log_message "User chose to quit."
        echo "Exiting..."
        break
    fi

    # Execute selected choices
    execute_choices "$user_choices"
    
    log_message "Setup complete."
    echo "Please run 'source ~/.bashrc' if ~/.bashrc was modified."
done

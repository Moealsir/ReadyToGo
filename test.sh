#!/bin/bash

LOGFILE="setup.log"
ERRORFILE="setup_error.log"
STATEFILE="setup_state.txt"
FAILUREFILE="setup_failure.txt"

# Define colors
pink='\033[1;35m'    # Pink
green='\033[0;32m'   # Green
orange='\033[0;33m'  # Orange
reset='\033[0m'      # Reset color

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

# Initialize state file
initialize_state() {
    if [ ! -f "$STATEFILE" ]; then
        touch "$STATEFILE"
    fi
    if [ ! -f "$FAILUREFILE" ]; then
        touch "$FAILUREFILE"
    fi
}

# Update the state file with the executed choice
update_state() {
    local choice=$1
    echo "$choice" >> "$STATEFILE"
}

# Update the failure file with the failed choice
update_failure() {
    local choice=$1
    echo "$choice" >> "$FAILUREFILE"
}

# Check if a choice has been executed
is_executed() {
    local choice=$1
    grep -q "^$choice$" "$STATEFILE"
}

# Check if a choice has failed
is_failed() {
    local choice=$1
    grep -q "^$choice$" "$FAILUREFILE"
}

# Functions for each tool/module
update_and_upgrade() {
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        update_failure "1"
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
        update_failure "2"
        return 1
    fi

    # Step 2: Install Node.js and npm
    log_message "Installing Node.js and npm..."
    if ! sudo apt install -y nodejs; then
        log_error "Failed to install Node.js and npm"
        echo -e "${orange}Failed to install Node.js and npm${reset}"
        update_failure "2"
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
        update_failure "3"
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
        update_failure "5"
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
        update_failure "4"
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
        update_failure "6"
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
        update_failure "7"
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
        update_failure "8"
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
        update_failure "4"
        return 1
    fi

    log_message "Adding swap space of ${size}G..."

    # Create the swap file
    if ! sudo fallocate -l "${size}G" /swapfile; then
        log_error "Failed to create swapfile"
        echo -e "${orange}Failed to create swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo chmod 600 /swapfile; then
        log_error "Failed to set permissions on swapfile"
        echo -e "${orange}Failed to set permissions on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo mkswap /swapfile; then
        log_error "Failed to set up swap space on swapfile"
        echo -e "${orange}Failed to set up swap space on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo swapon /swapfile; then
        log_error "Failed to enable swap space on swapfile"
        echo -e "${orange}Failed to enable swap space on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; then
        log_error "Failed to add swapfile to /etc/fstab"
        echo -e "${orange}Failed to add swapfile to /etc/fstab${reset}"
        update_failure "4"
        return 1
    fi

    update_state "4"
    log_message "Swap space added successfully."
}

# Function to display menu options
display_menu() {
    clear
    echo -e "${pink}Choose a task:${reset}"
    # echo "1) Update and upgrade"
    # echo "2) Install Node.js and npm"
    # echo "3) Install pm2"
    # echo "4) Add Swap Space"
    # echo "5) Install MySQL"
    # echo "6) Add authorized_keys"
    # echo "7) Add to_bash content to .bashrc"
    # echo "8) Install nginx"
    # echo "r) Reset colors"
    # echo "q) Quit"
    # echo ""

    for choice in $(seq 1 9); do
        if is_executed "$choice"; then
            echo -e "$choice) ${green}$(get_choice_description "$choice")${reset}"
        elif is_failed "$choice"; then
            echo -e "$choice) ${orange}$(get_choice_description "$choice")${reset}"
        else
            echo -e "$choice) $(get_choice_description "$choice")"
        fi
    done
}

# Function to get choice description
get_choice_description() {
    case $1 in
        1) echo "Update and upgrade";;
        2) echo "Install Node.js and npm";;
        3) echo "Install pm2";;
        4) echo "Add Swap Space";;
        5) echo "Install MySQL";;
        6) echo "Add authorized_keys";;
        7) echo "Add to_bash content to .bashrc";;
        8) echo "Install nginx";;
        0) echo "Reset colors";;
    esac
}

# Function to reset colors
reset_colors() {
    > "$STATEFILE"
    > "$FAILUREFILE"
    log_message "All colors reset."
}

# Main script loop
initialize_state

while true; do
    display_menu

    read -p "Enter your choice: " choice
    case $choice in
        1) update_and_upgrade;;
        2) install_nodejs_npm;;
        3) install_pm2;;
        4) add_swap;;
        5) install_mysql;;
        6) add_authorized_keys;;
        7) add_to_bashrc;;
        8) install_nginx;;
        0) reset_colors;;
        q) break;;
        *) echo "Invalid choice!";;
    esac
done

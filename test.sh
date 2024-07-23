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
    echo "$(date +"%Y-%m-%d %H:%M:%S") : ERROR : $error_message" | tee -a "$ERRORFILE"
}

# Define colors
pink='\033[1;35m'
green='\033[0;32m'
reset='\033[0m'

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

# Functions for each tool/module (same as before)
update_and_upgrade() {
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        return 1
    fi
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
    update_state "1"
}

install_pm2() {
    log_message "Installing pm2..."
    if ! sudo npm install pm2@latest -g; then
        log_error "Failed to install pm2"
        return 1
    fi
    update_state "2"
}

install_mysql() {
    log_message "Installing MySQL..."
    if ! sudo apt update || ! sudo apt install mysql-server -y || ! sudo systemctl start mysql.service; then
        log_error "Failed to install and start MySQL"
        return 1
    fi
    update_state "4"
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
    update_state "5"
}

add_to_bashrc() {
    log_message "Adding to_bash content to ~/.bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to ~/.bashrc"
        return 1
    fi
    copy_dir_navigator
    add_github_credentials
    update_state "6"
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
    update_state "7"
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
    update_state "3"
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
                echo "Invalid range: $part. Skipping."
            fi
        # Handle individual numbers
        elif [[ $part =~ ^[0-9]+$ ]]; then
            result+="$part "
        else
            echo "Invalid input: $part. Skipping."
        fi
    done

    echo "$result"
}

# Function to select and execute chosen tools/modules
execute_choices() {
    local choices=$1
    local processed_choices
    processed_choices=$(process_choices "$choices")

    for choice in $processed_choices; do
        case $choice in
            1) install_nodejs_npm ;;
            2) install_pm2 ;;
            3) add_swap ;;
            4) install_mysql ;;
            5) add_authorized_keys ;;
            6) add_to_bashrc ;;
            7) install_nginx ;;
            8) check_versions ;;
            *) echo "Invalid option $choice. Skipping." ;;
        esac
    done
}


# Function to display menu
display_menu() {
    clear
    echo -e "${pink}Setup Tool Selector${reset}"
    echo "Select the tools/modules you want to install by entering the corresponding numbers separated by spaces (or 'q' to quit):"
    echo "1) Update and Upgrade"
    echo "2) Install Node.js and npm"
    echo "3) Add Swap Space"
    echo "4) Install MySQL"
    echo "5) Add Authorized Keys"
    echo "6) Add GitHub Credentials to ~/.bashrc"
    echo "7) Install Nginx"
    echo "8) Check Installed Versions"
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
    [3]="Add Swap Space"
    [4]="Install MySQL"
    [5]="Add Authorized Keys"
    [6]="Add GitHub Credentials to ~/.bashrc"
    [7]="Install Nginx"
    [8]="Check Installed Versions"
)

# Function to reset the color
reset_colors() {
    echo "Select options to reset colors:"
    echo "1) Reset color for one option"
    echo "2) Reset color for multiple options"
    echo "3) Reset all colors"
    read -r reset_choice

    case $reset_choice in
        1) 
            echo "Enter the option number to reset color (1-8): "
            read -r option
            sed -i "/^$option$/d" "$STATEFILE"
            ;;
        2)
            echo "Enter the option numbers to reset colors (e.g., 1 2 3): "
            read -r options
            for option in $options; do
                sed -i "/^$option$/d" "$STATEFILE"
            done
            ;;
        3)
            > "$STATEFILE"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

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

    # Debug output
    echo "User choices: $user_choices"

    # Execute selected choices
    execute_choices "$user_choices"
    
    log_message "Setup complete."
    echo "Please run 'source ~/.bashrc' if ~/.bashrc was modified."
done

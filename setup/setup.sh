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

# Load module scripts
source update_and_upgrade.sh
source install_nodejs_npm.sh
source install_pm2.sh
source install_mysql.sh
source add_swap.sh
source add_authorized_keys.sh
source add_to_bashrc.sh
source install_nginx.sh

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

# Function to display menu options
display_menu() {
    clear
    echo -e "${pink}Choose a task:${reset}"
    
    for choice in $(seq 0 8); do
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
        0) echo "Reset colors";;
        1) echo "Update and upgrade";;
        2) echo "Install Node.js and npm";;
        3) echo "Install pm2";;
        4) echo "Add Swap Space";;
        5) echo "Install MySQL";;
        6) echo "Add authorized_keys";;
        7) echo "Add to_bash content to .bashrc";;
        8) echo "Install nginx";;
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

    read -p "Enter your choice: ('r' to reset colors, 'q' to quit)" choice
    case $choice in
        0) reset_colors;;
        1) update_and_upgrade;;
        2) install_nodejs_npm;;
        3) install_pm2;;
        4) add_swap;;
        5) install_mysql;;
        6) add_authorized_keys;;
        7) add_to_bashrc;;
        8) install_nginx;;
        r) reset_colors;;
        q) break;;
        *) echo "Invalid choice!";;
    esac
done

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
source scripts/update_and_upgrade.sh
source scripts/install_nodejs_npm.sh
source scripts/install_pm2.sh
source scripts/install_mysql.sh
source scripts/add_swap.sh
source scripts/add_authorized_keys.sh
source scripts/add_to_bashrc.sh
source scripts/install_nginx.sh
source scripts/configure_firewall.sh
source scripts/install_ssl.sh
source scripts/install_docker.sh
source scripts/install_fail2ban.sh
source scripts/manage_users.sh
source scripts/configure_backups.sh
source scripts/install_monitoring_tools.sh
source scripts/configure_log_rotation.sh
source scripts/schedule_security_updates.sh

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
    
    for choice in $(seq 0 17); do
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
        9) echo "Configure Firewall";;
        10) echo "Install SSL Certificates";;
        11) echo "Install Docker and Docker Compose";;
        12) echo "Install Fail2ban";;
        13) echo "Manage Users";;
        14) echo "Configure Backups";;
        15) echo "Install Monitoring Tools";;
        16) echo "Configure Log Rotation";;
        17) echo "Schedule Security Updates";;
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
        9) configure_firewall;;
        10) install_ssl;;
        11) install_docker;;
        12) install_fail2ban;;
        13) manage_users;;
        14) configure_backups;;
        15) install_monitoring_tools;;
        16) configure_log_rotation;;
        17) schedule_security_updates;;
        r) reset_colors;;
        q) break;;
        *) echo "Invalid choice!";;
    esac
done

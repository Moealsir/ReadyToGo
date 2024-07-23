install_pm2() {
    if is_executed "3"; then
        log_message "pm2 already installed. Skipping."
        return
    fi

    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        log_message "Node.js and npm are not installed. Please install them first."
        echo -e "${orange}Node.js and npm are not installed. Please install them first.${reset}"
        return 1
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

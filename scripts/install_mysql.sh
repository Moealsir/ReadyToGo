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

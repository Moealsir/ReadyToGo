#!/bin/bash

install_fail2ban() {
    if is_executed "12"; then
        log_message "Fail2ban already installed. Skipping."
        return
    fi

    log_message "Installing Fail2ban..."
    if ! sudo apt update || ! sudo apt install fail2ban -y; then
        log_error "Failed to install Fail2ban"
        update_failure "12"
        return 1
    fi

    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban
    update_state "12"
    log_message "Fail2ban installed and started successfully."
}

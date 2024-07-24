#!/bin/bash

configure_log_rotation() {
    if is_executed "16"; then
        log_message "Log rotation already configured. Skipping."
        return
    fi

    log_message "Configuring log rotation..."
    if ! sudo apt update || ! sudo apt install logrotate -y; then
        log_error "Failed to install logrotate"
        update_failure "16"
        return 1
    fi

    sudo logrotate /etc/logrotate.conf
    update_state "16"
    log_message "Log rotation configured successfully."
}

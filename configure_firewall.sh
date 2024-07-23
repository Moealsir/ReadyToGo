#!/bin/bash

configure_firewall() {
    if is_executed "9"; then
        log_message "Firewall already configured. Skipping."
        return
    fi

    log_message "Configuring firewall..."
    if ! sudo ufw default deny incoming || ! sudo ufw default allow outgoing || ! sudo ufw allow ssh; then
        log_error "Failed to configure firewall"
        update_failure "9"
        return 1
    fi

    sudo ufw enable
    update_state "9"
    log_message "Firewall configured successfully."
}

#!/bin/bash

install_nginx() {
    if is_executed "8"; then
        log_message "nginx already installed. Skipping."
        return
    fi

    log_message "Installing nginx..."
    if ! sudo apt update || ! sudo apt install nginx -y || ! sudo systemctl start nginx.service; then
        log_error "Failed to install and start nginx"
        echo -e "${orange}Failed to install and start nginx${reset}"
        update_failure "8"
        return 1
    fi

    log_message "Configuring firewall for nginx..."
    if ! sudo ufw allow 'Nginx Full' || ! sudo ufw allow ssh || ! sudo ufw enable; then
        log_error "Failed to configure firewall for nginx and SSH"
        echo -e "${orange}Failed to configure firewall for nginx and SSH${reset}"
        update_failure "8"
        return 1
    fi

    update_state "8"
    log_message "nginx installed, started, and firewall configured successfully."
}

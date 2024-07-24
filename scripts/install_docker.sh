#!/bin/bash

install_docker() {
    if is_executed "11"; then
        log_message "Docker already installed. Skipping."
        return
    fi

    log_message "Installing Docker and Docker Compose..."
    if ! sudo apt update || ! sudo apt install docker.io docker-compose -y; then
        log_error "Failed to install Docker and Docker Compose"
        update_failure "11"
        return 1
    fi

    sudo systemctl start docker
    sudo systemctl enable docker
    update_state "11"
    log_message "Docker and Docker Compose installed successfully."
}

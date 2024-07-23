#!/bin/bash

add_authorized_keys() {
    if is_executed "6"; then
        log_message "authorized_keys already added. Skipping."
        return
    fi

    log_message "Creating .ssh directory if it doesn't exist..."
    if ! mkdir -p ~/.ssh; then
        log_error "Failed to create .ssh directory"
        echo -e "${orange}Failed to create .ssh directory${reset}"
        update_failure "6"
        return 1
    fi

    log_message "Copying authorized_keys to ~/.ssh/..."
    if ! cp ./authorized_keys ~/.ssh/; then
        log_error "Failed to copy authorized_keys to ~/.ssh/"
        echo -e "${orange}Failed to copy authorized_keys to ~/.ssh/${reset}"
        update_failure "6"
        return 1
    fi

    log_message "Setting permissions on ~/.ssh/authorized_keys..."
    if ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to set permissions on authorized_keys"
        echo -e "${orange}Failed to set permissions on authorized_keys${reset}"
        update_failure "6"
        return 1
    fi

    update_state "6"
    log_message "Public key successfully added to authorized_keys."
}

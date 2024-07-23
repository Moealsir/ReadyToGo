add_authorized_keys() {
    if is_executed "6"; then
        log_message "authorized_keys already added. Skipping."
        return
    fi

    read -p "Enter the public key: " public_key

    if ! mkdir -p ~/.ssh; then
        log_error "Failed to create .ssh directory"
        echo -e "${orange}Failed to create .ssh directory${reset}"
        update_failure "6"
        return 1
    fi

    if ! echo "$public_key" >> ~/.ssh/authorized_keys; then
        log_error "Failed to add public key to authorized_keys"
        echo -e "${orange}Failed to add public key to authorized_keys${reset}"
        update_failure "6"
        return 1
    fi

    if ! chmod 600 ~/.ssh/authorized_keys; then
        log_error "Failed to set permissions on authorized_keys"
        echo -e "${orange}Failed to set permissions on authorized_keys${reset}"
        update_failure "6"
        return 1
    fi

    update_state "6"
    log_message "Public key added to authorized_keys."
}

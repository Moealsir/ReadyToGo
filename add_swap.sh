add_swap() {
    if is_executed "4"; then
        log_message "Swap space already added. Skipping."
        return
    fi

    read -p "Enter the size of swap space in GB: " size

    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        log_error "Error: The size must be a positive integer."
        echo -e "${orange}Error: The size must be a positive integer.${reset}"
        update_failure "4"
        return 1
    fi

    log_message "Adding swap space of ${size}G..."

    if ! sudo fallocate -l "${size}G" /swapfile; then
        log_error "Failed to create swapfile"
        echo -e "${orange}Failed to create swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo chmod 600 /swapfile; then
        log_error "Failed to set permissions on swapfile"
        echo -e "${orange}Failed to set permissions on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo mkswap /swapfile; then
        log_error "Failed to set up swap space on swapfile"
        echo -e "${orange}Failed to set up swap space on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! sudo swapon /swapfile; then
        log_error "Failed to enable swap space on swapfile"
        echo -e "${orange}Failed to enable swap space on swapfile${reset}"
        update_failure "4"
        return 1
    fi

    if ! echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; then
        log_error "Failed to add swapfile to /etc/fstab"
        echo -e "${orange}Failed to add swapfile to /etc/fstab${reset}"
        update_failure "4"
        return 1
    fi

    update_state "4"
    log_message "Swap space added successfully."
}

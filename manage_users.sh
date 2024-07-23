#!/bin/bash

manage_users() {
    if is_executed "13"; then
        log_message "User management already done. Skipping."
        return
    fi

    log_message "Managing users..."
    read -p "Enter the username to create: " username
    if ! sudo adduser "$username"; then
        log_error "Failed to create user $username"
        update_failure "13"
        return 1
    fi

    read -p "Enter groups for the user (comma-separated): " groups
    if ! sudo usermod -aG "$groups" "$username"; then
        log_error "Failed to add user $username to groups $groups"
        update_failure "13"
        return 1
    fi

    update_state "13"
    log_message "User $username created and added to groups $groups successfully."
}

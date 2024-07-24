update_and_upgrade() {
    log_message "Updating and upgrading..."
    if ! sudo apt-get update; then
        log_error "Failed to update package list"
        update_failure "1"
        return 1
    else
        log_message "Package list updated successfully."
    fi
}

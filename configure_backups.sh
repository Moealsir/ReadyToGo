#!/bin/bash

configure_backups() {
    if is_executed "14"; then
        log_message "Backup already configured. Skipping."
        return
    fi

    log_message "Configuring backups..."
    read -p "Enter the backup directory: " backup_dir
    read -p "Enter the remote backup location (user@host:/path): " remote_backup

    echo "0 2 * * * root rsync -av --delete $backup_dir $remote_backup" | sudo tee -a /etc/crontab
    if [ $? -ne 0 ]; then
        log_error "Failed to configure backups"
        update_failure "14"
        return 1
    fi

    update_state "14"
    log_message "Backups configured successfully."
}

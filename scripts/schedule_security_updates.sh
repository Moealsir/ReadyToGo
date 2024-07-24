#!/bin/bash

schedule_security_updates() {
    if is_executed "17"; then
        log_message "Security updates already scheduled. Skipping."
        return
    fi

    log_message "Scheduling security updates..."
    echo "0 3 * * * root apt update && apt upgrade -y" | sudo tee -a /etc/crontab
    if [ $? -ne 0 ]; then
        log_error "Failed to schedule security updates"
        update_failure "17"
        return 1
    fi

    update_state "17"
    log_message "Security updates scheduled successfully."
}

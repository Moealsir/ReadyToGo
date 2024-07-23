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
    else
        log_message "nginx installed and started successfully."
    fi
    update_state "8"
}

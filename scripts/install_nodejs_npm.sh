install_nodejs_npm() {
    if is_executed "2"; then
        log_message "Node.js and npm already installed. Skipping."
        return
    fi

    log_message "Installing Node.js v20.15.1 and npm v10.7.0..."

    log_message "Adding Node.js repository..."
    if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
        log_error "Failed to download and run Node.js setup script"
        echo -e "${orange}Failed to add Node.js repository${reset}"
        update_failure "2"
        return 1
    fi

    log_message "Installing Node.js and npm..."
    if ! sudo apt install -y nodejs; then
        log_error "Failed to install Node.js and npm"
        echo -e "${orange}Failed to install Node.js and npm${reset}"
        update_failure "2"
        return 1
    fi

    node_version=$(node -v)
    npm_version=$(npm -v)

    log_message "Node.js version: $node_version"
    log_message "npm version: $npm_version"

    update_state "2"
    log_message "Node.js and npm installed successfully."
}

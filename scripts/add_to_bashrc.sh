#!/bin/bash

add_to_bashrc() {
    if is_executed "7"; then
        log_message "Content already added to .bashrc. Skipping."
        return
    fi

    log_message "Adding dir_navigator.sh to /bin/..."
    if ! sudo cp ./dir_navigator.sh /bin/; then
        log_error "Failed to copy dir_navigator.sh to /bin/"
        echo -e "${orange}Failed to copy dir_navigator.sh to /bin/${reset}"
        update_failure "7"
        return 1
    fi

    log_message "Adding GitHub credentials to .bashrc..."
    read -p "Enter your GitHub username: " gituser
    read -p "Enter your GitHub email: " gitmail
    read -sp "Enter your GitHub token: " token
    echo  # To add a new line after entering the token

    {
        echo ""
        echo "# GitHub credentials"
        echo "export gituser=\"$gituser\""
        echo "export gitmail=\"$gitmail\""
        echo "export token=\"$token\""
    } >> ~/.bashrc

    log_message "Appending to_bash content to .bashrc..."
    if ! cat to_bash >> ~/.bashrc; then
        log_error "Failed to append to_bash content to .bashrc"
        echo -e "${orange}Failed to append to_bash content to .bashrc${reset}"
        update_failure "7"
        return 1
    fi

    update_state "7"
    log_message "Content added to .bashrc successfully."
}

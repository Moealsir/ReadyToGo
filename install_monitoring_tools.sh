#!/bin/bash

install_monitoring_tools() {
    if is_executed "15"; then
        log_message "Monitoring tools already installed. Skipping."
        return
    fi

    log_message "Installing Prometheus and Grafana..."
    if ! sudo apt update || ! sudo apt install prometheus grafana -y; then
        log_error "Failed to install Prometheus and Grafana"
        update_failure "15"
        return 1
    fi

    sudo systemctl start prometheus
    sudo systemctl enable prometheus
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
    update_state "15"
    log_message "Prometheus and Grafana installed and started successfully."
}

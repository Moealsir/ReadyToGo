#!/bin/bash
# Function to install MySQL
clear
echo "Installing MySQL..."
sudo apt update && sudo apt install mysql-server -y && sudo systemctl start mysql.service

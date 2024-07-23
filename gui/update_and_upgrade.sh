#!/bin/bash
# Function to update and upgrade the system
clear
echo "Updating and upgrading..."
sudo apt-get update && sudo apt-get upgrade -y

#!/bin/bash
# Function to add swap space
clear
read -p "Enter the size of swap space in GB: " size

if ! [[ "$size" =~ ^[0-9]+$ ]]; then
    echo "Error: The size must be a positive integer."
    exit 1
fi

echo "Adding swap space of ${size}G..."

sudo fallocate -l "${size}G" /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo "
vm.swappiness=10
vm.vfs_cache_pressure=50
" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Swap file created, configured, and sysctl settings updated successfully."

free -h

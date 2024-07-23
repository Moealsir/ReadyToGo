#!/bin/bash
# Function to add authorized keys
clear
echo "Adding authorized keys..."
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
cp authorized_keys ~/.ssh/authorized_keys

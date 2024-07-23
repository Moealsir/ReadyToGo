#!/bin/bash
# Function to create gituser, gitmail, token variables and add them to ~/.bashrc
clear
read -p "Enter your GitHub username: " gituser
read -p "Enter your GitHub email: " gitmail
read -sp "Enter your GitHub token: " token
echo  # To add a new line after entering the token

echo "" >> ~/.bashrc
echo "# GitHub credentials" >> ~/.bashrc
echo "export gituser=\"$gituser\"" >> ~/.bashrc
echo "export gitmail=\"$gitmail\"" >> ~/.bashrc
echo "export token=\"$token\"" >> ~/.bashrc

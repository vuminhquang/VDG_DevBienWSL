#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

sudo apt update
sudo apt install -y wget gnupg

# Install Amazon Corretto JDK
echo_message "Installing Amazon Corretto JDK..."

# Import the Corretto public key and add the repository
wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list

# Update package list and install Amazon Corretto
sudo apt-get update
sudo apt-get install -y java-21-amazon-corretto-jdk

# Verify Java installation
echo_message "Verifying Java installation..."
java -version
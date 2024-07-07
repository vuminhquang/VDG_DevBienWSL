#!/bin/bash

# Function to print messages
function print_message {
    echo -e "\n\033[1;32m$1\033[0m\n"
}

# Step 1: Update and Upgrade Your System
print_message "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install systemd and Related Packages
print_message "Installing systemd and related packages..."
sudo apt install -y systemd systemd-sysv

# Step 3: Enable systemd in WSL
print_message "Enabling systemd in WSL..."

# Create or modify /etc/wsl.conf
WSL_CONF_PATH="/etc/wsl.conf"

# Backup existing wsl.conf if it exists
if [ -f "$WSL_CONF_PATH" ]; then
    sudo cp "$WSL_CONF_PATH" "$WSL_CONF_PATH.bak"
    print_message "Backup of existing wsl.conf created at $WSL_CONF_PATH.bak"
fi

# Add systemd configuration to wsl.conf
sudo bash -c 'echo -e "\n[boot]\nsystemd=true" | tee -a /etc/wsl.conf'
print_message "Configuration file /etc/wsl.conf updated to enable systemd."

# Prompt user to restart WSL
print_message "Please restart WSL to apply changes. Run the following commands in PowerShell or Command Prompt:"
echo -e "\n\033[1;33mwsl --shutdown\nwsl\033[0m\n"

print_message "Installation and configuration complete."
#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Update package list and install necessary packages
echo_message "Updating package list and installing necessary packages..."
sudo apt-get update
sudo apt-get install -y fontconfig


# Create font directory
echo_message "Creating font directory..."
mkdir -p ~/.local/share/fonts

# Copy Windows fonts
echo_message "Copying Windows fonts..."
cp /mnt/c/Windows/Fonts/*.ttf ~/.local/share/fonts/

# Update font cache
echo_message "Updating font cache..."
fc-cache -f -v

# Verify installation (optional)
echo_message "Verifying font installation..."
fc-list | grep "Segoe"
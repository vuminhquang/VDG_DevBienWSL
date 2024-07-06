#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Install zlib
echo_message "Installing zlib..."
sudo apt-get update
sudo apt-get install -y console-setup zlib1g-dev || { echo_message "Failed to install zlib."; exit 1; }

echo_message "zlib installation complete."


# Install gnome-keyring
echo_message "Installing gnome-keyring..."
sudo apt-get update
sudo apt-get install -y libsecret-1-0 gnome-keyring || { echo_message "Failed to install gnome-keyring."; exit 1; }

echo_message "gnome-keyring installation complete."
#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Install prerequisites
echo_message "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y software-properties-common apt-transport-https wget gnupg || { echo_message "Failed to install prerequisites."; exit 1; }

# Add the Microsoft GPG key
echo_message "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - || { echo_message "Failed to add Microsoft GPG key."; exit 1; }

# Add the Microsoft Edge repository
echo_message "Adding Microsoft Edge repository..."
echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list || { echo_message "Failed to add Microsoft Edge repository."; exit 1; }

# Install Microsoft Edge
echo_message "Installing Microsoft Edge..."
sudo apt-get update
sudo apt-get install -y microsoft-edge-stable || { echo_message "Failed to install Microsoft Edge."; exit 1; }

echo_message "Microsoft Edge installation complete. You can start Microsoft Edge from your application menu or by running 'microsoft-edge'."
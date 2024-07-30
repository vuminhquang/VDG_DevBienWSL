#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Function to get the latest LTS version of Node.js
get_latest_lts_version() {
    local latest_lts_version=$(curl -sL https://nodejs.org/dist/index.json | grep -oP '"version":\s*"\K(v[0-9]+\.[0-9]+\.[0-9]+)(?=",.*"lts":\s*true)' | head -n 1)
    echo $latest_lts_version
}

# Variables
LATEST_LTS_VERSION=$(get_latest_lts_version)
NODEJS_VERSION=${LATEST_LTS_VERSION#v} # Remove the 'v' prefix

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y curl || { echo_message "Failed to install packages."; exit 1; }

# Add NodeSource APT repository for Node.js
echo_message "Adding NodeSource APT repository for Node.js..."
curl -fsSL https://deb.nodesource.com/setup_$NODEJS_VERSION.x | sudo -E bash - || { echo_message "Failed to add NodeSource APT repository."; exit 1; }

# Install Node.js
echo_message "Installing Node.js version $NODEJS_VERSION..."
#sudo apt-get install -y nodejs || { echo_message "Failed to install Node.js."; exit 1; }
# install nsolid (which is node, to have npm too, if apt install nodejs only there will have no npm ins)
sudo apt-get install nsolid -y || { echo_message "Failed to install Node.js."; exit 1; }

# Verify the installation
echo_message "Verifying Node.js installation..."
node -v || { echo_message "Node.js installation verification failed."; exit 1; }
npm -v || { echo_message "NPM installation verification failed."; exit 1; }

echo_message "Node.js $NODEJS_VERSION installation complete. You can use the 'node' and 'npm' commands to verify."
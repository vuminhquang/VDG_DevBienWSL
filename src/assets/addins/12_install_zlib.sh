#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Install zlib
echo_message "Installing zlib..."
sudo apt-get update
sudo apt-get install -y zlib1g-dev || { echo_message "Failed to install zlib."; exit 1; }

echo_message "zlib installation complete."
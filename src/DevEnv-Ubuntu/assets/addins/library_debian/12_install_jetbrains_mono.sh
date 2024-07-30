#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
FONT_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
FONT_ZIP="/tmp/JetBrainsMono.zip"
FONT_DIR="/usr/share/fonts/truetype/jetbrains-mono"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget unzip || { echo_message "Failed to install packages."; exit 1; }

# Download the font
echo_message "Downloading JetBrains Mono font from $FONT_URL..."
wget -O $FONT_ZIP $FONT_URL || { echo_message "Failed to download JetBrains Mono font."; exit 1; }

# Create installation directory
echo_message "Creating font installation directory..."
sudo mkdir -p $FONT_DIR || { echo_message "Failed to create font installation directory."; exit 1; }

# Unzip the font
echo_message "Unzipping JetBrains Mono font..."
unzip -o $FONT_ZIP -d /tmp || { echo_message "Failed to unzip JetBrains Mono font."; exit 1; }

# Install the font to the system-wide directory
echo_message "Installing JetBrains Mono font to system-wide directory..."
sudo mv /tmp/fonts/ttf/*.ttf $FONT_DIR/ || { echo_message "Failed to install JetBrains Mono font."; exit 1; }

# Clean up
echo_message "Cleaning up..."
rm -f $FONT_ZIP
rm -rf /tmp/fonts || { echo_message "Failed to clean up."; exit 1; }

# Refresh font cache
echo_message "Refreshing font cache..."
sudo fc-cache -f -v || { echo_message "Failed to refresh font cache."; exit 1; }

echo_message "JetBrains Mono font installation complete."
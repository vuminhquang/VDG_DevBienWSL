#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Direct download URL for GitKraken
GITKRAKEN_URL="https://release.gitkraken.com/linux/gitkraken-amd64.deb"

# Variables
GITKRAKEN_DEB="/tmp/gitkraken.deb"
DESKTOP_ENTRY="/usr/share/applications/gitkraken.desktop"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget gdebi-core || { echo_message "Failed to install packages."; exit 1; }

# Download GitKraken
echo_message "Downloading GitKraken from $GITKRAKEN_URL..."
wget -O $GITKRAKEN_DEB $GITKRAKEN_URL || { echo_message "Failed to download GitKraken."; exit 1; }

# Install GitKraken
echo_message "Installing GitKraken..."
sudo gdebi -n $GITKRAKEN_DEB || { echo_message "Failed to install GitKraken."; exit 1; }

# Clean up
echo_message "Cleaning up..."
rm $GITKRAKEN_DEB || { echo_message "Failed to clean up."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GitKraken
Icon=/usr/share/gitkraken/gitkraken.png
Exec=/usr/bin/gitkraken
Comment=The legendary Git GUI client
Categories=Development;IDE;
Terminal=false
StartupWMClass=GitKraken
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }




echo_message "GitKraken installation complete. You can start GitKraken from your applications menu."
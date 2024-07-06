#!/bin/bash

# Define the .NET installation script URL
DOTNET_INSTALL_SCRIPT_URL="https://dot.net/v1/dotnet-install.sh"

# Define the installation and symlink directories
DOTNET_INSTALL_DIR="/usr/share/dotnet"
DOTNET_SYMLINK="/usr/local/bin/dotnet"

# Download the .NET installation script using wget
echo "Downloading the .NET installation script..."
wget $DOTNET_INSTALL_SCRIPT_URL -O dotnet-install.sh

# Install the latest .NET SDK into the specified directory
echo "Installing the latest .NET SDK..."
sudo apt-get install -y libicu-dev
sudo bash dotnet-install.sh --version latest --install-dir $DOTNET_INSTALL_DIR

# (Optional) To install the .NET Runtime instead of the SDK, uncomment the following lines:
# echo "Installing the latest .NET Runtime..."
# sudo bash dotnet-install.sh --version latest --runtime aspnetcore --install-dir $DOTNET_INSTALL_DIR

# (Optional) To install a specific major version, uncomment and modify the following lines:
# DOTNET_MAJOR_VERSION="8.0"
# echo "Installing .NET $DOTNET_MAJOR_VERSION SDK..."
# sudo bash dotnet-install.sh --channel $DOTNET_MAJOR_VERSION --install-dir $DOTNET_INSTALL_DIR

# Create a symbolic link to make dotnet accessible globally
echo "Creating a symbolic link for dotnet..."
sudo ln -sf $DOTNET_INSTALL_DIR/dotnet $DOTNET_SYMLINK

# Clean up by removing the installation script
echo "Cleaning up the installation script..."
rm ./dotnet-install.sh

# Verify the installation
echo "Verifying the .NET installation..."
dotnet --version

echo "Installation of .NET completed successfully!"
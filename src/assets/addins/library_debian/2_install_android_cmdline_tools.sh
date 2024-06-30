#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
SDK_ROOT="/opt/android-sdk"
TOOLS_DIR="$SDK_ROOT/cmdline-tools/latest"
PLATFORM_TOOLS_DIR="$SDK_ROOT/platform-tools"
TEMP_ZIP="/tmp/android_cmdline_tools.zip"
PROFILE_FILE="/etc/profile.d/android-sdk.sh"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget unzip || { echo_message "Failed to install packages."; exit 1; }

# Create SDK directory
echo_message "Creating Android SDK directory..."
sudo mkdir -p $TOOLS_DIR || { echo_message "Failed to create Android SDK directory."; exit 1; }

# Download Android Command Line Tools
echo_message "Downloading Android Command Line Tools from $ANDROID_SDK_URL..."
wget -O $TEMP_ZIP $ANDROID_SDK_URL || { echo_message "Failed to download Android Command Line Tools."; exit 1; }

# Extract Android Command Line Tools
echo_message "Extracting Android Command Line Tools..."
sudo unzip -o $TEMP_ZIP -d $TOOLS_DIR || { echo_message "Failed to extract Android Command Line Tools."; exit 1; }

# Clean up
echo_message "Cleaning up..."
rm $TEMP_ZIP || { echo_message "Failed to clean up."; exit 1; }

# Set up environment variables
echo_message "Setting up environment variables..."
sudo tee $PROFILE_FILE > /dev/null << EOF
export ANDROID_SDK_ROOT=$SDK_ROOT
export PATH=\$PATH:$TOOLS_DIR/bin:$PLATFORM_TOOLS_DIR
EOF

sudo chmod +x $PROFILE_FILE || { echo_message "Failed to set up environment variables."; exit 1; }
source $PROFILE_FILE

# Install essential SDK packages
echo_message "Installing essential SDK packages..."
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-33" || { echo_message "Failed to install essential SDK packages."; exit 1; }

echo_message "Android Command Line Tools installation complete. Please restart your terminal or run 'source /etc/profile.d/android-sdk.sh' to use the tools."
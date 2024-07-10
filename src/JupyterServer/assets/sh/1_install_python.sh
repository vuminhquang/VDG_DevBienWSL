#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
PYTHON_VERSION="${1:-3.12}"  # Default to 3.12 if no version is provided
PYTHON_MAJOR_MINOR=$(echo $PYTHON_VERSION | cut -d. -f1,2)
PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
PYTHON_TARBALL="/tmp/Python-$PYTHON_VERSION.tgz"
BUILD_DIR="/tmp/Python-$PYTHON_VERSION"
INSTALL_DIR="/usr/local"

# Function to install python3-venv and python-venv if not already installed
install_python_venv() {
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
        echo_message "python3-venv is not installed. Installing it now..."
        sudo apt-get install -y python3-venv || { echo_message "Failed to install python3-venv."; exit 1; }
    else
        echo_message "python3-venv is already installed."
    fi

    if ! dpkg -s python-venv >/dev/null 2>&1; then
        echo_message "python-venv is not installed. Installing it now..."
        sudo apt-get install -y python-venv || { echo_message "Failed to install python-venv."; exit 1; }
    else
        echo_message "python-venv is already installed."
    fi
}

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget build-essential libffi-dev libssl-dev libbz2-dev zlib1g-dev liblzma-dev libreadline-dev libsqlite3-dev || { echo_message "Failed to install packages."; exit 1; }

# Install python3-venv and python-venv
install_python_venv

# Download Python
echo_message "Downloading Python $PYTHON_VERSION from $PYTHON_URL..."
wget -O $PYTHON_TARBALL $PYTHON_URL || { echo_message "Failed to download Python."; exit 1; }

# Extract Python
echo_message "Extracting Python $PYTHON_VERSION..."
mkdir -p $BUILD_DIR
tar -xzf $PYTHON_TARBALL -C $BUILD_DIR --strip-components=1 || { echo_message "Failed to extract Python."; exit 1; }

# Build and install Python
echo_message "Building and installing Python $PYTHON_VERSION..."
cd $BUILD_DIR
./configure --prefix=$INSTALL_DIR --enable-optimizations || { echo_message "Failed to configure Python build."; exit 1; }
make -j$(nproc) || { echo_message "Failed to build Python."; exit 1; }
sudo make altinstall || { echo_message "Failed to install Python."; exit 1; }

# Create symlinks for python and pip
echo_message "Creating symlinks for python and pip..."
sudo ln -sf $INSTALL_DIR/bin/python$PYTHON_MAJOR_MINOR /usr/bin/python$PYTHON_MAJOR_MINOR
sudo ln -sf $INSTALL_DIR/bin/pip$PYTHON_MAJOR_MINOR /usr/bin/pip$PYTHON_MAJOR_MINOR

# Optionally, create symlinks for `python` and `pip` if you want the default `python` and `pip` commands to point to the new version
sudo ln -sf $INSTALL_DIR/bin/python$PYTHON_MAJOR_MINOR /usr/bin/python
sudo ln -sf $INSTALL_DIR/bin/pip$PYTHON_MAJOR_MINOR /usr/bin/pip

# Add Python to PATH for all users
echo_message "Adding Python to PATH for all users..."
if [ ! -f /etc/profile.d/python.sh ]; then
    echo "export PATH=$INSTALL_DIR/bin:\$PATH" | sudo tee /etc/profile.d/python.sh
    sudo chmod +x /etc/profile.d/python.sh
fi

# Verify the installation
echo_message "Verifying Python installation..."
$INSTALL_DIR/bin/python$PYTHON_MAJOR_MINOR --version || { echo_message "Python installation verification failed."; exit 1; }

# Clean up
echo_message "Cleaning up..."
sudo rm -rf $PYTHON_TARBALL $BUILD_DIR || { echo_message "Failed to clean up."; exit 1; }

echo_message "Python $PYTHON_VERSION installation complete."

# Update symbolic links for previous versions
update_symlinks() {
    local old_version=$1
    echo_message "Updating symbolic links for Python $old_version to $PYTHON_VERSION..."
    sudo ln -sf $INSTALL_DIR/bin/python$PYTHON_MAJOR_MINOR /usr/bin/python$old_version
    sudo ln -sf $INSTALL_DIR/bin/pip$PYTHON_MAJOR_MINOR /usr/bin/pip$old_version
}

# Check for previous versions and update symlinks
for old_version in $(ls /usr/bin/python* | grep -oP 'python\K[0-9.]+'); do
    if [ "$old_version" != "$PYTHON_MAJOR_MINOR" ]; then
        update_symlinks $old_version
    fi
done
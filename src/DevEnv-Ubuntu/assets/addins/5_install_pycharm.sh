#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Direct download URL
PYCHARM_URL="https://download.jetbrains.com/python/pycharm-professional-2024.1.4.tar.gz"

# Variables
PYCHARM_TARBALL="/tmp/pycharm.tar.gz"
INSTALL_DIR="/opt/pycharm"
SYMLINK_DIR="/usr/local/bin"
PYCHARM_SYMLINK="$SYMLINK_DIR/pycharm"
RUN_SCRIPT="/usr/local/bin/run_pycharm.sh"
DESKTOP_ENTRY="/usr/share/applications/pycharm.desktop"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget tar libxext6 libxrender1 libxtst6 libxi6 libxrandr2 libxfixes3 libxinerama1 libfreetype6 fontconfig fonts-dejavu e2fsprogs || { echo_message "Failed to install packages."; exit 1; }

# Download PyCharm
echo_message "Downloading PyCharm from $PYCHARM_URL..."
wget -O $PYCHARM_TARBALL $PYCHARM_URL || { echo_message "Failed to download PyCharm."; exit 1; }

# Create installation directory
echo_message "Creating PyCharm installation directory..."
sudo mkdir -p $INSTALL_DIR || { echo_message "Failed to create PyCharm installation directory."; exit 1; }

# Extract PyCharm
echo_message "Extracting PyCharm..."
sudo tar -xzf $PYCHARM_TARBALL -C $INSTALL_DIR --strip-components=1 || { echo_message "Failed to extract PyCharm."; exit 1; }

# Verify the extraction
if [ ! -f "$INSTALL_DIR/bin/pycharm.sh" ]; then
    echo_message "PyCharm extraction failed: pycharm.sh not found."
    exit 1
fi

# Clean up
echo_message "Cleaning up..."
rm $PYCHARM_TARBALL || { echo_message "Failed to clean up."; exit 1; }

# Create a symbolic link
echo_message "Creating symbolic link..."
sudo ln -sf $INSTALL_DIR/bin/pycharm.sh $PYCHARM_SYMLINK || { echo_message "Failed to create symbolic link."; exit 1; }

# Get the path to the Java executable
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    echo_message "Java is not installed or not found in PATH."
    exit 1
fi

# Create a script to set DISPLAY and run PyCharm with the system's Java
echo_message "Creating run script to set DISPLAY variable and use system's Java..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route show default | awk '/default/ {print \$3}'):0.0
export PYCHARM_JDK=\$(dirname \$(dirname $JAVA_PATH))
export JAVA_HOME=\$(dirname \$(dirname $JAVA_PATH))
exec $INSTALL_DIR/bin/pycharm.sh
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm
Icon=$INSTALL_DIR/bin/pycharm.png
Exec=$RUN_SCRIPT
Comment=Python IDE for Professional Developers by JetBrains
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "PyCharm installation complete. You can start PyCharm by running 'run_pycharm.sh'."
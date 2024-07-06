#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Direct download URL for IntelliJ IDEA (update this to the latest version's URL if necessary)
INTELLIJ_URL="https://download.jetbrains.com/idea/ideaIC-2023.1.4.tar.gz"

# Variables
INTELLIJ_TARBALL="/tmp/intellij.tar.gz"
INSTALL_DIR="/opt/intellij"
SYMLINK_DIR="/usr/local/bin"
INTELLIJ_SYMLINK="$SYMLINK_DIR/intellij"
RUN_SCRIPT="/usr/local/bin/run_intellij.sh"
DESKTOP_ENTRY="/usr/share/applications/intellij.desktop"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget tar libxext6 libxrender1 libxtst6 libxi6 libxrandr2 libxfixes3 libxinerama1 libfreetype6 fontconfig fonts-dejavu || { echo_message "Failed to install packages."; exit 1; }

# Download IntelliJ IDEA
echo_message "Downloading IntelliJ IDEA from $INTELLIJ_URL..."
wget -O $INTELLIJ_TARBALL $INTELLIJ_URL || { echo_message "Failed to download IntelliJ IDEA."; exit 1; }

# Create installation directory
echo_message "Creating IntelliJ IDEA installation directory..."
sudo mkdir -p $INSTALL_DIR || { echo_message "Failed to create IntelliJ IDEA installation directory."; exit 1; }

# Extract IntelliJ IDEA
echo_message "Extracting IntelliJ IDEA..."
sudo tar -xzf $INTELLIJ_TARBALL -C $INSTALL_DIR --strip-components=1 || { echo_message "Failed to extract IntelliJ IDEA."; exit 1; }

# Verify the extraction
if [ ! -f "$INSTALL_DIR/bin/idea.sh" ]; then
    echo_message "IntelliJ IDEA extraction failed: idea.sh not found."
    exit 1
fi

# Clean up
echo_message "Cleaning up..."
rm $INTELLIJ_TARBALL || { echo_message "Failed to clean up."; exit 1; }

# Create a symbolic link
echo_message "Creating symbolic link..."
sudo ln -sf $INSTALL_DIR/bin/idea.sh $INTELLIJ_SYMLINK || { echo_message "Failed to create symbolic link."; exit 1; }

# Get the path to the Java executable
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    echo_message "Java is not installed or not found in PATH."
    exit 1
fi

# Create a script to set DISPLAY and run IntelliJ IDEA with the system's Java
echo_message "Creating run script to set DISPLAY variable and use system's Java..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route show default | awk '/default/ {print \$3}'):0.0
export INTELLIJ_JDK=\$(dirname \$(dirname $JAVA_PATH))
export JAVA_HOME=\$(dirname \$(dirname $JAVA_PATH))
exec $INSTALL_DIR/bin/idea.sh
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA
Icon=$INSTALL_DIR/bin/idea.png
Exec=$RUN_SCRIPT
Comment=Java IDE for Professional Developers by JetBrains
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "IntelliJ IDEA installation complete. You can start IntelliJ IDEA by running 'run_intellij.sh'."
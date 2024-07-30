#!/bin/bash
# set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Direct download URL
RIDER_URL="https://download.jetbrains.com/rider/JetBrains.Rider-2024.1.4.tar.gz"

# Variables
RIDER_TARBALL="/tmp/rider.tar.gz"
INSTALL_DIR="/opt/rider"
SYMLINK_DIR="/usr/local/bin"
RIDER_SYMLINK="$SYMLINK_DIR/rider"
RUN_SCRIPT="/usr/local/bin/run_rider.sh"
DESKTOP_ENTRY="/usr/share/applications/rider.desktop"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget tar libxext6 libxrender1 libxtst6 libxi6 libxrandr2 libxfixes3 libxinerama1 fonts-dejavu e2fsprogs iproute2 || { echo_message "Failed to install packages."; exit 1; }

# Download Rider
echo_message "Downloading Rider from $RIDER_URL..."
wget -O $RIDER_TARBALL $RIDER_URL || { echo_message "Failed to download Rider."; exit 1; }

# Create installation directory
echo_message "Creating Rider installation directory..."
sudo mkdir -p $INSTALL_DIR || { echo_message "Failed to create Rider installation directory."; exit 1; }

# Extract Rider
echo_message "Extracting Rider..."
sudo tar -xzf $RIDER_TARBALL -C $INSTALL_DIR --strip-components=1 || { echo_message "Failed to extract Rider."; exit 1; }

# Verify the extraction
if [ ! -f "$INSTALL_DIR/bin/rider.sh" ]; then
    echo_message "Rider extraction failed: rider.sh not found."
    exit 1
fi

# Clean up
echo_message "Cleaning up..."
rm $RIDER_TARBALL || { echo_message "Failed to clean up."; exit 1; }

# Create a symbolic link
echo_message "Creating symbolic link..."
sudo ln -sf $INSTALL_DIR/bin/rider.sh $RIDER_SYMLINK || { echo_message "Failed to create symbolic link."; exit 1; }

# Get the path to the Java executable
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    echo_message "Java is not installed or not found in PATH."
    exit 1
fi

# Create a script to set DISPLAY and run Rider with the system's Java
echo_message "Creating run script to set DISPLAY variable and use system's Java..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route | grep 'default' | grep 'eth0' | awk '{print \$3}'):0.0
export RIDER_JDK=\$(dirname \$(dirname $JAVA_PATH))
export JAVA_HOME=\$(dirname \$(dirname $JAVA_PATH))
exec $INSTALL_DIR/bin/rider.sh
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
# Create the applications directory if it doesn't exist
if [ ! -d "/usr/share/applications" ]; then
    echo_message "Creating /usr/share/applications directory..."
    sudo mkdir -p /usr/share/applications || { echo_message "Failed to create /usr/share/applications directory."; exit 1; }
fi

sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Rider
Icon=$INSTALL_DIR/bin/rider.png
Exec=$RUN_SCRIPT
Comment=.NET IDE for Professional Developers by JetBrains
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rider
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "Rider installation complete. You can start Rider by running 'run_rider.sh'."
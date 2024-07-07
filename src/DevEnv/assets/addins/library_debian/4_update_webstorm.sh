#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Function to fetch the latest WebStorm version using the JetBrains Toolbox App API
fetch_latest_webstorm_version() {
    local api_url="https://data.services.jetbrains.com/products/releases?code=WS&latest=true&type=release"
    local version=$(curl -s $api_url | jq -r '.WS[0].version')
    echo $version
}

# Function to get the installed WebStorm version
get_installed_webstorm_version() {
    local version_file="/opt/webstorm/product-info.json"
    if [ -f "$version_file" ]; then
        local installed_version=$(jq -r '.version' "$version_file")
        echo $installed_version
    else
        echo "none"
    fi
}

# Check if jq is installed, if not, install it
if ! command -v jq &> /dev/null
then
    echo_message "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq || { echo_message "Failed to install jq."; exit 1; }
fi

# Fetch the latest WebStorm version
LATEST_VERSION=$(fetch_latest_webstorm_version)

if [ -z "$LATEST_VERSION" ]; then
    echo_message "Failed to fetch the latest WebStorm version."
    exit 1
fi

# Fetch the installed WebStorm version
INSTALLED_VERSION=$(get_installed_webstorm_version)

echo_message "Latest version: $LATEST_VERSION"
echo_message "Installed version: $INSTALLED_VERSION"

# Compare versions
if [ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]; then
    echo_message "WebStorm is already up to date."
    exit 0
fi

# Update the download URL to the latest version
WEBSTORM_URL="https://download.jetbrains.com/webstorm/WebStorm-${LATEST_VERSION}.tar.gz"

# Variables
WEBSTORM_TARBALL="/tmp/webstorm.tar.gz"
INSTALL_DIR="/opt/webstorm"
SYMLINK_DIR="/usr/local/bin"
WEBSTORM_SYMLINK="$SYMLINK_DIR/webstorm"
RUN_SCRIPT="/usr/local/bin/run_webstorm.sh"
DESKTOP_ENTRY="/usr/share/applications/webstorm.desktop"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y wget tar libxext6 libxrender1 libxtst6 libxi6 libxrandr2 libxfixes3 libxinerama1 libfreetype6 fontconfig fonts-dejavu || { echo_message "Failed to install packages."; exit 1; }

# Download WebStorm
echo_message "Downloading WebStorm from $WEBSTORM_URL..."
wget -O $WEBSTORM_TARBALL $WEBSTORM_URL || { echo_message "Failed to download WebStorm."; exit 1; }

# Create installation directory
echo_message "Creating WebStorm installation directory..."
sudo mkdir -p $INSTALL_DIR || { echo_message "Failed to create WebStorm installation directory."; exit 1; }

# Extract WebStorm
echo_message "Extracting WebStorm..."
sudo tar -xzf $WEBSTORM_TARBALL -C $INSTALL_DIR --strip-components=1 || { echo_message "Failed to extract WebStorm."; exit 1; }

# Verify the extraction
if [ ! -f "$INSTALL_DIR/bin/webstorm.sh" ]; then
    echo_message "WebStorm extraction failed: webstorm.sh not found."
    exit 1
fi

# Clean up
echo_message "Cleaning up..."
rm $WEBSTORM_TARBALL || { echo_message "Failed to clean up."; exit 1; }

# Create a symbolic link
echo_message "Creating symbolic link..."
sudo ln -sf $INSTALL_DIR/bin/webstorm.sh $WEBSTORM_SYMLINK || { echo_message "Failed to create symbolic link."; exit 1; }

# Get the path to the Java executable
JAVA_PATH=$(which java)
if [ -z "$JAVA_PATH" ]; then
    echo_message "Java is not installed or not found in PATH."
    exit 1
fi

# Create a script to set DISPLAY and run WebStorm with the system's Java
echo_message "Creating run script to set DISPLAY variable and use system's Java..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route show default | awk '/default/ {print \$3}'):0.0
export WEBSTORM_JDK=\$(dirname \$(dirname $JAVA_PATH))
export JAVA_HOME=\$(dirname \$(dirname $JAVA_PATH))
exec $INSTALL_DIR/bin/webstorm.sh
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WebStorm
Icon=$INSTALL_DIR/bin/webstorm.png
Exec=$RUN_SCRIPT
Comment=JavaScript IDE for Professional Developers by JetBrains
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-webstorm
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "WebStorm installation complete. You can start WebStorm by running 'run_webstorm.sh'."
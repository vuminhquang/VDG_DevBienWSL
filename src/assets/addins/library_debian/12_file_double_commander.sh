#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
RUN_SCRIPT="/usr/local/bin/run_double_commander.sh"
DESKTOP_ENTRY="$HOME/.local/share/applications/double_commander.desktop"
LAUNCH_SCRIPT="$HOME/bin/launch-desktop.sh"
CONFIG_DIR="$HOME/.config/doublecmd"

# Ensure required directories exist
sudo mkdir -p /usr/share/desktop-directories/
mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname $DESKTOP_ENTRY)"
mkdir -p "$(dirname $LAUNCH_SCRIPT)"

# Install required packages
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y doublecmd-qt || { echo_message "Failed to install Double Commander."; exit 1; }

# Create a script to set DISPLAY and run Double Commander
echo_message "Creating run script to set DISPLAY variable and use system's Double Commander..."
sudo tee $RUN_SCRIPT > /dev/null << EOF
#!/bin/bash
export DISPLAY=\$(ip route show default | awk '/default/ {print \$3}'):0.0
exec doublecmd
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Double Commander
Icon=utilities-terminal
Exec=$RUN_SCRIPT
Comment=Lightweight file manager
Categories=Utility;FileManager;
Terminal=false
EOF

chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

# Create a helper script to launch .desktop files with gtk-launch
echo_message "Creating helper script to launch .desktop files with gtk-launch..."
tee $LAUNCH_SCRIPT > /dev/null << EOF
#!/bin/bash

if [ \$# -eq 0 ]; then
    echo "Usage: \$0 <path-to-desktop-file>"
    exit 1
fi

desktop_file="\$1"
app_name=\$(basename "\$desktop_file" .desktop)

gtk-launch "\$app_name"
EOF

chmod +x $LAUNCH_SCRIPT || { echo_message "Failed to create helper script."; exit 1; }

# Create a basic Double Commander configuration file with the file association and default path
echo_message "Creating Double Commander configuration..."
tee $CONFIG_DIR/extassoc.xml > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<doublecmd DCVersion="1.0.10">
  <ExtensionAssociation>
    <FileType>
      <Name>desktop</Name>
      <IconFile>/home/user/bin/launch-desktop.sh</IconFile>
      <ExtensionList>desktop</ExtensionList>
      <Actions>
        <Action>
          <Name>Open with launch-desktop.sh</Name>
          <Command>/home/user/bin/launch-desktop.sh</Command>
          <Params>%f</Params>
        </Action>
      </Actions>
    </FileType>
  </ExtensionAssociation>
</doublecmd>

EOF

# Install font for Zutty
sudo apt-get install -y xfonts-100dpi xfonts-75dpi
sudo mkfontdir /usr/share/fonts/X11/100dpi
sudo mkfontdir /usr/share/fonts/X11/75dpi
sudo mkfontscale /usr/share/fonts/X11/100dpi
sudo mkfontscale /usr/share/fonts/X11/75dpi
sudo fc-cache -fv

echo_message "Double Commander installation and configuration complete. You can start Double Commander from your application menu or by running 'run_double_commander.sh'."
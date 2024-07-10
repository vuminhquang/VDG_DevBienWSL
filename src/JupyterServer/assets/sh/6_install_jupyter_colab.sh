#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
RUN_SCRIPT="/usr/local/bin/run_jupyter_colab.sh"
DESKTOP_ENTRY="/usr/share/applications/jupyter_colab.desktop"

# Function to install python3-venv if it's not already installed
install_python_venv() {
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
        echo "python3-venv is not installed. Installing it now..."
        sudo apt update
        sudo apt install -y python3-venv
    else
        echo "python3-venv is already installed."
    fi
}

echo_message "Starting the installation of Jupyter and the Colab extension..."

# Step 1: Ensure python3-venv is installed
install_python_venv

# Step 2: Switch to the home directory and create a Python virtual environment
echo_message "Switching to the home directory..."
cd ~

echo_message "Creating a Python virtual environment..."
python3 -m venv ~/jupyter_env

# Step 3: Activate the virtual environment
echo_message "Activating the virtual environment..."
source ~/jupyter_env/bin/activate

# Step 4: Install Jupyter
echo_message "Installing Jupyter..."
pip install jupyter

# Step 5: Install the Colab Jupyter HTTP-over-WebSocket extension
echo_message "Installing the Colab Jupyter HTTP-over-WebSocket extension..."
pip install jupyter_http_over_ws

# Enable the extension
echo_message "Enabling the Jupyter HTTP-over-WebSocket extension..."
jupyter serverextension enable --py jupyter_http_over_ws

# Ensure Tailscale is installed
echo_message "Installing required packages..."
sudo apt-get update
sudo apt-get install -y tailscale || { echo_message "Failed to install Tailscale."; exit 1; }

# Create the run script
echo_message "Creating run script to start Jupyter Notebook with Tailscale..."
sudo tee $RUN_SCRIPT > /dev/null << 'EOF'
#!/bin/bash

# Ensure Tailscale is running
echo "Starting Tailscale..."
sudo tailscale up

# Get the Tailscale IP address
TAILSCALE_IP=$(tailscale ip)

# Check if Tailscale IP was fetched successfully
if [ -z "$TAILSCALE_IP" ]; then
    echo "Failed to get Tailscale IP. Please ensure Tailscale is running."
    exit 1
fi

echo "Tailscale IP: $TAILSCALE_IP"

# Activate the virtual environment
source ~/jupyter_env/bin/activate

# Start Jupyter Notebook bound to localhost and Tailscale IP
echo "Starting Jupyter Notebook..."
jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --ip=127.0.0.1 --ip=$TAILSCALE_IP --port=8888 --NotebookApp.port_retries=0
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Jupyter Colab
Icon=utilities-terminal
Exec=$RUN_SCRIPT
Comment=Run Jupyter Notebook for Google Colab using Tailscale
Categories=Development;Education;Science;
Terminal=true
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "Jupyter Colab setup complete. You can start Jupyter Notebook by running 'run_jupyter_colab.sh'."

# Instructions for connecting to the local runtime
echo_message "To connect to the local runtime:"
echo "1. In Colaboratory, click the Connect button and select 'Connect to local runtime...'."
echo "2. Enter the URL from the Jupyter server startup output in the dialog that appears and click the Connect button."
echo "You should now be connected to your local runtime."
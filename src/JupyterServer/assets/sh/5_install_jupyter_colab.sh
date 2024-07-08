#!/bin/bash

# Script to install Jupyter and the Colab extension in a virtual environment, and start a local Jupyter server

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

echo "Starting the installation of Jupyter and the Colab extension..."

# Step 1: Ensure python3-venv is installed
install_python_venv

# Step 2: Switch to the home directory and create a Python virtual environment
echo "Switching to the home directory..."
cd ~

echo "Creating a Python virtual environment..."
python3 -m venv ~/jupyter_env

# Step 3: Activate the virtual environment
echo "Activating the virtual environment..."
source ~/jupyter_env/bin/activate

# Step 4: Install Jupyter
echo "Installing Jupyter..."
pip install jupyter

# Step 5: Install the Colab Jupyter HTTP-over-WebSocket extension
echo "Installing the Colab Jupyter HTTP-over-WebSocket extension..."
pip install jupyter_http_over_ws

# Enable the extension
echo "Enabling the Jupyter HTTP-over-WebSocket extension..."
jupyter serverextension enable --py jupyter_http_over_ws

# Step 6: Start a local Jupyter server and authenticate
echo "Starting the local Jupyter server..."
echo "Note down the link you get from this screen. You will be using it in the next step."
jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0

# Instructions for connecting to the local runtime
echo "To connect to the local runtime:"
echo "1. In Colaboratory, click the Connect button and select 'Connect to local runtime...'."
echo "2. Enter the URL from the Jupyter server startup output in the dialog that appears and click the Connect button."
echo "You should now be connected to your local runtime."

echo "Installation and setup complete!"
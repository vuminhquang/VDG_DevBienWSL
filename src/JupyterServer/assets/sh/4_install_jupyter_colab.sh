#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Colab runtime installation variables
COLAB_NOTEBOOK_DIR="$HOME/colab_notebooks"
COLAB_SCRIPT_DIR="$HOME/colab_scripts"
COLAB_START_SCRIPT="$COLAB_SCRIPT_DIR/start_colab.sh"
COLAB_SERVICE="/etc/systemd/system/colab.service"

# Install Colab runtime dependencies
echo_message "Installing Colab runtime dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip || { echo_message "Failed to install Python packages."; exit 1; }
pip3 install jupyter jupyter_http_over_ws

# Set up Colab notebooks and scripts directories
echo_message "Setting up Colab directories..."
mkdir -p $COLAB_NOTEBOOK_DIR
mkdir -p $COLAB_SCRIPT_DIR

# Generate Jupyter Notebook configuration
echo_message "Generating Jupyter Notebook configuration..."
jupyter notebook --generate-config

# Create a Jupyter Notebook password
echo_message "Creating a Jupyter Notebook password..."
jupyter_password=$(python3 -c "from notebook.auth import passwd; print(passwd())")

# Add password and remote access configuration to Jupyter Notebook config file
config_file=~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.password = u'$jupyter_password'" >> $config_file
echo "c.NotebookApp.allow_origin = 'https://colab.research.google.com'" >> $config_file
echo "c.NotebookApp.disable_check_xsrf = True" >> $config_file
echo "c.NotebookApp.ip = '0.0.0.0'" >> $config_file
echo "c.NotebookApp.open_browser = False" >> $config_file
echo "c.NotebookApp.port = 8888" >> $config_file

# Create the start script for Colab
echo_message "Creating start script for Colab..."
sudo tee $COLAB_START_SCRIPT > /dev/null << EOF
#!/bin/bash
# Start Jupyter Notebook with WebSocket support for Colab
jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.disable_check_xsrf=True --notebook-dir=$COLAB_NOTEBOOK_DIR
EOF

sudo chmod +x $COLAB_START_SCRIPT || { echo_message "Failed to create start script."; exit 1; }

# Create a systemd service for Colab
echo_message "Creating systemd service for Colab..."
sudo tee $COLAB_SERVICE > /dev/null << EOF
[Unit]
Description=Colab Jupyter Notebook

[Service]
Type=simple
ExecStart=$COLAB_START_SCRIPT
WorkingDirectory=$COLAB_NOTEBOOK_DIR
User=$USER
Group=$USER
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Colab service
echo_message "Enabling and starting Colab service..."
sudo systemctl daemon-reload
sudo systemctl enable colab.service
sudo systemctl start colab.service

echo_message "Colab runtime installation complete and service started. You can now use your local runtime remotely from Colab."
echo_message "Your Jupyter Notebook password is: $jupyter_password"
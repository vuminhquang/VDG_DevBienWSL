#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Variables
RUN_SCRIPT="/usr/local/bin/run_jupyter_py_3_10.sh"
DESKTOP_ENTRY="/usr/share/applications/jupyter_py310.desktop"

# Function to install pyenv and pyenv-virtualenv if not already installed
install_pyenv() {
    if ! command -v pyenv &> /dev/null; then
        echo_message "pyenv is not installed. Installing it now..."
        curl https://pyenv.run | bash

        # Add pyenv to bashrc
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

        # Source bashrc to apply changes
        source ~/.bashrc
    else
        echo_message "pyenv is already installed."
    fi
}

echo_message "Starting the installation of Jupyter with Python 3.10..."

# Step 1: Ensure pyenv is installed
install_pyenv

# Step 2: Install Python 3.10 if not already installed
if ! pyenv versions | grep -q '3.10.12'; then
    echo_message "Installing Python 3.10.12..."
    pyenv install 3.10.12
else
    echo_message "Python 3.10.12 is already installed."
fi

# Step 3: Create a virtual environment with Python 3.10
echo_message "Creating and activating virtual environment..."
pyenv virtualenv 3.10.12 jupyter-py310
pyenv activate jupyter-py310

# Step 4: Install Jupyter and other necessary packages
echo_message "Installing Jupyter and other packages..."
pip install --upgrade pip
pip install jupyter ipykernel jupyter_http_over_ws

# Step 5: Install the IPython kernel for Jupyter
echo_message "Installing IPython kernel..."
python -m ipykernel install --user --name=jupyter-py310 --display-name "Python 3.10"

# Enable the extension
echo_message "Enabling the Jupyter HTTP-over-WebSocket extension..."
jupyter server extension enable --py jupyter_http_over_ws

# Create the run script
echo_message "Creating run script to start Jupyter Notebook..."
sudo tee $RUN_SCRIPT > /dev/null << 'EOF'
#!/bin/bash

# Activate the virtual environment
source ~/.pyenv/versions/jupyter-py310/bin/activate

# Start Jupyter Notebook
echo "Starting Jupyter Notebook..."
jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0

# Deactivate the virtual environment after Jupyter Notebook stops
deactivate
EOF

sudo chmod +x $RUN_SCRIPT || { echo_message "Failed to create run script."; exit 1; }

# Create a desktop entry
echo_message "Creating desktop entry..."
sudo tee $DESKTOP_ENTRY > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Jupyter Python 3.10
Icon=utilities-terminal
Exec=$RUN_SCRIPT
Comment=Run Jupyter Notebook with Python 3.10 for Google Colab
Categories=Development;Education;Science;
Terminal=true
EOF

sudo chmod +r $DESKTOP_ENTRY || { echo_message "Failed to create desktop entry."; exit 1; }

echo_message "Jupyter setup with Python 3.10 complete. You can start Jupyter Notebook by running 'run_jupyter_py_3_10.sh'."

# Instructions for connecting to the local runtime
echo_message "To connect to the local runtime:"
echo "1. In Colaboratory, click the Connect button and select 'Connect to local runtime...'."
echo "2. Enter the URL from the Jupyter server startup output in the dialog that appears and click the Connect button."
echo "You should now be connected to your local runtime."

# Deactivate the virtual environment
pyenv deactivate
#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

sudo apt update

# Install prerequisites
sudo apt install -y software-properties-common

# Add the deadsnakes PPA for newer Python versions
sudo add-apt-repository ppa:deadsnakes/ppa

# Update the package list again after adding the new PPA
sudo apt update

# Install Python 3.12
sudo apt install -y python3.12

# Tailscale installation variables
TAILSCALE_SERVICE="/etc/systemd/system/tailscale.service"

# Install Tailscale
echo_message "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale service
echo_message "Starting Tailscale service..."
sudo systemctl enable --now tailscaled

# Authenticate to Tailscale
echo_message "Authenticating to Tailscale..."
sudo tailscale up

# Create a systemd service for Tailscale
echo_message "Creating systemd service for Tailscale..."
sudo tee $TAILSCALE_SERVICE > /dev/null << EOF
[Unit]
Description=Tailscale
After=network.target

[Service]
ExecStart=/usr/sbin/tailscaled
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Tailscale service
echo_message "Enabling and starting Tailscale service..."
sudo systemctl daemon-reload
sudo systemctl enable tailscale.service
sudo systemctl start tailscale.service

echo_message "Tailscale installation complete and service started."
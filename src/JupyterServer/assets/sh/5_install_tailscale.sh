#!/bin/bash
set -e

echo_message() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Tailscale installation variables
TAILSCALE_SERVICE="/etc/systemd/system/tailscale.service"

# Install Tailscale
echo_message "Installing Tailscale..."
#curl -fsSL https://tailscale.com/install.sh | sh
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/kinetic.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/kinetic.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install tailscale

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
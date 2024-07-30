#!/bin/bash

echo "Installing Tailscale..."

# Add the Tailscale repository to sources list
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).list | sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null

# Update package lists and install Tailscale
sudo apt update
sudo apt install -y tailscale

# Start and enable Tailscale service
sudo systemctl enable --now tailscaled

# Authenticate and connect Tailscale
sudo tailscale up

echo "Tailscale installation complete."
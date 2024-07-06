#!/bin/bash
set -e

# Update and install necessary packages
apt-get update
apt-get upgrade -y
apt-get install -y sudo iproute2 curl wget dbus

# Create user
useradd -m -s /bin/bash $username
echo "$username:$passwordPlain" | chpasswd
echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure default user in wsl.conf
mkdir -p /etc
echo "[user]" >> /etc/wsl.conf
echo "default=$username" >> /etc/wsl.conf

# Clean up
rm /root/setup_debian.sh
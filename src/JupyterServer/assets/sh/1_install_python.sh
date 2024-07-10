#!/bin/bash

# Detect the Linux distribution and version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo "Cannot detect the OS type."
    exit 1
fi

# Function to install python3.12-venv
install_python_venv() {
    case $OS in
        ubuntu | debian)
            sudo apt-get update
            sudo apt-get install -y python3.12 python3.12-venv
            ;;
        fedora)
            sudo dnf install -y python3.12 python3.12-venv
            ;;
        centos | rhel)
            sudo yum install -y python3.12 python3.12-venv
            ;;
        opensuse)
            sudo zypper install -y python3.12 python3.12-venv
            ;;
        arch)
            sudo pacman -Syu --noconfirm python3.12 python3.12-venv
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    echo "Python 3.12 and python3.12-venv have been installed."
}

# Install python3.12-venv
install_python_venv
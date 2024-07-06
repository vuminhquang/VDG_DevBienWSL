#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if Git is already installed
check_git_installed() {
  if command -v git &> /dev/null; then
    echo "Git is already installed."
    exit 0
  fi
}

# Function to install Git
install_git() {
  echo "Updating package list..."
  sudo apt-get update -y

  echo "Installing Git..."
  sudo apt-get install -y git

  echo "Git installation completed."
}

# Function to ensure Git is in the PATH
ensure_git_in_path() {
  if ! command -v git &> /dev/null; then
    echo "Error: Git is not in the PATH. Please check your installation."
    exit 1
  else
    echo "Git is successfully installed and in the PATH."
  fi
}

# Function to clean up unnecessary files
cleanup() {
  echo "Cleaning up..."
  sudo apt-get clean
  sudo apt-get autoremove -y

  echo "Cleanup completed."
}

# Check if Git is already installed
check_git_installed

# Install Git
install_git

# Ensure Git is in the PATH
ensure_git_in_path

# Clean up
cleanup
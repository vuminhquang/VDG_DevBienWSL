#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display messages
message() {
    echo -e "\e[32m$1\e[0m"
}

# Function to display error messages
error() {
    echo -e "\e[31m$1\e[0m" >&2
}

# Update package lists and install necessary packages
message "Updating package lists..."
sudo apt-get update -y

message "Installing basic build tools..."
sudo apt-get install -y build-essential dkms

# Remove old GPG key if it exists
message "Removing old CUDA GPG key..."
sudo apt-key del 7fa2af80 || true

# Detect distribution
distribution=$(source /etc/os-release && echo $ID$VERSION_ID)

# Add NVIDIA package repositories based on detected distribution
message "Adding CUDA and cuDNN repositories for $distribution..."

if ! curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -; then
    error "Failed to add NVIDIA Docker GPG key"
    exit 1
fi

if ! curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list; then
    error "Failed to add NVIDIA Docker repository"
    exit 1
fi

if ! sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub; then
    error "Failed to add CUDA GPG key"
    exit 1
fi

if ! echo "deb https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list; then
    error "Failed to add CUDA repository"
    exit 1
fi

if ! echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda_learn.list; then
    error "Failed to add cuDNN repository"
    exit 1
fi

# Update package lists after adding new repositories
message "Updating package lists..."
sudo apt-get update -y

# Install CUDA toolkit and cuDNN
message "Installing CUDA toolkit and cuDNN..."
if ! sudo apt-get install -y cuda-toolkit-12-x libcudnn8 libcudnn8-dev nvidia-container-runtime; then
    error "Failed to install CUDA and cuDNN"
    exit 1
fi

# Verify installation
message "Verifying CUDA installation..."
if ! nvidia-smi; then
    error "nvidia-smi command failed. CUDA installation may be incorrect."
    exit 1
fi

if ! nvcc --version; then
    error "nvcc command failed. CUDA toolkit installation may be incorrect."
    exit 1
fi

message "CUDA and cuDNN installation was successful."
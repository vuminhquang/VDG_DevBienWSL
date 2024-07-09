#!/bin/bash

set -e

# Define the base URL and the destination directory
BASE_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/"
DEST_DIR="$HOME/nvidia-cuda-packages"

# Create the destination directory
mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

# List of essential packages to download
PACKAGES=(
  "cuda-toolkit-12-5_12.5.1-1_amd64.deb"
  "cuda-drivers-555_555.42.06-1_amd64.deb"
  "cuda-runtime-12-5_12.5.1-1_amd64.deb"
  "libcudnn9-cuda-12_9.2.1.18-1_amd64.deb"
  "libcudnn9-dev-cuda-12_9.2.1.18-1_amd64.deb"
  "cuda-command-line-tools-12-5_12.5.1-1_amd64.deb"
  "cuda-compiler-12-5_12.5.1-1_amd64.deb"
  "cuda-nvcc-12-5_12.5.82-1_amd64.deb"
)

# Download the essential packages
echo "Downloading NVIDIA CUDA and cuDNN packages..."
for package in "${PACKAGES[@]}"; do
  if [ ! -f "$package" ]; then
    wget "${BASE_URL}${package}" -P "$DEST_DIR"
  else
    echo "$package already exists, skipping download."
  fi
done

# Extract dependencies from downloaded packages
DEPENDENCIES=()
for package in "${PACKAGES[@]}"; do
  DEPS=$(dpkg-deb -f "$package" Depends | sed 's/, /\n/g' | awk -F ' ' '{print $1}')
  DEPENDENCIES+=($DEPS)
done

# Remove duplicate dependencies
DEPENDENCIES=($(echo "${DEPENDENCIES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Function to download the latest version of a dependency
download_latest_dependency() {
  local dep=$1
  local file_list=$(wget -qO- "${BASE_URL}" | grep -oP "${dep}[_a-zA-Z0-9.-]*\.deb" | head -n 1)
  if [ -n "$file_list" ]; then
    local latest_dep=$(echo "$file_list" | awk -F '[<>]' '{print $1}')
    if [ ! -f "${latest_dep}" ]; then
      wget "${BASE_URL}${latest_dep}" -P "$DEST_DIR" || echo "Failed to download dependency: $latest_dep"
    else
      echo "$latest_dep already exists, skipping download."
    fi
  else
    echo "Dependency not found: $dep"
  fi
}

# Download dependencies
echo "Downloading dependencies..."
for dep in "${DEPENDENCIES[@]}"; do
  download_latest_dependency "$dep"
done

# Update the package list and install the required dependencies
echo "Updating package list and installing dependencies..."
sudo apt update
sudo apt install -y build-essential dkms

# Install the downloaded packages
echo "Installing downloaded packages..."
for package in "${PACKAGES[@]}"; do
  sudo dpkg -i "$package"
done

# Install the downloaded dependencies
echo "Installing dependencies..."
for dep in "${DEPENDENCIES[@]}"; do
  sudo dpkg -i "${DEST_DIR}/$(basename $dep)"*.deb || true
done

# Fix any dependency issues
echo "Fixing dependencies..."
sudo apt-get install -f -y

# Verify installation
echo "Verifying CUDA installation..."
nvcc --version || echo "CUDA installation verification failed."

echo "Verifying cuDNN installation..."
cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2 || echo "cuDNN installation verification failed."

echo "Verifying NVIDIA driver installation..."
nvidia-smi || echo "NVIDIA driver installation verification failed."

echo "Installation completed successfully!"
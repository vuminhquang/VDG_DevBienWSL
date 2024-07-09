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

# Detect distribution
distribution=$(source /etc/os-release && echo $ID$VERSION_ID)

# Build the base URL
BASE_URL="https://developer.download.nvidia.com/compute/cuda/repos/${distribution}/x86_64/"

# Default version (can be set by the user, otherwise the script will get the latest version)
DEFAULT_VERSION=""

# Essential CUDA packages
ESSENTIAL_CUDA_PACKAGES=(
    "cuda-toolkit"
    "cuda-runtime"
    "cuda-compiler"
)

# Essential cuDNN packages
ESSENTIAL_CUDNN_PACKAGES=(
    "libcudnn9-cuda"
    "libcudnn9-dev-cuda"
)

# Function to download and install a package
install_package() {
    package=$1
    wget -q ${BASE_URL}${package}
    sudo dpkg -i ${package} || true  # Allow failures to handle dependencies
    rm ${package}
}

# Function to resolve dependencies by parsing dpkg errors
resolve_dependencies() {
    dpkg_errors=$(sudo dpkg --configure -a 2>&1 | grep "dependency problems" || true)
    if [[ ! -z "$dpkg_errors" ]]; then
        missing_packages=$(echo "$dpkg_errors" | grep "depends on" | sed -e 's/.*depends on //' -e 's/,.*//' -e 's/)//' | sort -u)
        for pkg in $missing_packages; do
            if ! dpkg -s $pkg >/dev/null 2>&1; then
                install_package ${pkg}_*.deb
            fi
        done
    fi
}

# Download and parse the index page
message "Downloading and parsing the index page..."
index_page=$(wget -qO- ${BASE_URL})

# Extract package names from the index page
extract_packages() {
    pattern=$1
    echo "$index_page" | grep -oP "${pattern}" | sort -u
}

# Extract all packages
all_packages=$(extract_packages "[a-zA-Z0-9._-]+\.deb")

# Function to get the latest or default version package
get_latest_package() {
    package_base=$1
    version_prefix=$2
    if [[ -z "$DEFAULT_VERSION" ]]; then
        package_file=$(echo "$all_packages" | grep -P "^${package_base}-${version_prefix}_[0-9.]+_*_amd64.deb$" | sort -V | tail -1)
    else
        package_file=$(echo "$all_packages" | grep -P "^${package_base}-${version_prefix}_${DEFAULT_VERSION}[0-9.]*_*_amd64.deb$" | sort -V | tail -1)
    fi
    echo $package_file
}

# Download and install essential CUDA packages
message "Downloading and installing essential CUDA packages..."
for package_base in "${ESSENTIAL_CUDA_PACKAGES[@]}"; do
    version_prefix="12-5"
    package_file=$(get_latest_package ${package_base} ${version_prefix})
    if [[ ! -z "$package_file" ]]; then
        install_package ${package_file}
        resolve_dependencies
    fi
done

# Download and install essential cuDNN packages
message "Downloading and installing essential cuDNN packages..."
for package_base in "${ESSENTIAL_CUDNN_PACKAGES[@]}"; do
    version_prefix="12"
    package_file=$(get_latest_package ${package_base} ${version_prefix})
    if [[ ! -z "$package_file" ]]; then
        install_package ${package_file}
        resolve_dependencies
    fi
done

# Fix any remaining broken dependencies
message "Fixing broken dependencies..."
sudo apt-get install -f -y

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
#!/bin/bash

# Step 1: Get the URL of the latest release
latest_release_url=$(curl -s https://api.github.com/repos/erebe/wstunnel/releases/latest | grep "html_url" | cut -d '"' -f 4 | head -n 1)

if [ -z "$latest_release_url" ]; then
    echo "Unable to fetch the latest release information."
    exit 1
fi

echo "Latest release URL: $latest_release_url"

# Step 2: Extract the version information from the URL
version=$(echo $latest_release_url | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+')

if [ -z "$version" ]; then
    echo "Unable to extract version information."
    exit 1
fi

echo "Latest version: $version"

# Step 3: Construct the URL of the wstunnel_linux_amd64.tar.gz file
download_url="https://github.com/erebe/wstunnel/releases/download/$version/wstunnel_${version}_linux_amd64.tar.gz"

# Step 4: Download the file
wget -O wstunnel_linux_amd64.tar.gz $download_url

if [ $? -ne 0 ]; then
    echo "Failed to download file from $download_url"
    exit 1
fi

# Step 5: Extract the tar.gz file
tar -xzf wstunnel_linux_amd64.tar.gz

# Step 6: Move the executable to /usr/local/bin
sudo mv wstunnel /usr/local/bin/

# Step 7: Grant execution permissions to the file
sudo chmod +x /usr/local/bin/wstunnel

# Step 8: Verify the installed version
wstunnel --version

if [ $? -ne 0 ]; then
    echo "Installation failed."
    exit 1
fi

echo "Successfully installed WSTunnel version $version"
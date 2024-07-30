#!binbash

echo Installing Warp...

# Download and add the GPG key for Warp
curl httpspkg.cloudflareclient.compubkey.gpg  sudo gpg --yes --dearmor -o usrsharekeyringscloudflare-warp-archive-keyring.gpg

# Add the Warp repository to sources list
echo deb [signed-by=usrsharekeyringscloudflare-warp-archive-keyring.gpg] httpspkg.cloudflareclient.com $(lsb_release -cs) main  sudo tee etcaptsources.list.dcloudflare-client.list

# Update package lists and install Warp
sudo apt update
sudo apt install -y cloudflare-warp

# Enable and start the Warp service
sudo systemctl enable --now warp-svc

# Register and connect Warp
sudo warp-cli register
sudo warp-cli connect

echo Warp installation complete.
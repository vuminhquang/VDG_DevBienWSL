wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt-get install -y cuda-toolkit

# Verify installation
echo "Verifying CUDA installation..."
#nvcc --version || echo "CUDA installation verification failed."

#echo "Verifying cuDNN installation..."
#cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2 || echo "cuDNN installation verification failed."

#echo "Verifying NVIDIA driver installation..."
nvidia-smi || echo "CUDA installation verification failed."

echo "Installation completed successfully!"
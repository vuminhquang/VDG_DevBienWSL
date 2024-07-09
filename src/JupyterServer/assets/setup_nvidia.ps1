param (
    [string]$wslName,
    [string]$username
)

# Function to display messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

# Function to download a file
function Download-File {
    param (
        [string]$url,
        [string]$outputPath,
        [int]$maxRetries = 3
    )
    $attempt = 0
    while ($attempt -lt $maxRetries) {
        try {
            Write-Message "Attempting to download $url (Attempt $($attempt + 1) of $maxRetries)..."
            Invoke-WebRequest -Uri $url -OutFile $outputPath
            Write-Message "Download successful!"
            return $true
        } catch {
            Write-Host "Error downloading file: $_" -ForegroundColor Red
            $attempt++
            if ($attempt -ge $maxRetries) {
                Write-Host "Failed to download file after $maxRetries attempts." -ForegroundColor Red
                return $false
            }
            Start-Sleep -Seconds 5
        }
    }
}

# Function to check if NVIDIA driver is installed
function Check-NvidiaDriver {
    try {
        $driverVersion = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceClass -eq "Display" -and $_.Manufacturer -like "NVIDIA*" } | Select-Object -First 1
        if ($driverVersion) {
            Write-Message "NVIDIA driver is already installed (Version: $($driverVersion.DriverVersion))."
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Host "Error checking NVIDIA driver: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check if GeForce Experience is installed
function Check-GeForceExperience {
    try {
        $geforceExperience = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = 'NVIDIA GeForce Experience'" | Select-Object -First 1
        if ($geforceExperience) {
            Write-Message "GeForce Experience is already installed (Version: $($geforceExperience.Version))."
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Host "Error checking GeForce Experience: $_" -ForegroundColor Red
        return $false
    }
}

# Ensure WSL 2 is installed and usable
Write-Message "Checking WSL version..."
wsl --set-default-version 2

# Check if NVIDIA driver is installed
if (-not (Check-NvidiaDriver)) {
    # Download and install the latest NVIDIA driver for Windows
    $nvidiaDriverUrl = "https://us.download.nvidia.com/Windows/555.99/555.99-desktop-win10-win11-64bit-international-dch-whql.exe"
    $nvidiaDriverPath = Join-Path -Path $env:TEMP -ChildPath "nvidia_driver.exe"

    Write-Message "Downloading the latest NVIDIA driver..."
    if (Download-File -url $nvidiaDriverUrl -outputPath $nvidiaDriverPath) {
        Write-Message "Installing the NVIDIA driver..."
        Start-Process -FilePath $nvidiaDriverPath -ArgumentList "/s" -Wait
        Write-Message "NVIDIA driver installed successfully."
    } else {
        Write-Host "Failed to download NVIDIA driver. Aborting setup." -ForegroundColor Red
        exit 1
    }
}

# Check if GeForce Experience is installed
if (-not (Check-GeForceExperience)) {
    # Download and install GeForce Experience
    $geforceExperienceUrl = "https://us.download.nvidia.com/GFE/GFEClient/3.23.0.74/GeForce_Experience_v3.23.0.74.exe"
    $geforceExperiencePath = Join-Path -Path $env:TEMP -ChildPath "geforce_experience.exe"

    Write-Message "Downloading GeForce Experience..."
    if (Download-File -url $geforceExperienceUrl -outputPath $geforceExperiencePath) {
        Write-Message "Installing GeForce Experience..."
        try {
            Start-Process -FilePath $geforceExperiencePath -ArgumentList "/silent" -Wait
            Write-Message "GeForce Experience installed successfully."
        } catch {
            Write-Host "Failed to install GeForce Experience. Continuing with setup." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Failed to download GeForce Experience. Continuing with setup." -ForegroundColor Yellow
    }
}

# Create a script to set up CUDA and NVIDIA runtime in WSL
$setupCudaScript = @'
#!/bin/bash
set -e

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y build-essential

# Add NVIDIA package repositories
distribution=$(source /etc/os-release && echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install CUDA toolkit and NVIDIA container runtime
sudo apt-get update
sudo apt-get install -y cuda libcudnn8 libcudnn8-dev nvidia-container-runtime

# Verify installation
nvidia-smi
nvcc --version

echo "CUDA and NVIDIA runtime installed successfully."
'@

# Save the script to a temporary file
$setupCudaScriptPath = Join-Path -Path $env:TEMP -ChildPath "setup_cuda.sh"
$setupCudaScript | Set-Content -Path $setupCudaScriptPath -NoNewline -Encoding UTF8

# Convert Windows path to WSL path
function Convert-WindowsPathToWslPath {
    param (
        [string]$windowsPath
    )
    $wslPath = $windowsPath -replace '\\', '/'
    $wslPath = $wslPath -replace ':', ''
    return "/mnt/" + $wslPath.Substring(0, 1).ToLower() + $wslPath.Substring(1)
}

$setupCudaWslPath = Convert-WindowsPathToWslPath -windowsPath $setupCudaScriptPath

# Copy and run the setup script in WSL
Write-Message "Setting up CUDA and NVIDIA runtime in WSL..."
wsl --distribution $wslName --user $username cp $setupCudaWslPath /home/$username/setup_cuda.sh
wsl --distribution $wslName --user $username chmod +x /home/$username/setup_cuda.sh
wsl --distribution $wslName --user $username bash /home/$username/setup_cuda.sh

Write-Message "NVIDIA GPU setup in WSL completed successfully!"
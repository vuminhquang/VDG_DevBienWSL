# PowerShell script to automate setting up Debian on WSL

# Function to display messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

# Function to prompt for a path
function Prompt-ForPath {
    param (
        [string]$promptMessage
    )
    $path = Read-Host $promptMessage
    while (-not (Test-Path -Path $path)) {
        Write-Host "Invalid path. Please enter a valid directory path." -ForegroundColor Red
        $path = Read-Host $promptMessage
    }
    return $path
}

# Function to convert a file to Unix format
function Convert-ToUnixFormat {
    param (
        [string]$filePath
    )

    $content = Get-Content -Raw -Path $filePath
    $content = $content -replace "`r`n", "`n"
    Set-Content -Path $filePath -Value $content -NoNewline
}

# Directory to store setup data
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$setupDataDirectory = Join-Path -Path $scriptDirectory -ChildPath "setup_data"

# Ensure the setup_data directory exists
if (-Not (Test-Path -Path $setupDataDirectory)) {
    New-Item -ItemType Directory -Path $setupDataDirectory | Out-Null
}

# Prompt user for the WSL instance name
$wslName = Read-Host "Enter the name for your WSL instance (e.g., MyDebian)"

# Save the WSL instance name to a file for later cleanup
$wslNameFile = Join-Path -Path $setupDataDirectory -ChildPath "wsl_name.txt"
Set-Content -Path $wslNameFile -Value $wslName
Write-Message "WSL instance name saved to $wslNameFile"

# Prompt user for the path to store WSL
$wslStoragePath = Prompt-ForPath -promptMessage "Enter the path where you want WSL to store `${wslName}:"

# Save the storage path to a file for later cleanup
$storagePathFile = Join-Path -Path $setupDataDirectory -ChildPath "wsl_storage_path.txt"
Set-Content -Path $storagePathFile -Value $wslStoragePath
Write-Message "Storage path saved to $storagePathFile"

# Prompt user for the desired username and password
$username = Read-Host "Enter the username you want to create in $wslName"
$password = Read-Host "Enter the password for the user $username (leave blank to use default 'password')" -AsSecureString

if ($password.Length -eq 0) {
    $passwordPlain = "password"
} else {
    $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
}

# URL of the Debian root filesystem tar.xz
$debianTarUrl = "https://github.com/debuerreotype/docker-debian-artifacts/raw/8d227a7d1f698c702d82e7de764ed0a7df65fb7c/bookworm/slim/rootfs.tar.xz"
$debianTarPath = Join-Path -Path $env:TEMP -ChildPath "debian_rootfs.tar.xz"

# Define a function to download the file with retries
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

# Attempt to download the Debian tar file
if (-Not (Download-File -url $debianTarUrl -outputPath $debianTarPath)) {
    Write-Host "Aborting setup due to download failure." -ForegroundColor Red
    exit 1
}

# Import the Debian instance to the specified path
Write-Message "Importing the $wslName instance to the specified path..."
wsl --import $wslName $wslStoragePath $debianTarPath --version 2

# Remove the downloaded tar file
Write-Message "Cleaning up the downloaded tar file..."
Remove-Item -Path $debianTarPath

# Convert a Windows path to a WSL path
function Convert-WindowsPathToWslPath {
    param (
        [string]$windowsPath
    )
    $wslPath = $windowsPath -replace '\\', '/'
    $wslPath = $wslPath -replace ':', ''
    return "/mnt/" + $wslPath.Substring(0, 1).ToLower() + $wslPath.Substring(1)
}

# Create setup_debian.sh if it doesn't already exist
$setupScriptPath = Join-Path -Path $scriptDirectory -ChildPath "assets/setup_debian.sh"
if (-Not (Test-Path -Path $setupScriptPath)) {
@'
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
'@ -replace "`r`n", "`n" | Set-Content -Path $setupScriptPath -Force -NoNewline -Encoding UTF8
}

# Convert setup script path to WSL path and copy to root
$setupScriptWslPath = Convert-WindowsPathToWslPath -windowsPath $setupScriptPath
wsl --distribution $wslName --user root cp $setupScriptWslPath /root/setup_debian.sh
wsl --distribution $wslName --user root chmod +x /root/setup_debian.sh

# Define the environment variables to pass to WSL
$envVars = @"
username=$username
passwordPlain=$passwordPlain
"@

# Convert the environment variables to a single line
$envVars = $envVars -replace "\r\n", " "
# Print out the environment variables for debugging
Write-Output "Environment Variables to be passed:"
Write-Output $envVars

# Run the setup script in WSL
Write-Message "Running the setup script in WSL..."
wsl --distribution $wslName --user root -- bash -c "$envVars bash /root/setup_debian.sh"

# New Section: Run asset/setup_nvidia.ps1
$setupNvidiaScriptPath = Join-Path -Path $scriptDirectory -ChildPath "asset/setup_nvidia.ps1"
if (Test-Path -Path $setupNvidiaScriptPath)) {
    Write-Message "Running PowerShell script asset/setup_nvidia.ps1 locally..."
    & $setupNvidiaScriptPath
} else {
    Write-Message "No PowerShell script found at asset/setup_nvidia.ps1."
}

# New Section: Execute all .ps1 files in assets/ps1
$ps1Directory = Join-Path -Path $scriptDirectory -ChildPath "assets/ps1"
if (Test-Path -Path $ps1Directory) {
    $ps1Files = Get-ChildItem -Path $ps1Directory -Filter *.ps1
    foreach ($file in $ps1Files) {
        Write-Message "Running PowerShell script $($file) locally..."
        & $file.FullName
    }
} else {
    Write-Message "No PowerShell scripts found in assets/ps1."
}

# New Section: Execute all .sh files in assets/sh
$shDirectory = Join-Path -Path $scriptDirectory -ChildPath "assets/sh"
if (Test-Path -Path $shDirectory) {
    $shFiles = Get-ChildItem -Path $shDirectory -Filter *.sh
    foreach ($file in $shFiles) {
        Write-Message "Converting script $($file) to Unix format..."
        Convert-ToUnixFormat -filePath $file

        $fileWslPath = Convert-WindowsPathToWslPath -windowsPath $file.FullName
        Write-Message "Running script $fileWslPath in WSL..."
        wsl --distribution $wslName --user $username bash $fileWslPath
    }
} else {
    Write-Message "No scripts found in assets/sh."
}

# Restart the WSL instance
Write-Message "Restarting the $wslName instance..."
wsl --terminate $wslName

# Refresh desktop items in Windows
Write-Message "Refreshing desktop items in Windows..."
wsl.exe --update

Write-Message "Setup completed successfully!"
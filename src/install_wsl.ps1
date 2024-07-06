# PowerShell script to enable the newest version of WSL on Windows 11

function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

function Check-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-Not (Check-Admin)) {
    Write-Host "This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

Write-Message "Checking for existing WSL distributions..."

$wslList = wsl --list --quiet

if ($wslList) {
    Write-Message "Found existing WSL distributions. Removing them..."
    foreach ($distro in $wslList) {
        Write-Message "Unregistering WSL distribution: $distro"
        wsl --unregister $distro
    }
} else {
    Write-Message "No existing WSL distributions found."
}

Write-Message "Disabling WSL feature if already enabled..."
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart

Write-Message "Disabling Virtual Machine Platform feature if already enabled..."
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

Write-Message "Restarting the system to apply changes..."
Restart-Computer -Force

# The script will continue after the reboot
Write-Message "Enabling the WSL feature..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Message "Enabling the Virtual Machine Platform feature..."
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Message "Restarting the system to apply changes..."
Restart-Computer -Force

# The script will continue after the second reboot
Write-Message "Installing the latest version of WSL from the Microsoft Store..."
Invoke-WebRequest -Uri "https://aka.ms/wslstorepage" -OutFile "$env:TEMP\wsl.msixbundle"
Start-Process "explorer.exe" -ArgumentList "$env:TEMP\wsl.msixbundle"

Write-Message "Setting WSL 2 as the default version..."
wsl --set-default-version 2

Write-Message "Installing the latest WSL kernel update..."
wsl --update

Write-Message "Verifying WSL installation..."
wsl --version

Write-Message "Installation and setup of WSL completed successfully!"
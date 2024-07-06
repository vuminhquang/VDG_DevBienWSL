# PowerShell script to complete WSL setup after the second reboot

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

# Remove the scheduled task
$taskName = "CompleteWSLSetup2"
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
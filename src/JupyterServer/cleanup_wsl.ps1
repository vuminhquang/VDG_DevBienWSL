# PowerShell script to clean up WSL instance and setup data

# Function to display messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

# Function to prompt for confirmation
function Confirm-Action {
    param (
        [string]$message
    )
    $confirmation = Read-Host "$message (Y/N)"
    while ($confirmation -notin @("Y", "N", "y", "n")) {
        Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
        $confirmation = Read-Host "$message (Y/N)"
    }
    return $confirmation -match "^[Yy]$"
}

# Directory to store setup data
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$setupDataDirectory = Join-Path -Path $scriptDirectory -ChildPath "setup_data"

# Read the WSL instance name from the file
$wslNameFile = Join-Path -Path $setupDataDirectory -ChildPath "wsl_name.txt"
if (Test-Path -Path $wslNameFile) {
    $wslName = Get-Content -Path $wslNameFile
    Write-Message "WSL instance name read from $($wslNameFile): $($wslName)"
} else {
    Write-Host "WSL instance name file not found. Exiting cleanup." -ForegroundColor Red
    exit 1
}

# Prompt for confirmation before proceeding with cleanup
if (-not (Confirm-Action -message "Are you sure you want to unregister and delete the WSL instance '$wslName' and related data?")) {
    Write-Host "Cleanup aborted by user." -ForegroundColor Yellow
    exit 0
}

# Unregister the WSL instance
Write-Message "Unregistering the $wslName instance..."
wsl --unregister $wslName

# Read the storage path from the file
$storagePathFile = Join-Path -Path $setupDataDirectory -ChildPath "wsl_storage_path.txt"
if (Test-Path -Path $storagePathFile) {
    $wslStoragePath = Get-Content -Path $storagePathFile
    Write-Message "Storage path read from $($storagePathFile): $($wslStoragePath)"

    # Remove the storage path directory if it exists
    if (Test-Path -Path $wslStoragePath) {
        Write-Message "Removing the storage path directory..."
        Remove-Item -Path $wslStoragePath -Recurse -Force
    } else {
        Write-Host "Storage path directory not found." -ForegroundColor Red
    }
}

# Remove the setup data directory
Write-Message "Removing the setup data directory..."
Remove-Item -Path $setupDataDirectory -Recurse -Force

Write-Message "Cleanup completed successfully!"
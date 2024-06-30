# PowerShell script to clean up (uninstall) an existing Debian WSL instance

# Function to display messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

# Function to read the storage path from the file
function Get-StoragePath {
    param (
        [string]$filePath
    )
    if (Test-Path -Path $filePath) {
        return Get-Content -Path $filePath -Raw
    } else {
        Write-Host "Storage path file not found: $filePath" -ForegroundColor Red
        return $null
    }
}

# Directory to store setup data
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$setupDataDirectory = Join-Path -Path $scriptDirectory -ChildPath "setup_data"

# Read the storage path from the file
$storagePathFile = Join-Path -Path $setupDataDirectory -ChildPath "debian_storage_path.txt"
$storagePath = Get-StoragePath -filePath $storagePathFile

# Unregister the Debian WSL instance if it exists
Write-Message "Checking for existing Debian WSL instance..."

# Get the list of WSL distributions
$wslListOutput = wsl -l -q
Write-Message "WSL list output: $wslListOutput"

# Split the output into lines and trim whitespace from each line
$wslDistros = $wslListOutput -split "`r?`n" | ForEach-Object { $_.Trim() }
Write-Message "WSL distributions: $($wslDistros -join ', ')"

# Check if any of the distribution names is "Debian"
if ($wslDistros -contains "Debian") {
    Write-Message "Unregistering the existing Debian WSL instance..."
    wsl --unregister Debian
    Write-Message "Debian WSL instance unregistered successfully."
} else {
    Write-Message "No Debian WSL instance found."
}

if ($storagePath) {
    # Remove the Debian files from the storage path
    if (Test-Path -Path $storagePath) {
        Write-Message "Removing Debian files from $storagePath..."
        Remove-Item -Path $storagePath -Recurse -Force
        Write-Message "Debian files removed successfully from $storagePath."
    } else {
        Write-Message "The specified path does not exist: $storagePath"
    }

    # Remove the storage path file
    Write-Message "Removing the storage path file..."
    Remove-Item -Path $storagePathFile -Force
    Write-Message "Storage path file removed successfully."
} else {
    Write-Message "No storage path file found, skipping storage path cleanup."
}

# Remove the add-ins state file
$addinsStateFile = Join-Path -Path $setupDataDirectory -ChildPath "addins_state.json"
if (Test-Path -Path $addinsStateFile) {
    Write-Message "Removing the add-ins state file..."
    Remove-Item -Path $addinsStateFile -Force
    Write-Message "Add-ins state file removed successfully."
} else {
    Write-Message "No add-ins state file found, skipping add-ins state cleanup."
}

Write-Message "WSL cleanup completed."
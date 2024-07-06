# PowerShell script to copy files to a WSL user's home directory

# Function to display messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Host -ForegroundColor Green "$message"
}

# Function to convert a Windows path to a WSL path
function Convert-WindowsPathToWslPath {
    param (
        [string]$windowsPath
    )
    $wslPath = $windowsPath -replace '\\', '/'
    $wslPath = $wslPath -replace ':', ''
    return "/mnt/" + $wslPath.Substring(0, 1).ToLower() + $wslPath.Substring(1)
}

# Function to copy files to WSL user's home directory
function Copy-FilesToWsl {
    param (
        [string]$srcDir,
        [string]$wslUsername,
        [string]$wslDistro = "Debian"
    )

    $wslHome = "/home/$wslUsername/addins"
    $srcFiles = Get-ChildItem -Path $srcDir

    # Create the target directory in WSL if it doesn't exist
    Write-Message "Creating target directory $wslHome in WSL..."
    wsl --distribution $wslDistro --user $wslUsername mkdir -p $wslHome

    foreach ($file in $srcFiles) {
        $fileWslPath = Convert-WindowsPathToWslPath -windowsPath $file.FullName
        Write-Message "Copying $fileWslPath to $wslHome..."
        wsl --distribution $wslDistro --user $wslUsername cp $fileWslPath $wslHome
    }

    Write-Message "Files copied successfully to $wslHome."
}

# Prompt user for the WSL username
$username = Read-Host "Enter the WSL username"

# Define the source directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$srcDirectory = Join-Path -Path $scriptDirectory -ChildPath "assets/addins/library_debian"

# Check if the source directory exists
if (-Not (Test-Path -Path $srcDirectory)) {
    Write-Host "Source directory $srcDirectory does not exist." -ForegroundColor Red
    exit 1
}

# Copy files to the WSL user's home directory
Copy-FilesToWsl -srcDir $srcDirectory -wslUsername $username
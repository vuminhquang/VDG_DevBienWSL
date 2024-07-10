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

Write-Message "NVIDIA GPU setup in WSL completed successfully!"
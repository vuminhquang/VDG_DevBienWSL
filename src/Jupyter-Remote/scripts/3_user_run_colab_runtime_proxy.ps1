param (
    [string]$RemoteUser,
    [string]$RemoteTailscaleIP,
    [int]$Port = 8888
)

# Function to check if a command exists
function CommandExists {
    param (
        [string]$Command
    )
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to check if Tailscale is running
function IsTailscaleRunning {
    $tailscaleStatus = & tailscale status 2>&1
    return $tailscaleStatus -notmatch "failed to connect to local tailscaled"
}

# Install Tailscale (if not already installed)
if (-not (CommandExists tailscale)) {
    Write-Output "Installing Tailscale..."
    Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup.exe" -OutFile "$env:TEMP\tailscale-setup.exe"
    Start-Process -FilePath "$env:TEMP\tailscale-setup.exe" -ArgumentList "/quiet" -Wait
}

# Check if Tailscale is running
if (-not (IsTailscaleRunning)) {
    Write-Output "Starting Tailscale..."
    Start-Process -FilePath "tailscale" -ArgumentList "up" -Wait
} else {
    Write-Output "Tailscale is already running."
}

# Set up SSH tunnel
Write-Output "Setting up SSH tunnel..."
$sshCommand = "ssh -L $Port`:localhost`:$Port $RemoteUser@$RemoteTailscaleIP"
Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", $sshCommand

# Instructions for the user to complete the setup
Write-Output "Tailscale setup is complete."
Write-Output "To connect to the local runtime from Google Colab:"
Write-Output "1. Open Google Colab."
Write-Output "2. Click 'Connect' -> 'Connect to local runtime…'"
Write-Output "3. Enter 'http://localhost:$Port' and click 'Connect'."

# Reminder to use SSH key-based authentication for better security
Write-Output "Ensure you use SSH key-based authentication for better security."

# End of script
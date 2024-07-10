param (
    [string]$PrivateKeyContent,
    [string]$RemoteUser,
    [string]$RemoteHost,
    [int]$RemotePort = 22
)

# Function to check if a command exists
function CommandExists {
    param (
        [string]$Command
    )
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to check if SSH is installed
function CheckSSH {
    if (-not (CommandExists ssh)) {
        Write-Output "SSH client is not installed. Please install OpenSSH client first."
        exit
    }
}

# Save the provided private key to a file
function SavePrivateKey {
    $sshDir = "$HOME\.ssh"
    $privateKeyPath = "$sshDir\id_rsa"
    
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force
    }
    
    Write-Output "Saving the provided private key..."
    $PrivateKeyContent | Out-File -FilePath $privateKeyPath -Encoding ASCII -Force
    
    # Set the correct permissions for the private key
    Write-Output "Setting correct permissions for the private key..."
    icacls $privateKeyPath /inheritance:r
    icacls $privateKeyPath /grant:r "$($env:USERNAME):(F)"
    icacls $privateKeyPath /remove "NT AUTHORITY\SYSTEM"
    icacls $privateKeyPath /remove "BUILTIN\Administrators"
    icacls $privateKeyPath /remove "BUILTIN\Users"
}

# Main script execution
CheckSSH
SavePrivateKey

Write-Output "SSH key-based authentication setup is complete."
Write-Output "You can now log in to the remote server without a password using:"
Write-Output "ssh -i $HOME\.ssh\id_rsa -p $RemotePort $RemoteUser@$RemoteHost"

# End of script
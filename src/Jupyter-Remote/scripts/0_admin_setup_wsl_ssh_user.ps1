param (
    [string]$WSLDistribution = "Ubuntu",
    [string]$NewUser,
    [string]$Password,
    [int]$Port = 22
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

# Install and configure OpenSSH server on WSL
function InstallOpenSSH {
    Write-Output "Installing OpenSSH server on WSL..."
    wsl -d $WSLDistribution -u root -- bash -c "apt update && apt install -y openssh-server && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && service ssh start"
}

# Create a new user on the WSL server
function CreateWSLUser {
    Write-Output "Creating new user on WSL..."
    wsl -d $WSLDistribution -u root -- bash -c "useradd -m -s /bin/bash $NewUser && echo '$NewUser:$Password' | chpasswd && mkdir -p /home/$NewUser/.ssh && chown -R $NewUser:$NewUser /home/$NewUser/.ssh"
}

# Generate SSH key pair for the new user
function GenerateUserSSHKey {
    Write-Output "Generating SSH key pair for the new user..."
    wsl -d $WSLDistribution -u root -- bash -c "ssh-keygen -t rsa -b 2048 -f /home/$NewUser/.ssh/id_rsa -N '' && chown $NewUser:$NewUser /home/$NewUser/.ssh/id_rsa*"
}

# Retrieve the generated private key
function RetrievePrivateKey {
    Write-Output "Retrieving the generated private key..."
    $privateKey = wsl -d $WSLDistribution -u root -- bash -c "cat /home/$NewUser/.ssh/id_rsa"
    return $privateKey
}

# Main script execution
CheckSSH
InstallOpenSSH
CreateWSLUser
GenerateUserSSHKey
$privateKey = RetrievePrivateKey

Write-Output "SSH key-based authentication setup for the new user is complete."
Write-Output "Provide the following private key to the new user for their SSH access:"
Write-Output "`n$privateKey`n"
Write-Output "They can save this key on their local machine and use it to log in using:"
Write-Output "ssh -i <path_to_private_key> -p $Port $NewUser@<WSL_IP_Address>"

# End of script
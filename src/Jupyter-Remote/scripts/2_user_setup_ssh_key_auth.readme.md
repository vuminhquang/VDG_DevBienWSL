
### To Use This Script:

1. Save the script as `setup_ssh_key_auth.ps1`.
2. Run the script in PowerShell with the required parameters. For example:

   ```powershell
   $privateKeyContent = @"
   -----BEGIN RSA PRIVATE KEY-----
   MIIEogIBAAKCAQEA...
   -----END RSA PRIVATE KEY-----
   "@

   .\setup_ssh_key_auth.ps1 -PrivateKeyContent $privateKeyContent -RemoteUser "your_username" -RemoteHost "your_remote_host" -RemotePort 22
   ```

### Script Explanation:

- **CheckSSH**: Ensures that the SSH client is installed on the local machine.
- **SavePrivateKey**: Saves the provided private key to `$HOME\.ssh\id_rsa` and sets the appropriate permissions to make it secure.
- **Main Script Execution**: Calls the functions to perform the setup and provides instructions to the user on how to log in to the remote server using the SSH key.

This script ensures the private key is saved securely and provides the user with the necessary information to connect to the remote server using SSH key-based authentication.
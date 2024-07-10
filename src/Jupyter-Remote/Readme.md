Using to proxy runtime client for google colab to connect, use this after done setup Jupyter wsl server

---

### Steps to Set Up and Use SSH Key-Based Authentication

1. **Run Script to Create a Remote User**

   Execute the script named `0_create_remote_user.ps1` on your WSL server. This script will:

   - Create a new user on the remote WSL server.
   - Generate an SSH key pair for the new user.
   - Output the private key for the new user.

   **Command:**

   ```powershell
   .\0_create_remote_user.ps1 -NewUser "new_username" -Password "your_password" -WSLDistribution "Ubuntu" -Port 22
   ```

2. **Run Script to Set Up the Private Key on Windows Client**

   On the client machine, run the script named `2_setup_private_key.ps1` to configure SSH key-based authentication. This script will:

   - Save the provided private key to the client's local machine.
   - Set the correct permissions for the private key.

   **Command:**

   ```powershell
   $privateKeyContent = @"
   -----BEGIN RSA PRIVATE KEY-----
   MIIEogIBAAKCAQEA...
   -----END RSA PRIVATE KEY-----
   "@

   .\2_setup_private_key.ps1 -PrivateKeyContent $privateKeyContent -RemoteUser "new_username" -RemoteHost "remote_host_ip" -RemotePort 22
   ```

3. **Run Script to Start Using SSH Key-Based Authentication**

   Finally, run the script named `3_start_using_ssh.ps1` to begin using SSH key-based authentication from the client machine. This script will:

   - Connect to the remote server using the saved private key.

   **Command:**

   ```powershell
   .\3_start_using_ssh.ps1 -RemoteUser "new_username" -RemoteHost "remote_host_ip" -RemotePort 22
   ```

### Summary of the Process:

1. **Create a Remote User**: Run the first script to set up the user and generate the SSH key pair on the WSL server.
2. **Set Up Private Key on Client**: Run the second script on the client machine to save and configure the private key.
3. **Start Using SSH**: Run the third script to initiate an SSH connection using the configured key.

By following these steps, you will successfully set up and use SSH key-based authentication for secure access to your remote WSL server.

---
# PowerShell script to enable WSL features and schedule the third part

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

Write-Message "Enabling the WSL feature..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Message "Enabling the Virtual Machine Platform feature..."
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Unregister the first scheduled task
$taskName = "CompleteWSLSetup1"
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

# Schedule the third part of the script to run at startup after second reboot
$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Enable-WSL-Part3.ps1"
$taskName = "CompleteWSLSetup2"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName

Write-Message "Restarting the system to apply changes..."
Restart-Computer -Force
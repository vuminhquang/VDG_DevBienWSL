# PowerShell script to disable WSL and schedule a task to continue after reboot

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

Write-Message "Checking for existing WSL distributions..."

$wslList = wsl --list --quiet

if ($wslList) {
    Write-Message "Found existing WSL distributions. Removing them..."
    foreach ($distro in $wslList) {
        Write-Message "Unregistering WSL distribution: $distro"
        wsl --unregister $distro
    }
} else {
    Write-Message "No existing WSL distributions found."
}

Write-Message "Disabling WSL feature if already enabled..."
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart

Write-Message "Disabling Virtual Machine Platform feature if already enabled..."
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

# Schedule the second part of the script to run at startup after first reboot
$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Enable-WSL-Part2.ps1"
$taskName = "CompleteWSLSetup1"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName

Write-Message "Restarting the system to apply changes..."
Restart-Computer -Force
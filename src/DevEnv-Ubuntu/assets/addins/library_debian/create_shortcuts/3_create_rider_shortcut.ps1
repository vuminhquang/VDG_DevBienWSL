# Load the common functions
. "$PSScriptRoot\create_shortcut_common.ps1"

# Define Rider-specific parameters
$AppName = "Rider"
$WslScriptPath = "/usr/local/bin/run_rider.sh"
$WslIconPath = "/opt/rider/bin/rider.png"

# Create the shortcut
Create-Shortcut -AppName $AppName -WslScriptPath $WslScriptPath -WslIconPath $WslIconPath
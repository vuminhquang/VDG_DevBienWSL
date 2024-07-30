# Load the common functions
. "$PSScriptRoot\create_shortcut_common.ps1"

# Define PyCharm-specific parameters
$AppName = "PyCharm"
$WslScriptPath = "/usr/local/bin/run_pycharm.sh"
$WslIconPath = "/opt/pycharm/bin/pycharm.png"

# Create the shortcut
Create-Shortcut -AppName $AppName -WslScriptPath $WslScriptPath -WslIconPath $WslIconPath
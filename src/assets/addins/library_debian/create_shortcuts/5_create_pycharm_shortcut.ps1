# Function to convert PNG to ICO
function Convert-PngToIco {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$PngFilePath,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$IcoFilePath,

        [Parameter(Mandatory = $false, Position = 2)]
        [int[]]$Sizes = @(16, 32, 48, 64, 128, 256)
    )

    begin {
        Add-Type -AssemblyName System.Drawing
    }

    process {
        try {
            $pngImage = [System.Drawing.Image]::FromFile($PngFilePath)
            $icoImages = @()

            foreach ($size in $Sizes) {
                $bitmap = New-Object System.Drawing.Bitmap($size, $size)
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

                $rectangle = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
                $graphics.DrawImage($pngImage, $rectangle)

                $icoImage = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
                $icoImages += $icoImage

                $graphics.Dispose()
                $bitmap.Dispose()
            }

            $icoImage = New-Object System.Drawing.Icon($icoImages[5], $icoImages[5].Size)

            $fileStream = New-Object System.IO.FileStream($IcoFilePath, [System.IO.FileMode]::Create)
            $icoImage.Save($fileStream)
            $fileStream.Close()

            Write-Verbose "Successfully converted $PngFilePath to $IcoFilePath with sizes: $($Sizes -join ', ')."
        }
        catch {
            Write-Error "Failed to convert $PngFilePath to $IcoFilePath. Error: $_"
        }
        finally {
            if ($pngImage) { $pngImage.Dispose() }
            if ($icoImages) { $icoImages.ForEach('Dispose') }
            if ($icoImage) { $icoImage.Dispose() }
            if ($fileStream) { $fileStream.Dispose() }
        }
    }
}




# Define the WSL paths
$wslScriptPath = "/usr/local/bin/run_pycharm.sh"
$wslIconPath = "/opt/pycharm/bin/pycharm.png"  # Adjust this path if necessary

# Check if the icon file exists in WSL
$iconExists = wsl -d Debian -e bash -c "test -f $wslIconPath && echo 'true' || echo 'false'"

if ($iconExists -ne 'true') {
    Write-Error "Icon file not found at $wslIconPath in WSL. Please check the path."
    exit 1
}

# Define the Windows paths
$shortcutPath = "$env:USERPROFILE\Desktop\PyCharm.lnk"
$windowsPngPath = "$env:USERPROFILE\.devbien\ico\pycharm.png"
$windowsIconPath = "$env:USERPROFILE\.devbien\ico\pycharm.ico"

# Create the .devbien/ico directory if it doesn't exist
if (-Not (Test-Path -Path "$env:USERPROFILE\.devbien\ico")) {
    New-Item -Path "$env:USERPROFILE\.devbien\ico" -ItemType Directory | Out-Null
}

# Copy the icon file from WSL to Windows
wsl -d Debian cp $wslIconPath /mnt/c/Users/$env:USERNAME/.devbien/ico/pycharm.png

if (-Not (Test-Path -Path $windowsPngPath)) {
    Write-Error "Failed to copy icon from WSL."
    exit 1
}

# Convert the PNG file to ICO format
Convert-PngToIco -PngFilePath $windowsPngPath -IcoFilePath $windowsIconPath

if (-Not (Test-Path -Path $windowsIconPath)) {
    Write-Error "Failed to convert PNG to ICO."
    exit 1
}

# Define the target command to run the WSL script with the specified distribution
$targetPath = "powershell.exe"
$arguments = "-WindowStyle Hidden -Command `"wsl.exe -d Debian -- $wslScriptPath`""

# Create a new WScript.Shell COM object
$WScriptShell = New-Object -ComObject WScript.Shell

# Create a shortcut object
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)

# Set properties on the shortcut
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.WorkingDirectory = "$env:USERPROFILE"
$shortcut.WindowStyle = 7   # Hidden window style
$shortcut.IconLocation = "$windowsIconPath,0"

# Save the shortcut
$shortcut.Save()

Write-Output "Shortcut to run PyCharm via WSL (Debian) has been created on your Desktop."
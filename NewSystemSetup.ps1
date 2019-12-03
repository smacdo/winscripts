# First time
# ============
#  Run this from an administrator ISE window. Make sure to enable powersehll scripts by running:
#   "Set-ExecutionPolicy remotesigned"

# Create powershell profile file
if (!(Test-Path $profile))
{
    Write-Host "Creating PS1 profile at $profile"
    New-Item -path $profile -type file -force
}

# Look for a network adapter
if ( @(Get-NetAdapter | Where { $_.Status -eq "Up" }).Count -eq 0 -And -not $SkipNetworkInterfaceCheck)
{
    Write-Warning "No network adapter detected"
}

#=================================================================================================
# Show file extensions and hidden files in explorer
#=================================================================================================
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$restartExplorer = $FALSE

if ((Get-ItemPropertyValue $key HideFileExt) -ne 0)
{
    Write-Host "Enabling display of file extensions in explorer"
    Set-ItemProperty $key HideFileExt 0
    $restartExplorer = $TRUE
}

if ((Get-ItemPropertyValue $key Hidden) -ne 1)
{
    Write-Host "Enabling display of hidden files in explorer"
    Set-ItemProperty $key Hidden 1
    #Set-ItemProperty $key ShowSuperHidden 1  # Disabled because we don't really need this.
    $restartExplorer = $TRUE
}

# Do we need to restart the explorer shell to apply changes?
if ($restartExplorer)
{
    Write-Host "Killing (and hopefully restarting) explorer to apply changes"
    #Stop-Process -processname explorer
}

#=================================================================================================
# Apply secure java permissions.
#=================================================================================================
#. ".\powershell_commands\Configure-JavaBrowserPlugIn.ps1"

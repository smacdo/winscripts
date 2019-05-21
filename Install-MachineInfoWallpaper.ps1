<#
.SYNOPSIS
    Copies bginfo.exe to the target machine, applies a preconfigured default settings for desktop display and
    registers it to be run each time the user logs in.

.PARAMETER WhatIf   Shows what would happen if the command was run, without running the command.
.PARAMETER Confirm  Requests confirmation before performing actions.
.PARAMETER Delete   Removes files, directories, links and other items created by this script.

.NOTES
    Version 1.0
    Author: Scott MacDonald <scott@smacdo.com>
    Creation Date: 05/16/2019

.EXAMPLE
    .\Installl-MachineInfoWallpaper
#>
#requires -version 5

[CmdletBinding()]
param(
    [Parameter()][switch]$WhatIf,
    [Parameter()][switch]$Confirm,
    [Parameter()][switch]$Delete
)

#----------------------------------------------------------------------------------------------------------------------
# Shared functions
#----------------------------------------------------------------------------------------------------------------------
<#
    .SYNOPSIS
    Copies (install) or deletes (uninstall) a file with logging.
    .DESCRIPTION
    The file is copied in addition to the source and destiation values being written using Write-Verbose.
    .EXAMPLE
    Install-File foobar.txt -Destination x\foobar.txt
    .PARAMETER Source      Path to the file to install. 
    .PARAMETER Destination Where to install the file to.
    .PARAMETER WhatIf      Shows what would happen if the command was run, without running the command.
    .PARAMETER Confirm     Requests confirmation before performing actions.
    .PARAMETER Delete      Removes the installed file at its destination (if present).
#>
function Install-File
{
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination,
        [Parameter()][switch]$WhatIf,
        [Parameter()][switch]$Confirm,
        [Parameter()][switch]$Delete)
    if ($Delete -eq $true)
    {
        if (Test-Path $Destination)
        {
            Write-Verbose "Uninstall: $($Destination)"
            Remove-Item -LiteralPath $Destination -WhatIf:$WhatIf -Confirm:$Confirm
        }
        elseif (!$WhatIf)
        {
            Write-Warning "File to uninstall does not exist: $($Destination)"    
        }
    }
    else
    {
        Write-Verbose "Install: $($Source) ==> $($Destination)"

        if (!$WhatIf -and (Test-Path $Destination))
        {
            Write-Warning "File already exists, overwriting: $($Destination)"
        }

        Copy-Item $Source -Destination $Destination -WhatIf:$WhatIf -Confirm:$Confirm
    }
}

<#
    .SYNOPSIS
    Creates a shell shortcut.
    .DESCRIPTION
    This function will create a Windows shell shortcut using the WSCript COM API.
    .EXAMPLE
    New-Shortcut foobar.txt -Destination x\foobar.txt
    .PARAMETER Source      The actual file being linked to. 
    .PARAMETER Destination Path to the shortcut to be created.
    .PARAMETER Arguments   Additional arguments to pass to the command when running the shortcut.
    .PARAMETER WhatIf      Shows what would happen if the command was run, without running the command.
    .PARAMETER Confirm     Requests confirmation before performing actions.
    .PARAMETER Delete      Removes the shortcut at its destination (if present).
#>
function New-Shortcut
{
    param(
        [Parameter(Mandatory=$true,Position=0)][string]$SourceExe,
        [Parameter(Mandatory=$true)][string]$Destination,
        [Parameter()][string]$Arguments,
        [Parameter()][switch]$WhatIf,
        [Parameter()][switch]$Confirm,
        [Parameter()][switch]$Delete)
    if ($Delete -eq $true)
    {
        if (Test-Path $Destination)
        {
            Write-Verbose "Delete: $($Destination)"
            Remove-Item -LiteralPath $Destination -WhatIf:$WhatIf -Confirm:$Confirm
        }
        elseif (!$WhatIf)
        {
            Write-Warning "Shortcut to delete does not exist: $($Destination)"    
        }
    }
    else
    {
        Write-Verbose "Shortcut: $($SourceExe) <== $($Destination)"
        Write-Verbose " - Target:   $($SourceExe)"
        Write-Verbose " - Arguments: $($Arguments)"

        # Remove existing file before creating.
        if (Test-Path $Destination)
        {
            Write-Warning "Destination file exists, deleting: $($Destination)"
            Remove-Item -LiteralPath $Destination -WhatIf:$WhatIf -Confirm:$Confirm
        }

        $wshShell = New-Object -comObject WScript.Shell

        $shortcut = $wshShell.CreateShortcut($Destination)
        $shortcut.TargetPath = $SourceExe
        $shortcut.Arguments = $Arguments

        $shortcut.Save()
    }

    $Destination
}

<#
    .SYNOPSIS
    Creates all missing directories in a path.
    .DESCRIPTION
    The given path is split apart and each directory that does not exist is created.
    .EXAMPLE
    New-DirectoryRecursive c:\my\app\data
    .PARAMETER Source      The directory path to create.
    .PARAMETER WhatIf      Shows what would happen if the command was run, without running the command.
    .PARAMETER Confirm     Requests confirmation before performing actions.
    .PARAMETER Delete      Removes the top level directory.
#>
function New-DirectoryRecursive
{
    Param(
        [Parameter(Mandatory=$true,Position=0)]$Source,
        [Parameter()][switch]$WhatIf,
        [Parameter()][switch]$Confirm,
        [Parameter()][switch]$Delete)

    if ($Delete)
    {
        if (Test-Path $Source)
        {
            Write-Verbose "Delete directory: $($Source)"
            Remove-Item -LiteralPath $Source -WhatIf:$WhatIf -Confirm:$Confirm
        }
        else
        {
            Write-Warning "Directory to delete does not exist, skipping: $($Source)"
        }
    }
    else
    {
        if (!(Test-Path $Source))
        {
            Write-Verbose "Create directory: $($Source)"
            New-Item -Force -ItemType Directory -Path $Source WhatIf:$WhatIf Confirm:$Confirm
        }
        else
        {
            Write-Verbose "Directory already exists: $($Source)"
        }
    }
}

<#
    .SYNOPSIS
    Gets the path to the folder that contains the currently running powershell script.
#>
function Get-CurrentScriptFolder
{
    Split-Path -parent $PSCommandPath
}

<#
    .SYNOPSIS
    Gets the path to the folder that contains user profile start up items.
    .DESCRIPTION
    This path contains only items specific to the user profile, not all users for the system.
#>
function Get-UserStartupFolder
{
    Join-Path $env:APPDATA "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
}

<#
    .SYNOPSIS
    Gets a path relative to the user's local app data folder.
    .DESCRIPTION
    This either get a path to the user's local app data folder, or an absolute path to an item inside of the user's
    local app data folder if given a relative path.
    .EXAMPLE
    Get-LocalAppDataFolder -InnerDirectory "CompanyName\ProductName\file.txt"
    .PARAMETER InnerDirectory A relative path to be appended to the returned local app data path.
    .PARAMETER WhatIf         Shows what would happen if the command was run, without running the command.
    .PARAMETER Confirm        Requests confirmation before performing actions.
    .PARAMETER Delete         Removes the inner directory folder.
#>
function Get-LocalAppDataFolder
{
    Param(
        [Parameter()]$InnerDirectory,
        [Parameter()][switch]$WhatIf,
        [Parameter()][switch]$Confirm,
        [Parameter()][switch]$Delete)

    if ($PSBoundParameters.ContainsKey("InnerDirectory"))
    {
        $localAppFolder = Join-Path $env:LOCALAPPDATA $InnerDirectory
        New-DirectoryRecursive $localAppFolder -WhatIf:$WhatIf -Confirm:$Confirm -Delete:$Delete
        $localAppFolder
    }
    else
    {
        $env:LOCALAPPDATA
    }
}

#----------------------------------------------------------------------------------------------------------------------
# Main Script
#----------------------------------------------------------------------------------------------------------------------
# Copy BGInfo binaries and related files to user's local settings folder.
$localAppFolder = Get-LocalAppDataFolder -InnerDirectory "Apps\AutoBgInfo"
$scriptFolder = Get-CurrentScriptFolder

Install-File (Join-Path $scriptFolder "bin/Bginfo.exe") -Destination (Join-Path $localAppFolder "Bginfo.exe") -Delete:$Delete -WhatIf:$WhatIf -Confirm:$Confirm
Install-File (Join-Path $scriptFolder "bin/Bginfo64.exe") -Destination (Join-Path $localAppFolder "Bginfo64.exe") -Delete:$Delete -WhatIf:$WhatIf -Confirm:$Confirm
Install-File (Join-Path $scriptFolder "bin/BgEula.txt") -Destination (Join-Path $localAppFolder "BgEula.exe") -Delete:$Delete -WhatIf:$WhatIf -Confirm:$Confirm
Install-File (Join-Path $scriptFolder "bin/Default.bgi") -Destination (Join-Path $localAppFolder "Default.bgi") -Delete:$Delete -WhatIf:$WhatIf -Confirm:$Confirm

# Create a link in the user's local start up folder (not all users' startup).
# TODO: Decide between x86 and x64
$startupFolder = Get-UserStartupFolder
$startupLink = New-Shortcut (Join-Path $scriptFolder "bin/Bginfo.exe") `
    -Destination (Join-Path $startupFolder "AutoBginfo.exe.lnk") `
    -Arguments "`"$(Join-Path $localAppFolder "Default.bgi")`" /LOG:`"$(Join-Path $localAppFolder "log.txt")`" /TIMER:0 /SILENT /NOLICPROMPT" `
    -Delete:$Delete -WhatIf:$WhatIf -Confirm:$Confirm

# Run BGInfo.exe now to apply the wallpaper.
if (!$WhatIf -and !$Delete)
{
    Invoke-Item -Path $startupLink
}

<#
    .SYNOPSIS
    Finds the bin folder on a machine that has texlive installed.
    .DESCRIPTION
    This function uses the environment variable TEXLIVE_INSTALL_DIR to find the installation directory. If the value is
    not defined it will look in C:\texlive\* instead to find a bin folder.
#>
function Get-TexLiveBinPath
{
    # Try to use the TEXLIVE_INSTALL_DIR envirornment variable first.
    if (Test-Path env:TEXLIVE_INSTALL_DIR)
    {
        $potentialPath = Join-Path $env:TEXLIVE_INSTALL_DIR "bin\\win32"

        if (Test-Path -Path $potentialPath)
        {
            return $potentialPath
        }
    }
    
    # Search for an installation with the pattern C:\texlive\<YEAR>
    Write-Host "HELLLLLLLLLLLLLLO"
}
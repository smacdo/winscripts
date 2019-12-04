#requires -version 5
#######################################################################################################################
# TODO: Rename Show-Stock
#######################################################################################################################
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string]
    $name
)

Import-Module -Force $PSScriptRoot\psm\Stocks.psm1


#Write-Host (Find-Stock -name $name)
Write-Host (Get-Stock -symbol $name)
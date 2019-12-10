#requires -version 5
<#
.SYNOPSIS
  Get a list of stock ticker symbols that match the searched for name.
.DESCRIPTION
  This command will return a list of stock ticker symbols that match the name either partially or fully.
.PARAMETER Name
  Partial or full name of the stock.
.INPUTS
  None
.OUTPUTS
  All matching stock ticker symbols as an array of strings.
.NOTES
  Version:        1.0
  Author:         Scott MacDonald
  Creation Date:  12/09/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Find-Stock -Name Google
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name
)

Import-Module -Force $PSScriptRoot\psm\Stocks.psm1
Write-Host (Find-StockSymbol -Name $Name)
#requires -version 5
<#
.SYNOPSIS
  Show stock information for a given stock ticker symbol.
.DESCRIPTION
  Fetches stock information from a web service for a given stocker ticker symbol and displays it to the user.
.PARAMETER Symbol
  The stock ticker symbol.
.INPUTS
  The stock ticker symbol.
.OUTPUTS
  None.
.NOTES
  Version:        1.0
  Author:         Scott MacDonald
  Creation Date:  12/04/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Show-Stock -Symbol MSFT
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string] $Symbol,
    [switch] $Detail
)

Import-Module -Force $PSScriptRoot\psm\Stocks.psm1
$stock = Get-Stock -Symbol $Symbol

if ($Detail) {
    # TODO: Better formatting
    Write-Host "TODO: DETAILS"
    Write-Host $stock
} else {
    # Use emoji to indicate if the stock went up or down in percent.
    # TODO: Use switch to disable emoji if terminal does not support.
    $percentChar = '💤'
    $color = (Get-Host).ui.rawui.ForegroundColor

    if ($stock.ChangePercent -gt 0.5) {
        $percentChar = '🔼'
        $color = 'Green'
    } elseif ($stock.ChangePercent -lt -.5) {
        $percentChar = '🔻'
        $color = 'Red'
    }

    # TODO: Color
    Write-Host "`$$($stock.price) $percentChar $($stock.ChangePercent)% (open: `$$($stock.Open), high: `$$($stock.High), low: `$$($stock.Low))" -ForegroundColor $color
}
<#
.SYNOPSIS
    Compiles a .tex file into a .dvi file using latex.

.PARAMETER Source       Path to source .tex file.
.PARAMETER Destination  Path to destination .dvi file.

.NOTES
    Version 1.0
    Author: Scott MacDonald <scott@smacdo.com>
    Creation Date: 05/21/2019

.EXAMPLE
    .\ConvertTo-Dvi.ps1 paper.tex -Destination paper.dvi
#>
#requires -version 5

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)][string]$Source,
    [Parameter(Position = 1, Mandatory = $true)][string]$Destination)

Import-Module ".\Latex.psm1"

$latexBin = Join-Path (Get-TexLiveBinPath) "latex.exe"
Write-Verbose "Using: $($latexBin)"

$latexProcess = Start-Process $latexBin #-ArgumentList ""

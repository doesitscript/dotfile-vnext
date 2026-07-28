#Requires -Version 5.1
<#
.SYNOPSIS
  Part 1 — Sets DWMFRAMEINTERVAL for Remote Desktop (RDP) toward a 60 FPS cap per Microsoft Learn.

.DESCRIPTION
  Creates or updates HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\DWMFRAMEINTERVAL
  as a REG_DWORD with value 15 (decimal). A full system restart is required after apply.

  Reference: https://learn.microsoft.com/en-us/troubleshoot/windows-server/remote/frame-rate-limited-to-30-fps

.PARAMETER Remove
  Remove DWMFRAMEINTERVAL from WinStations (undo). Restart again to fully revert behavior.

.EXAMPLE
  .\Set-RdpFrameRateCap.ps1

.EXAMPLE
  .\Set-RdpFrameRateCap.ps1 -Remove
#>
[CmdletBinding()]
param(
    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'This script must be run as Administrator (HKLM writes).'
}

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'
$name = 'DWMFRAMEINTERVAL'

if (-not (Test-Path -LiteralPath $regPath)) {
    Write-Error "Registry path not found: $regPath"
}

if ($Remove) {
    Remove-ItemProperty -LiteralPath $regPath -Name $name -ErrorAction SilentlyContinue
    Write-Host "Removed $name from WinStations (if it was present). Reboot to fully revert RDP frame cap behavior."
    exit 0
}

New-ItemProperty -LiteralPath $regPath -Name $name -PropertyType DWord -Value 15 -Force | Out-Null

$current = (Get-ItemProperty -LiteralPath $regPath -Name $name -ErrorAction Stop).$name
Write-Host "DWMFRAMEINTERVAL is set to $current (expect 15). Reboot the computer for the change to take full effect (per Microsoft Learn)."

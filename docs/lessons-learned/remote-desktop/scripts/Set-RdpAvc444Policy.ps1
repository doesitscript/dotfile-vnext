#Requires -Version 5.1
<#
.SYNOPSIS
  Part 2 — Policy registry for prioritizing H.264/AVC 444 (and optional hardware encoding) for Remote Desktop.

.DESCRIPTION
  Writes the same values as Group Policy under:
    HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services

  - AVC444ModePreferred = 1  (Prioritize H.264/AVC 444 graphics mode)
  - AVCHardwareEncodePreferred = 1  (optional, with -IncludeHardwareEncoding)

  ADMX reference: TerminalServer TS_SERVER_AVC444_MODE_PREFERRED / TS_SERVER_AVC_HW_ENCODE_PREFERRED

  After apply: reconnect RDP or reboot for a clean pickup.

.PARAMETER IncludeHardwareEncoding
  Also set AVCHardwareEncodePreferred = 1 (GPU offload when supported).

.PARAMETER Remove
  Remove AVC444ModePreferred and AVCHardwareEncodePreferred from the policy key (undo).

.EXAMPLE
  .\Set-RdpAvc444Policy.ps1

.EXAMPLE
  .\Set-RdpAvc444Policy.ps1 -IncludeHardwareEncoding

.EXAMPLE
  .\Set-RdpAvc444Policy.ps1 -Remove
#>
[CmdletBinding()]
param(
    [switch] $IncludeHardwareEncoding,
    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'This script must be run as Administrator (HKLM writes).'
}

$policyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
$avc444Name = 'AVC444ModePreferred'
$hwName = 'AVCHardwareEncodePreferred'

if (-not (Test-Path -LiteralPath $policyPath)) {
    New-Item -Path $policyPath -Force | Out-Null
}

if ($Remove) {
    Remove-ItemProperty -LiteralPath $policyPath -Name $avc444Name -ErrorAction SilentlyContinue
    Remove-ItemProperty -LiteralPath $policyPath -Name $hwName -ErrorAction SilentlyContinue
    Write-Host "Removed $avc444Name and $hwName (if present). Reconnect RDP or reboot as needed."
    exit 0
}

New-ItemProperty -LiteralPath $policyPath -Name $avc444Name -PropertyType DWord -Value 1 -Force | Out-Null

$avc = (Get-ItemProperty -LiteralPath $policyPath -Name $avc444Name -ErrorAction Stop).$avc444Name
Write-Host "$avc444Name = $avc (expect 1)."

if ($IncludeHardwareEncoding) {
    New-ItemProperty -LiteralPath $policyPath -Name $hwName -PropertyType DWord -Value 1 -Force | Out-Null
    $hw = (Get-ItemProperty -LiteralPath $policyPath -Name $hwName -ErrorAction Stop).$hwName
    Write-Host "$hwName = $hw (expect 1)."
} else {
    Write-Host 'Hardware encoding not changed (omit -IncludeHardwareEncoding to leave AVCHardwareEncodePreferred as-is).'
}

Write-Host 'Reconnect RDP sessions or reboot for encoding policy to apply reliably.'

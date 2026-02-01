# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script configures WinRM HTTPS and WSL features, then writes facts to facts/server-225.json

$ErrorActionPreference = "Stop"

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Warn about prerequisites on new systems
Write-Host ""
Write-Host "WARNING: On a new Windows server, ensure:" -ForegroundColor Yellow
Write-Host "  - PowerShell execution policy allows scripts (see README.md)" -ForegroundColor Yellow
Write-Host "  - Repository is cloned to this machine" -ForegroundColor Yellow
Write-Host "  - Running from elevated PowerShell (as Administrator)" -ForegroundColor Yellow
Write-Host ""

function Write-Facts($path, $obj) {
  $dir = Split-Path -Parent $path
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $obj | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

# Basic identity
$hostname = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object -First 1 -ExpandProperty IPAddress)

# Enable PSRemoting / WinRM
Enable-PSRemoting -Force

# Ensure WinRM service
Set-Service WinRM -StartupType Automatic
Start-Service WinRM

# Create/ensure HTTPS listener on 5986
$existingHttps = (winrm enumerate winrm/config/listener) -match "Transport = HTTPS"
if (-not $existingHttps) {
  $cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation Cert:\LocalMachine\My
  $thumb = $cert.Thumbprint
  winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumb`"}"
} else {
  # Best-effort extract thumbprint (not perfect, but ok for facts)
  $thumb = (Get-ChildItem Cert:\LocalMachine\My | Sort-Object NotAfter -Descending | Select-Object -First 1).Thumbprint
}

# Firewall for 5986
if (-not (Get-NetFirewallRule -DisplayName "WinRM HTTPS 5986" -ErrorAction SilentlyContinue)) {
  netsh advfirewall firewall add rule name="WinRM HTTPS 5986" dir=in action=allow protocol=TCP localport=5986 | Out-Null
}

# Enable WSL features (may require reboot)
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vmFeature  = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

$needsReboot = $false
if ($wslFeature.State -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null; $needsReboot = $true }
if ($vmFeature.State  -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null; $needsReboot = $true }

# Check if WSL exists
$wslExists = $false
try { wsl -l -q | Out-Null; $wslExists = $true } catch { $wslExists = $false }

# If WSL exists, get distro list
$distroList = @()
if ($wslExists) {
  $distroList = (wsl -l -q) | Where-Object { $_ -and $_.Trim().Length -gt 0 }
}

$facts = [ordered]@{
  physical_node = "server-225"
  windows = @{
    hostname = $hostname
    host_ip = $ip
    winrm_port = 5986
    winrm_transport = "ntlm"
    winrm_https_thumbprint = $thumb
  }
  wsl = @{
    features_enabled = ($wslFeature.State -eq "Enabled" -and $vmFeature.State -eq "Enabled")
    distros = $distroList
  }
  needs_reboot = $needsReboot
}

Write-Facts ".\facts\server-225.json" $facts

if ($needsReboot) {
  Write-Host "WSL features enabled. Reboot is required before continuing."
  exit 3010
}

Write-Host "Windows bootstrap complete. Now run bin/bootstrap-local.sh inside WSL."

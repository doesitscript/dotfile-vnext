# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script configures WinRM HTTPS and writes facts to facts/server-225.json
# Note: WSL installation is handled automatically if no distros are found

$ErrorActionPreference = "Stop"

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

function Write-Facts($path, $obj) {
  $dir = Split-Path -Parent $path
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $obj | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

# Basic identity
$hostname = $env:COMPUTERNAME
$ip = (Get-NetIPAddress -AddressFamily IPv4 `
  | Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.InterfaceAlias -notlike "*Loopback*" } `
  | Select-Object -First 1 -ExpandProperty IPAddress)

# Configure WinRM HTTPS (creates cert, listener, and firewall rule)
winrm quickconfig -transport:https -force | Out-Null

# Extract thumbprint for facts
$thumb = (Get-ChildItem Cert:\LocalMachine\My | Sort-Object NotAfter -Descending | Select-Object -First 1).Thumbprint

# Check if WSL distro is installed, install Ubuntu if not
# Fast WSL install path for Windows Server 2025
Write-Host "Checking for WSL distribution..." -ForegroundColor Cyan
$wslList = wsl.exe -l -q 2>$null
$hasDistro = $LASTEXITCODE -eq 0 -and ($wslList | Where-Object { $_.Trim() }).Count -gt 0

if (-not $hasDistro) {
    Write-Host "No WSL distro found. Installing Ubuntu..." -ForegroundColor Yellow
    wsl.exe --install -d Ubuntu
    Write-Host "WSL installation triggered." -ForegroundColor Green
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
    distros = $distroList
  }
}

Write-Facts ".\facts\server-225.json" $facts

Write-Host "Windows bootstrap complete. Now run bin/bootstrap-local.sh inside WSL."

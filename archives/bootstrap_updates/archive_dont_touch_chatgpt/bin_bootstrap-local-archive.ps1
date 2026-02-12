# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script configures WinRM HTTP and writes facts to facts/server-225.json
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

# Configure WinRM HTTP (creates listener and firewall rule)
winrm quickconfig -force | Out-Null

# Check if WSL distro is installed, install Ubuntu if not
# Fast WSL install path for Windows Server 2025
Write-Host "Checking for WSL distribution..." -ForegroundColor Cyan
$wslList = wsl.exe -l -q 2>$null
$distroList = @()
$hasDistro = $false

if ($LASTEXITCODE -eq 0 -and $wslList) {
    $distroList = $wslList | Where-Object { $_.Trim() }
    $hasDistro = $distroList.Count -gt 0
    if ($hasDistro) {
        Write-Host "WSL distribution found: $($distroList -join ', ')" -ForegroundColor Green
    }
}

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
    winrm_port = 5985
    winrm_transport = "ntlm"
    winrm_scheme = "http"
  }
  wsl = @{
    distros = $distroList
  }
}

Write-Facts ".\facts\server-225.json" $facts

Write-Host "Windows bootstrap complete. Now run bin/bootstrap-local.sh inside WSL."

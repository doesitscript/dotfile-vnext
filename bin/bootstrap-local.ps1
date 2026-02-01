# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script configures WinRM HTTPS and writes facts to facts/server-225.json
# Note: WSL installation should be done separately using wsl --install -d Ubuntu

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

# Check if WSL exists and get distro list
$wslExists = $false
$distroList = @()
try { 
  $wslOutput = wsl -l -q 2>&1
  if ($LASTEXITCODE -eq 0 -and $wslOutput) {
    $wslExists = $true
    $distroList = $wslOutput | Where-Object { $_ -and $_.Trim().Length -gt 0 }
  }
} catch { 
  $wslExists = $false 
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

# Requires -RunAsAdministrator

Write-Host "--- Starting OpenSSH Server Troubleshooter ---" -ForegroundColor Cyan

# 1. Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.PrincipalPolicy]::WindowsBuiltInRole::Administrator)) {
    Write-Host "This script must be run as an Administrator. Exiting." -ForegroundColor Red
    exit 1
}

# 2. Verify OpenSSH Server Installation Status
Write-Host "`n--- 2. Checking OpenSSH Server installation status ---" -ForegroundColor Yellow
$sshServerCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
if ($sshServerCapability.State -eq 'Installed') {
    Write-Host "OpenSSH Server is installed." -ForegroundColor Green
} else {
    Write-Host "OpenSSH Server is NOT installed. Attempting to install..." -ForegroundColor Red
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
        Write-Host "OpenSSH Server installed successfully. Please run this script again after the installation completes." -ForegroundColor Green
        exit 0
    } catch {
        Write-Host "Failed to install OpenSSH Server: $_.Exception.Message" -ForegroundColor Red
        exit 1
    }
}

# 3. Check and Start SSHD Service
Write-Host "`n--- 3. Checking SSHD service status ---" -ForegroundColor Yellow
$sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshdService) {
    Write-Host "SSHD service found. Status: $($sshdService.Status)" -ForegroundColor Green
    if ($sshdService.Status -ne 'Running') {
        Write-Host "Attempting to start SSHD service and set to Automatic startup..." -ForegroundColor Yellow
        Start-Service sshd
        Set-Service -Name sshd -StartupType 'Automatic'
        Write-Host "SSHD service started and set to automatic." -ForegroundColor Green
    }
} else {
    Write-Host "SSHD service not found. This indicates an issue with the installation." -ForegroundColor Red
}

# 4. Verify Firewall Rule
Write-Host "`n--- 4. Verifying OpenSSH firewall rule ---" -ForegroundColor Yellow
$fwRule = Get-NetFirewallRule -Name "*OpenSSHServer*" -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq $True}
if ($fwRule) {
    Write-Host "OpenSSH firewall rule is enabled." -ForegroundColor Green
} else {
    Write-Host "OpenSSH firewall rule not found or disabled. It should be automatically created during installation." -ForegroundColor Red
    # The following command creates the rule if needed
    # New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
    Write-Host "Manual creation may be needed if you confirm it's missing (see documentation)." -ForegroundColor Yellow
}

# 5. Check SSH configuration directory and permissions
Write-Host "`n--- 5. Checking C:\ProgramData\ssh directory and permissions ---" -ForegroundColor Yellow
$sshDir = "C:\ProgramData\ssh"
if (-not (Test-Path $sshDir)) {
    Write-Host "$sshDir folder is missing. Creating it..." -ForegroundColor Red
    New-Item -Path $sshDir -ItemType Directory | Out-Null
    # Permissions need to be set properly for host keys to be generated
    Write-Host "Permissions on $sshDir may be incorrect. You may need to use the FixHostFilePermissions.ps1 script from the OpenSSH portable distribution." -ForegroundColor Yellow
} else {
    Write-Host "$sshDir folder found." -ForegroundColor Green
    # The portable version includes scripts to fix permissions
    Write-Host "If key-based auth fails, consider running the FixHostFilePermissions.ps1 utility script manually." -ForegroundColor Yellow
}

# 6. Test local connection
Write-Host "`n--- 6. Testing local SSH connection (ssh localhost) ---" -ForegroundColor Yellow
try {
    # Use ssh client to connect to local server
    ssh.exe localhost -o BatchMode=yes -o ConnectionAttempts=1 | Out-Null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Local SSH connection test successful." -ForegroundColor Green
    } else {
        Write-Host "Local SSH connection test failed. Check logs in Event Viewer > Applications and Services Logs > OpenSSH/Operational." -ForegroundColor Red
    }
} catch {
    Write-Host "An error occurred during local connection test: $_.Exception.Message" -ForegroundColor Red
}

Write-Host "`n--- Troubleshooter Finished ---" -ForegroundColor Cyan

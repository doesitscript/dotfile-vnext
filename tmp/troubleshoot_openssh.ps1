# Requires -RunAsAdministrator

Write-Host "--- Starting OpenSSH Server Troubleshooter ---" -ForegroundColor Cyan

# 1. Check for Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
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

# 4. Verify Firewall Rule (project uses rule name "sshd"; default install may use *OpenSSHServer*)
Write-Host "`n--- 4. Verifying OpenSSH firewall rule and port ---" -ForegroundColor Yellow
$ruleByName = Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue
$ruleByPattern = Get-NetFirewallRule -DisplayName '*OpenSSH*' -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq $True }
$fwRule = if ($ruleByName) { $ruleByName } else { $ruleByPattern | Select-Object -First 1 }
if ($fwRule) {
    $portFilter = $fwRule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
    $localPorts = if ($portFilter -and $portFilter.LocalPort) { @($portFilter.LocalPort) } else { @() }
    $portStr = if ($localPorts.Count -gt 0) { $localPorts -join ',' } else { '(none)' }
    Write-Host "OpenSSH firewall rule found: Name=$($fwRule.Name), Enabled=$($fwRule.Enabled), LocalPort=$portStr" -ForegroundColor Green
    Write-Host "  Expected port is win_ssh_port in inventory/host_vars/<node>-win.yaml (default 22)." -ForegroundColor Gray
} else {
    Write-Host "OpenSSH firewall rule not found (checked name 'sshd' and display name *OpenSSH*)." -ForegroundColor Red
    Write-Host "  Run bootstrap: .\bin\bootstrap-local.ps1 or from Mac: ./bin/fz bootstrap --limit <node>-win" -ForegroundColor Yellow
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

# 6. Test local connection (use port 22 unless win_ssh_port is set elsewhere)
Write-Host "`n--- 6. Testing local SSH connection (ssh localhost) ---" -ForegroundColor Yellow
$testPort = 22
if ($fwRule) {
    $portFilter = $fwRule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
    if ($portFilter -and $portFilter.LocalPort) { $testPort = @($portFilter.LocalPort)[0] }
}
try {
    ssh.exe -p $testPort localhost -o BatchMode=yes -o ConnectionAttempts=1 -o StrictHostKeyChecking=no | Out-Null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Local SSH connection test successful." -ForegroundColor Green
    } else {
        Write-Host "Local SSH connection test failed. Check logs in Event Viewer > Applications and Services Logs > OpenSSH/Operational." -ForegroundColor Red
    }
} catch {
    Write-Host "An error occurred during local connection test: $_.Exception.Message" -ForegroundColor Red
}

Write-Host "`n--- Troubleshooter Finished ---" -ForegroundColor Cyan

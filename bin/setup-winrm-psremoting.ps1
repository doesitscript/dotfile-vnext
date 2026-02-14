# bin/setup-winrm-psremoting.ps1
# Requires -RunAsAdministrator
# Sets up WinRM and PS Remoting for Ansible from Mac. Called by bootstrap-local.ps1.
# Connection settings (transport, timeouts) are in repo root ansible.cfg; this script only prepares the Windows side.

$ErrorActionPreference = "Stop"

# CredSSP (required for some Ansible WinRM scenarios)
try {
    Enable-WSManCredSSP -Role Server -Force -ErrorAction Stop
    Write-Verbose "WSMan CredSSP Server enabled"
} catch {
    Write-Warning "Enable-WSManCredSSP failed (non-fatal): $_"
}

# WinRM service and HTTP listener (port 5985). Matches ansible.cfg and host_vars ansible_port.
Enable-PSRemoting -Force -SkipNetworkProfileCheck -ErrorAction Stop
Write-Verbose "PSRemoting enabled"

# Firewall: HTTP WinRM (5985). Use same name as Ansible playbooks so we don't duplicate.
$ruleName = "WinRM-HTTP-In-TCP"
$existing = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
if (-not $existing) {
    $firewallParams = @{
        Name        = $ruleName
        DisplayName = "WinRM HTTP (5985)"
        Description = "Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]"
        Action      = 'Allow'
        Direction   = 'Inbound'
        LocalPort   = 5985
        Profile     = 'Any'
        Protocol    = 'TCP'
    }
    New-NetFirewallRule @firewallParams
    Write-Verbose "Firewall rule $ruleName created"
} else {
    Write-Verbose "Firewall rule $ruleName already exists"
}

# Set network profile to Private so Private firewall profile applies (WinRM allowed)
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -Confirm:$false
Write-Verbose "Network profile(s) set to Private"

# Allow local accounts with WinRM (needed when not using domain accounts)
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
if (-not (Get-ItemProperty -Path $regPath -Name 'LocalAccountTokenFilterPolicy' -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $regPath -Name 'LocalAccountTokenFilterPolicy' -Value 1 -PropertyType DWORD -Force | Out-Null
} else {
    Set-ItemProperty -Path $regPath -Name 'LocalAccountTokenFilterPolicy' -Value 1 -Type DWord -Force
}
Write-Verbose "LocalAccountTokenFilterPolicy set to 1"

# Optional: ensure winrm quickconfig so listener is present (idempotent)
# winrm quickconfig -force 2>&1 | Out-Null

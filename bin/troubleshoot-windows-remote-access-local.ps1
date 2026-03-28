<#
.SYNOPSIS
Collect local Windows remote-access troubleshooting artifacts on the host itself.

.DESCRIPTION
Runs the same remote-access evidence collection model used by the repo's
troubleshooting collector, but directly on the Windows node instead of through
WinRM from another machine.

This is useful when the host is reachable locally but remote control surfaces
like WinRM or OpenSSH are intermittently down, timing out, or otherwise too
unstable to trust for collection.

Artifacts are written into the repo under:

  artifacts/troubleshooting/windows_remote_access/<COMPUTERNAME>/<timestamp>/

The helper supports grouped evidence scopes so collection can scale from normal
service/listener checks to deeper drop-path analysis.

.PARAMETER RepoRoot
Absolute or relative path to the repo root. Defaults to the parent directory of
the script's `bin/` folder.

.PARAMETER ArtifactStamp
Timestamp segment for the artifact directory. Defaults to the current local
time in `yyyyMMdd-HHmmss` format.

.PARAMETER ArtifactGroups
Evidence groups to collect. Defaults to:

  - control_surfaces
  - network_path
  - firewall_drop_path

Group meanings:

  control_surfaces
    WinRM/sshd services, listeners, configs, standard remote-access event logs,
    and direct firewall rules.

  network_path
    Adapters, IPv4 bindings, and recent network-related System events.

  firewall_drop_path
    Firewall profile policy, configured firewall logs, advanced-security
    firewall events, and Security drop/audit events such as 5152/5157.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\bin\troubleshoot-windows-remote-access-local.ps1

Collect the full default remote-access artifact bundle locally on the Windows
host.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\bin\troubleshoot-windows-remote-access-local.ps1 `
  -ArtifactGroups control_surfaces,network_path

Collect a narrower bundle focused on standard remote-access surfaces and the
local network path, without the deeper firewall drop-path surfaces.

.NOTES
Related repo diagnostics notes:
  - docs/diagnostics/winrm--windows--diagnostics.md
  - docs/diagnostics/openssh--windows--diagnostics.md
  - docs/diagnostics/windows-remote-access--local-run.md
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$ArtifactStamp = (Get-Date -Format 'yyyyMMdd-HHmmss'),
    [string[]]$ArtifactGroups = @('control_surfaces', 'network_path', 'firewall_drop_path')
)

$ErrorActionPreference = 'Stop'

$scenario = 'windows_remote_access'
$hostName = $env:COMPUTERNAME
$artifactRoot = Join-Path $RepoRoot "artifacts/troubleshooting/$scenario/$hostName/$ArtifactStamp"
$commandDir = Join-Path $artifactRoot 'command_results'
$eventDir = Join-Path $artifactRoot 'event_logs'
$notesDir = Join-Path $artifactRoot 'notes'

foreach ($dir in @($artifactRoot, $commandDir, $eventDir, $notesDir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

function Convert-ToPrettyJson {
    param([Parameter(Mandatory = $true)]$InputObject)
    return ($InputObject | ConvertTo-Json -Depth 12)
}

$result = [ordered]@{
    host = $hostName
    artifact_groups = @($ArtifactGroups)
    winrm = [ordered]@{
        service = $null
        listener = ''
        test_wsman = ''
        active_shells = @()
        tcp = @()
        firewall = @()
    }
    openssh = [ordered]@{
        service = $null
        processes = @()
        config_path = 'C:\ProgramData\ssh\sshd_config'
        config_exists = $false
        config = ''
        log_dir = 'C:\ProgramData\ssh\logs'
        log_files = @()
        sshd_log_tail = ''
        tcp = @()
        firewall = @()
    }
    system = [ordered]@{
        hostname = $hostName
        adapters = @()
        ipv4 = @()
        network_system_events = @()
    }
    firewall_path = [ordered]@{
        profiles = @()
        log_files = @()
        firewall_events = @()
        security_drop_events = @()
    }
    winrm_operational_events = @()
    winrm_system_events = @()
    openssh_operational_events = @()
    openssh_admin_events = @()
    scm_remote_access_events = @()
}

if ($ArtifactGroups -contains 'control_surfaces') {
    try {
        $svc = Get-Service WinRM -ErrorAction Stop
        $result.winrm.service = @{
            Name = $svc.Name
            Status = $svc.Status.ToString()
            StartType = $svc.StartType.ToString()
        }
    } catch {}

    try { $result.winrm.listener = (winrm enumerate winrm/config/listener 2>&1 | Out-String).Trim() } catch {}
    try { $result.winrm.test_wsman = (Test-WSMan localhost 2>&1 | Out-String).Trim() } catch {}
    try {
        $shells = Get-WSManInstance -ResourceURI shell -Enumerate -ErrorAction Stop
        $result.winrm.active_shells = @($shells | ForEach-Object {
            @{
                ShellId = $_.ShellId
                Owner = $_.Owner
                ClientIP = $_.ClientIP
                ShellRunTime = $_.ShellRunTime
                ShellInactivity = $_.ShellInactivity
                IdleTimeOut = $_.IdleTimeOut
            }
        })
    } catch {}
    try {
        $result.winrm.tcp = @(
            Get-NetTCPConnection -State Listen -ErrorAction Stop |
            Where-Object { $_.LocalPort -in 5985, 5986 } |
            Select-Object LocalAddress, LocalPort, State, OwningProcess
        )
    } catch {}
    try {
        $result.winrm.firewall = @(
            Get-NetFirewallRule -ErrorAction Stop |
            Where-Object { $_.DisplayName -match 'WinRM|Remote Management' } |
            Select-Object DisplayName, Enabled, Direction, Action
        )
    } catch {}

    try {
        $svc = Get-Service sshd -ErrorAction Stop
        $result.openssh.service = @{
            Name = $svc.Name
            Status = $svc.Status.ToString()
            StartType = $svc.StartType.ToString()
        }
    } catch {}
    try {
        $result.openssh.processes = @(
            Get-Process sshd -ErrorAction SilentlyContinue |
            Select-Object Id, StartTime, CPU, WorkingSet64
        )
    } catch {}
    try {
        if (Test-Path $result.openssh.config_path) {
            $result.openssh.config_exists = $true
            $result.openssh.config = Get-Content -LiteralPath $result.openssh.config_path -Raw
        }
    } catch {}
    try {
        if (Test-Path $result.openssh.log_dir) {
            $result.openssh.log_files = @(
                Get-ChildItem -LiteralPath $result.openssh.log_dir -ErrorAction SilentlyContinue |
                Select-Object Name, Length, LastWriteTime, Attributes
            )
            $sshdLog = Join-Path $result.openssh.log_dir 'sshd.log'
            if (Test-Path $sshdLog) {
                $result.openssh.sshd_log_tail = (Get-Content -LiteralPath $sshdLog -Tail 100 -ErrorAction SilentlyContinue | Out-String).Trim()
            }
        }
    } catch {}
    try {
        $result.openssh.tcp = @(
            Get-NetTCPConnection -State Listen -ErrorAction Stop |
            Where-Object { $_.LocalPort -eq 22 } |
            Select-Object LocalAddress, LocalPort, State, OwningProcess
        )
    } catch {}
    try {
        $result.openssh.firewall = @(
            Get-NetFirewallRule -ErrorAction Stop |
            Where-Object { $_.DisplayName -match 'SSH|sshd|OpenSSH' } |
            Select-Object DisplayName, Enabled, Direction, Action
        )
    } catch {}

    try {
        $result.winrm_operational_events = @(
            Get-WinEvent -LogName 'Microsoft-Windows-WinRM/Operational' -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
    try {
        $result.winrm_system_events = @(
            Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                ProviderName = 'Microsoft-Windows-WinRM'
                StartTime = (Get-Date).AddHours(-12)
            } -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
    try {
        $result.openssh_operational_events = @(
            Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
    try {
        $result.openssh_admin_events = @(
            Get-WinEvent -LogName 'OpenSSH/Admin' -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
    try {
        $result.scm_remote_access_events = @(
            Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                ProviderName = 'Service Control Manager'
                StartTime = (Get-Date).AddHours(-12)
            } -ErrorAction Stop |
            Where-Object { $_.Message -match 'sshd|WinRM' } |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
}

if ($ArtifactGroups -contains 'network_path') {
    try {
        $result.system.adapters = @(
            Get-NetAdapter -ErrorAction Stop |
            Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed
        )
    } catch {}
    try {
        $result.system.ipv4 = @(
            Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Select-Object InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin
        )
    } catch {}
    try {
        $result.system.network_system_events = @(
            Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                StartTime = (Get-Date).AddHours(-12)
            } -MaxEvents 100 -ErrorAction Stop |
            Where-Object { $_.ProviderName -match 'Hyper-V|TCPIP|DNS|DHCP|NetBT|vmswitch|NlaSvc|Netwtw|e1dexpress|NDIS' } |
            Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message
        )
    } catch {}
}

if ($ArtifactGroups -contains 'firewall_drop_path') {
    try {
        $result.firewall_path.profiles = @(
            Get-NetFirewallProfile -ErrorAction Stop |
            Select-Object `
                Name, Enabled, DefaultInboundAction, DefaultOutboundAction, `
                AllowInboundRules, AllowLocalFirewallRules, AllowLocalIPsecRules, `
                AllowUserApps, AllowUserPorts, NotifyOnListen, LogFileName, `
                LogAllowed, LogBlocked, LogIgnored, LogMaxSizeKilobytes
        )
    } catch {}
    try {
        $logPaths = @(
            $result.firewall_path.profiles |
            Where-Object { $_.LogFileName } |
            Select-Object -ExpandProperty LogFileName -Unique
        )
        foreach ($logPath in $logPaths) {
            if (Test-Path $logPath) {
                $result.firewall_path.log_files += @{
                    path = $logPath
                    tail = (Get-Content -LiteralPath $logPath -Tail 100 -ErrorAction SilentlyContinue | Out-String).Trim()
                }
            } else {
                $result.firewall_path.log_files += @{
                    path = $logPath
                    tail = ''
                    note = 'Configured log path does not currently exist'
                }
            }
        }
    } catch {}
    try {
        $result.firewall_path.firewall_events = @(
            Get-WinEvent -LogName 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall' -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
    try {
        $result.firewall_path.security_drop_events = @(
            Get-WinEvent -FilterHashtable @{
                LogName = 'Security'
                Id = 5152, 5157
                StartTime = (Get-Date).AddHours(-12)
            } -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated, Id, LevelDisplayName, Message
        )
    } catch {}
}

[System.IO.File]::WriteAllText(
    (Join-Path $commandDir 'windows_remote_access_probe.json'),
    (Convert-ToPrettyJson -InputObject $result)
)

if ($ArtifactGroups -contains 'control_surfaces') {
    $control = [ordered]@{
        artifact_groups = @($ArtifactGroups)
        host = $result.host
        winrm = $result.winrm
        openssh = $result.openssh
        winrm_operational_events = $result.winrm_operational_events
        winrm_system_events = $result.winrm_system_events
        openssh_operational_events = $result.openssh_operational_events
        openssh_admin_events = $result.openssh_admin_events
        scm_remote_access_events = $result.scm_remote_access_events
    }
    [System.IO.File]::WriteAllText(
        (Join-Path $commandDir 'windows_remote_access_control_surfaces.json'),
        (Convert-ToPrettyJson -InputObject $control)
    )
}

if ($ArtifactGroups -contains 'network_path') {
    $network = [ordered]@{
        artifact_groups = @($ArtifactGroups)
        host = $result.host
        system = $result.system
    }
    [System.IO.File]::WriteAllText(
        (Join-Path $commandDir 'windows_remote_access_network_path.json'),
        (Convert-ToPrettyJson -InputObject $network)
    )
}

if ($ArtifactGroups -contains 'firewall_drop_path') {
    $firewall = [ordered]@{
        artifact_groups = @($ArtifactGroups)
        host = $result.host
        firewall_path = $result.firewall_path
    }
    [System.IO.File]::WriteAllText(
        (Join-Path $commandDir 'windows_remote_access_firewall_drop_path.json'),
        (Convert-ToPrettyJson -InputObject $firewall)
    )
}

[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'winrm_operational.json'),
    (Convert-ToPrettyJson -InputObject $result.winrm_operational_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'winrm_system.json'),
    (Convert-ToPrettyJson -InputObject $result.winrm_system_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'openssh_operational.json'),
    (Convert-ToPrettyJson -InputObject $result.openssh_operational_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'openssh_admin.json'),
    (Convert-ToPrettyJson -InputObject $result.openssh_admin_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'scm_remote_access.json'),
    (Convert-ToPrettyJson -InputObject $result.scm_remote_access_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'firewall_advanced_security.json'),
    (Convert-ToPrettyJson -InputObject $result.firewall_path.firewall_events)
)
[System.IO.File]::WriteAllText(
    (Join-Path $eventDir 'firewall_security_drop_events.json'),
    (Convert-ToPrettyJson -InputObject $result.firewall_path.security_drop_events)
)

$notes = @"
Scenario: $scenario
Host: $hostName
Artifact root: $artifactRoot
Diagnostics notes:
- $RepoRoot/docs/diagnostics/winrm--windows--diagnostics.md
- $RepoRoot/docs/diagnostics/openssh--windows--diagnostics.md
Artifact groups:
$(($ArtifactGroups | ForEach-Object { "- $_" }) -join [Environment]::NewLine)
Repo debug reference:
- $RepoRoot/roles/access_identity_windows/tasks/debug_output.yml
Group descriptions:
- control_surfaces: WinRM/sshd services, listeners, configs, basic event channels, and remote-access firewall rules
- network_path: adapters, IPv4 bindings, and recent network-related System events
- firewall_drop_path: firewall profile policy, configured firewall log files, advanced-security channel events, and Security drop/audit events
"@

[System.IO.File]::WriteAllText((Join-Path $notesDir 'README.txt'), $notes)

Write-Host "Windows remote access troubleshooting artifacts written to:" -ForegroundColor Cyan
Write-Host "  $artifactRoot" -ForegroundColor Green

# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script:
# 1. Auto-detects which physical node it's running on (by hostname or IP)
# 2. Collects runtime facts (hostname, IP, WinRM thumbprint, WSL distros)
# 3. Generates host_vars files for Windows and WSL surfaces
# 4. Writes facts JSON for auditing/reuse

$ErrorActionPreference = "Stop"

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Get script directory and repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# ============================================================================
# YAML Loading Functions
# ============================================================================

function Import-Yaml {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        throw "YAML file not found: $Path"
    }
    
    # Try PowerShell-YAML module first
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Import-Module powershell-yaml -ErrorAction SilentlyContinue
        if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
            $result = ConvertFrom-Yaml (Get-Content $Path -Raw)
            # Convert to hashtable for easier access
            if ($result -is [hashtable]) {
                return $result
            } else {
                return $result | ConvertTo-Json -Depth 10 | ConvertFrom-Json
            }
        }
    }
    
    # Fallback: Use Python if available (common on Windows with WSL)
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    }
    
    if ($pythonCmd) {
        $yamlContent = Get-Content $Path -Raw
        $tempFile = [System.IO.Path]::GetTempFileName()
        $yamlContent | Out-File -FilePath $tempFile -Encoding UTF8
        
        try {
            $jsonContent = & $pythonCmd.Command -c @"
import yaml, json, sys
try:
    with open(r'$tempFile', 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    print(json.dumps(data))
except ImportError:
    print('{}')
except Exception as e:
    print('{}')
"@ 2>$null
            
            if ($jsonContent -and $jsonContent.Trim() -ne '{}' -and $jsonContent.Trim().Length -gt 0) {
                $result = $jsonContent | ConvertFrom-Json
                Remove-Item $tempFile -Force
                return $result
            }
        } catch {
            # Continue to simple parser
        } finally {
            if (Test-Path $tempFile) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # Last resort: Simple YAML parser for basic key-value structures
    # This is a minimal parser that handles the hosts_mapping.yaml structure
    $content = Get-Content $Path -Raw
    $result = @{}
    
    # Parse use_dns
    if ($content -match 'use_dns:\s*(true|false)') {
        $result.use_dns = $Matches[1] -eq 'true'
    } else {
        $result.use_dns = $false
    }
    
    # Parse physical_nodes - improved regex to handle various formats
    $result.physical_nodes = @{}
    if ($content -match 'physical_nodes:') {
        # Match node entries with more flexible whitespace
        $nodePattern = '(?m)^\s+(\w+):\s*\r?\n(?:\s+#.*\r?\n)?\s+hostname:\s*"([^"]+)"\s*\r?\n(?:\s+#.*\r?\n)?\s+ip_address:\s*"([^"]+)"'
        $matches = [regex]::Matches($content, $nodePattern)
        foreach ($match in $matches) {
            $nodeKey = $match.Groups[1].Value
            $hostname = $match.Groups[2].Value
            $ip = $match.Groups[3].Value
            $result.physical_nodes[$nodeKey] = @{
                hostname = $hostname
                ip_address = $ip
            }
        }
    }
    
    if ($result.physical_nodes.Count -eq 0) {
        Write-Warning "Simple YAML parser found no physical_nodes. Consider installing PowerShell-YAML module or Python with PyYAML."
    }
    
    return $result
}

# ============================================================================
# Helper Functions
# ============================================================================

function Get-LocalIPv4 {
    $ips = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { 
            $_.IPAddress -notlike "169.254.*" -and 
            $_.IPAddress -ne "127.0.0.1" -and 
            $_.InterfaceAlias -notlike "*Loopback*" 
        } |
        Select-Object -ExpandProperty IPAddress -Unique
    
    return $ips
}

function Get-PhysicalNodeFromMapping {
    param(
        [string]$Hostname,
        [array]$IPs,
        [object]$Mapping
    )
    
    $physicalNode = $null
    
    # Get keys - handle both hashtable and PSCustomObject
    $nodeKeys = @()
    if ($Mapping.physical_nodes -is [hashtable]) {
        $nodeKeys = $Mapping.physical_nodes.Keys
    } else {
        $nodeKeys = $Mapping.physical_nodes.PSObject.Properties.Name
    }
    
    # Method A: Match by hostname (preferred)
    foreach ($key in $nodeKeys) {
        $entry = $Mapping.physical_nodes.$key
        $entryHostname = if ($entry.hostname) { $entry.hostname } elseif ($entry.Hostname) { $entry.Hostname } else { $null }
        if ($entryHostname -and ($entryHostname.ToUpper() -eq $Hostname.ToUpper())) {
            $physicalNode = $key
            Write-Host "Matched physical_node '$physicalNode' by hostname: $Hostname" -ForegroundColor Green
            return $physicalNode
        }
    }
    
    # Method B: Match by IP (fallback)
    foreach ($key in $nodeKeys) {
        $entry = $Mapping.physical_nodes.$key
        $entryIP = if ($entry.ip_address) { $entry.ip_address } elseif ($entry.IP_address) { $entry.IP_address } elseif ($entry.ipAddress) { $entry.ipAddress } else { $null }
        if ($entryIP -and ($IPs -contains $entryIP)) {
            $physicalNode = $key
            Write-Host "Matched physical_node '$physicalNode' by IP: $entryIP" -ForegroundColor Green
            return $physicalNode
        }
    }
    
    # No match found - error with diagnostic info
    $mappingHostnames = @()
    $mappingIPs = @()
    foreach ($key in $nodeKeys) {
        $entry = $Mapping.physical_nodes.$key
        $entryHostname = if ($entry.hostname) { $entry.hostname } elseif ($entry.Hostname) { $entry.Hostname } else { $null }
        $entryIP = if ($entry.ip_address) { $entry.ip_address } elseif ($entry.IP_address) { $entry.IP_address } elseif ($entry.ipAddress) { $entry.ipAddress } else { $null }
        if ($entryHostname) { $mappingHostnames += "$key=$entryHostname" }
        if ($entryIP) { $mappingIPs += "$key=$entryIP" }
    }
    
    Write-Host "ERROR: Could not map this machine to a physical_node" -ForegroundColor Red
    Write-Host "  Detected hostname: $Hostname" -ForegroundColor Yellow
    Write-Host "  Detected IPs: $($IPs -join ', ')" -ForegroundColor Yellow
    Write-Host "  Mapping hostnames: $($mappingHostnames -join ', ')" -ForegroundColor Yellow
    Write-Host "  Mapping IPs: $($mappingIPs -join ', ')" -ForegroundColor Yellow
    throw "Could not map this machine to a physical_node. hostname=$Hostname ips=$($IPs -join ',')"
}

function Get-DesiredAnsibleHost {
    param(
        [string]$PhysicalNode,
        [object]$Mapping
    )
    
    $useDns = if ($Mapping.use_dns) { [bool]$Mapping.use_dns } else { $false }
    $nodeEntry = $Mapping.physical_nodes.$PhysicalNode
    
    $hostname = if ($nodeEntry.hostname) { $nodeEntry.hostname } elseif ($nodeEntry.Hostname) { $nodeEntry.Hostname } else { $null }
    $ipAddress = if ($nodeEntry.ip_address) { $nodeEntry.ip_address } elseif ($nodeEntry.IP_address) { $nodeEntry.IP_address } elseif ($nodeEntry.ipAddress) { $nodeEntry.ipAddress } else { $null }
    
    if ($useDns) {
        return $hostname
    } else {
        return $ipAddress
    }
}

function Get-WinRMHttpsThumbprint {
    # Try to get thumbprint from WinRM HTTPS listener
    try {
        $listenerOutput = winrm enumerate winrm/config/Listener 2>&1
        if ($listenerOutput -match 'CertificateThumbprint\s*=\s*([A-F0-9]+)') {
            return $Matches[1]
        }
    } catch {
        # Continue to cert store method
    }
    
    # Fallback: Get cert from cert store bound to 5986 or matching hostname
    $hostname = $env:COMPUTERNAME
    try {
        $certs = Get-ChildItem Cert:\LocalMachine\My | 
            Where-Object { 
                ($_.Subject -like "*CN=$hostname*" -or $_.Subject -like "*CN=$hostname.*") -and
                $_.HasPrivateKey
            } |
            Sort-Object NotAfter -Descending
        
        if ($certs) {
            return $certs[0].Thumbprint
        }
    } catch {
        # Return empty if we can't find it
    }
    
    return ""
}

function Get-WSLDistros {
    $distros = @()
    try {
        $wslOutput = wsl.exe --list --quiet 2>&1
        if ($LASTEXITCODE -eq 0 -and $wslOutput) {
            $distros = $wslOutput | Where-Object { $_ -and $_.Trim().Length -gt 0 } | ForEach-Object { $_.Trim() }
        }
    } catch {
        # WSL not available, return empty array
    }
    return $distros
}

function Write-Yaml {
    param(
        [string]$Path,
        [hashtable]$Data
    )
    
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    $yamlLines = @("---")
    
    foreach ($key in $Data.Keys) {
        $value = $Data[$key]
        
        # Handle different value types
        if ($null -eq $value) {
            $yamlLines += "$key`: null"
        } elseif ($value -is [bool]) {
            $yamlLines += "$key`: $($value.ToString().ToLower())"
        } elseif ($value -is [int] -or $value -is [long]) {
            $yamlLines += "$key`: $value"
        } elseif ($value -is [string]) {
            # Escape quotes and wrap in quotes if needed
            $escaped = $value -replace '"', '\"'
            $yamlLines += "$key`: `"$escaped`""
        } elseif ($value -is [array]) {
            $yamlLines += "$key`:"
            foreach ($item in $value) {
                if ($item -is [string]) {
                    $yamlLines += "  - `"$item`""
                } else {
                    $yamlLines += "  - $item"
                }
            }
        } else {
            # Fallback: convert to string
            $yamlLines += "$key`: `"$($value.ToString())`""
        }
    }
    
    $yamlLines | Set-Content -Path $Path -Encoding UTF8
}

function Write-Facts {
    param(
        [string]$Path,
        [object]$Obj
    )
    
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $Obj | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Host "=== Dynamic Bootstrap Local ===" -ForegroundColor Cyan
Write-Host ""

# Load mapping
$mappingPath = Join-Path $repoRoot "inventory\hosts_mapping.yaml"
Write-Host "Loading mapping from: $mappingPath" -ForegroundColor Cyan
$mapping = Import-Yaml $mappingPath

# Detect physical node
$hostname = $env:COMPUTERNAME
$ips = Get-LocalIPv4
Write-Host "Detected hostname: $hostname" -ForegroundColor Cyan
Write-Host "Detected IPs: $($ips -join ', ')" -ForegroundColor Cyan

$physicalNode = Get-PhysicalNodeFromMapping -Hostname $hostname -IPs $ips -Mapping $mapping
$ansibleHost = Get-DesiredAnsibleHost -PhysicalNode $physicalNode -Mapping $mapping

Write-Host "Physical node: $physicalNode" -ForegroundColor Green
Write-Host "Ansible host: $ansibleHost" -ForegroundColor Green
Write-Host ""

# Collect facts
Write-Host "Collecting facts..." -ForegroundColor Cyan

# Get best IP (use mapped IP or first detected)
$nodeEntry = $mapping.physical_nodes.$physicalNode
$mappedIP = if ($nodeEntry.ip_address) { $nodeEntry.ip_address } elseif ($nodeEntry.IP_address) { $nodeEntry.IP_address } elseif ($nodeEntry.ipAddress) { $nodeEntry.ipAddress } else { $null }
$bestIP = $mappedIP
if (-not $bestIP -or -not ($ips -contains $bestIP)) {
    $bestIP = if ($ips.Count -gt 0) { $ips[0] } else { "0.0.0.0" }
}

# Configure WinRM HTTPS
Write-Host "Configuring WinRM HTTPS..." -ForegroundColor Cyan
Enable-PSRemoting -Force | Out-Null
Set-Service WinRM -StartupType Automatic | Out-Null
Start-Service WinRM | Out-Null

# Create/ensure HTTPS listener on 5986
$existingHttps = (winrm enumerate winrm/config/listener) -match "Transport = HTTPS"
if (-not $existingHttps) {
    $cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation Cert:\LocalMachine\My
    $thumb = $cert.Thumbprint
    winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumb`"}" | Out-Null
} else {
    $thumb = Get-WinRMHttpsThumbprint
}

# Firewall for 5986
if (-not (Get-NetFirewallRule -DisplayName "WinRM HTTPS 5986" -ErrorAction SilentlyContinue)) {
    netsh advfirewall firewall add rule name="WinRM HTTPS 5986" dir=in action=allow protocol=TCP localport=5986 | Out-Null
}

# Get WSL distros
$wslDistros = Get-WSLDistros
if ($wslDistros.Count -gt 0) {
    Write-Host "Found WSL distros: $($wslDistros -join ', ')" -ForegroundColor Green
} else {
    Write-Host "No WSL distros found" -ForegroundColor Yellow
}

# Build facts object
$facts = [ordered]@{
    physical_node = $physicalNode
    windows = [ordered]@{
        hostname = $hostname
        host_ip = $bestIP
        winrm_port = 5986
        winrm_transport = "ntlm"
        winrm_https_thumbprint = $thumb
    }
    wsl = [ordered]@{
        distros = $wslDistros
    }
}

# Write facts JSON
$factsPath = Join-Path $repoRoot "facts\$physicalNode.facts.json"
Write-Host "Writing facts to: $factsPath" -ForegroundColor Cyan
Write-Facts -Path $factsPath -Obj $facts

# Generate host_vars
$hostVarsDir = Join-Path $repoRoot "inventory\host_vars"

# Read existing host_vars to preserve secrets (win_password, etc.)
$winVarsPath = Join-Path $hostVarsDir "$physicalNode-win.yaml"
$wslVarsPath = Join-Path $hostVarsDir "$physicalNode-wsl.yaml"

$existingWinVars = @{}
$existingWslVars = @{}

if (Test-Path $winVarsPath) {
    try {
        $existingWinContent = Get-Content $winVarsPath -Raw
        if ($existingWinContent -match 'win_user:\s*(.+)') { $existingWinVars.win_user = $Matches[1].Trim() }
        if ($existingWinContent -match 'win_password:\s*(.+)') { $existingWinVars.win_password = $Matches[1].Trim() }
    } catch { }
}

if (Test-Path $wslVarsPath) {
    try {
        $existingWslContent = Get-Content $wslVarsPath -Raw
        if ($existingWslContent -match 'wsl_user:\s*(.+)') { $existingWslVars.wsl_user = $Matches[1].Trim() }
        if ($existingWslContent -match 'wsl_ssh_port:\s*(\d+)') { $existingWslVars.wsl_ssh_port = [int]$Matches[1] }
        if ($existingWslContent -match 'wsl_distro:\s*(.+)') { $existingWslVars.wsl_distro = $Matches[1].Trim() }
    } catch { }
}

# Generate Windows host_vars
$winVars = [ordered]@{
    physical_node = $physicalNode
    ansible_host = $ansibleHost
    ansible_connection = "winrm"
    ansible_port = 5986
    ansible_winrm_transport = "ntlm"
    ansible_winrm_server_cert_validation = "ignore"
}

# Preserve existing values or set defaults
$winVars.ansible_user = if ($existingWinVars.win_user) { $existingWinVars.win_user } else { "josh" }
if ($existingWinVars.win_password) {
    $winVars.ansible_password = $existingWinVars.win_password
}

# Optionally add thumbprint if we want to validate
if ($thumb) {
    $winVars.ansible_winrm_cert_thumbprint = $thumb
}

Write-Host "Writing Windows host_vars to: $winVarsPath" -ForegroundColor Cyan
Write-Yaml -Path $winVarsPath -Data $winVars

# Generate WSL host_vars
$wslVars = [ordered]@{
    physical_node = $physicalNode
    ansible_host = $ansibleHost
    ansible_connection = "ssh"
    ansible_port = 22
}

# Preserve existing values or set defaults
$wslVars.ansible_user = if ($existingWslVars.wsl_user) { $existingWslVars.wsl_user } else { "josh" }
if ($existingWslVars.wsl_ssh_port) {
    $wslVars.ansible_port = $existingWslVars.wsl_ssh_port
}
if ($wslDistros.Count -gt 0 -and -not $existingWslVars.wsl_distro) {
    $wslVars.wsl_distro = $wslDistros[0]
} elseif ($existingWslVars.wsl_distro) {
    $wslVars.wsl_distro = $existingWslVars.wsl_distro
}

Write-Host "Writing WSL host_vars to: $wslVarsPath" -ForegroundColor Cyan
Write-Yaml -Path $wslVarsPath -Data $wslVars

Write-Host ""
Write-Host "=== Bootstrap Complete ===" -ForegroundColor Green
Write-Host "Generated files:" -ForegroundColor Cyan
Write-Host "  - $factsPath" -ForegroundColor White
Write-Host "  - $winVarsPath" -ForegroundColor White
Write-Host "  - $wslVarsPath" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review generated host_vars files" -ForegroundColor White
Write-Host "  2. Run bin/bootstrap-local.sh inside WSL (if WSL is available)" -ForegroundColor White
Write-Host "  3. Run Ansible playbooks from your Mac using the generated host_vars" -ForegroundColor White

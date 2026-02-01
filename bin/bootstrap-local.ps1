# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script:
# 1. Auto-detects which physical node it's running on (by hostname or IP)
# 2. Collects runtime facts (hostname, IP, WSL distros)
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

function Load-MappingYaml {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        throw "YAML file not found: $Path"
    }
    
    # Try PowerShell-YAML module first
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Import-Module powershell-yaml -ErrorAction SilentlyContinue
        if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
            $raw = Get-Content -Raw -Path $Path
            $mapping = $raw | ConvertFrom-Yaml
            if (-not $mapping -or -not $mapping.physical_nodes) {
                throw "Mapping YAML loaded but missing physical_nodes. Check formatting in $Path"
            }
            return $mapping
        }
    }
    
    # Module not available, try to install it
    Write-Host "PowerShell-YAML module not found. Installing..." -ForegroundColor Yellow
    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        Install-Module powershell-yaml -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
        Import-Module powershell-yaml -Force -ErrorAction Stop
        if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
            $raw = Get-Content -Raw -Path $Path
            $mapping = $raw | ConvertFrom-Yaml
            if (-not $mapping -or -not $mapping.physical_nodes) {
                throw "Mapping YAML loaded but missing physical_nodes. Check formatting in $Path"
            }
            return $mapping
        }
    } catch {
        Write-Host "Failed to install/import PowerShell-YAML module: $_" -ForegroundColor Yellow
        Write-Host "Falling back to Python YAML parsing..." -ForegroundColor Yellow
    }
    
    # Fallback: Use Python if available
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    }
    
    if ($pythonCmd) {
        try {
            $pythonScript = "import yaml,json,sys; print(json.dumps(yaml.safe_load(open(sys.argv[1],'r',encoding='utf-8')), indent=2))"
            $jsonContent = & $pythonCmd -c $pythonScript $Path 2>$null
            if ($jsonContent -and $jsonContent.Trim().Length -gt 0) {
                $mapping = $jsonContent | ConvertFrom-Json
                if (-not $mapping -or -not $mapping.physical_nodes) {
                    throw "Mapping YAML loaded but missing physical_nodes. Check formatting in $Path"
                }
                return $mapping
            }
        } catch {
            Write-Host "Python YAML parsing failed: $_" -ForegroundColor Yellow
        }
    }
    
    # Neither method worked
    throw "Could not load YAML file. Install PowerShell-YAML module with: Install-Module powershell-yaml -Scope CurrentUser"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Get-PreferredIPv4 {
    param(
        [object]$Mapping
    )
    
    # Collect all IPv4 addresses
    $allIPs = Get-NetIPAddress -AddressFamily IPv4
    
    # Filter out unwanted IPs
    $filteredIPs = $allIPs | Where-Object {
        $ip = $_.IPAddress
        $alias = $_.InterfaceAlias
        $prefixOrigin = $_.PrefixOrigin
        
        # Exclude link-local, loopback, and invalid origins
        if ($ip -like "169.254.*" -or $ip -eq "127.0.0.1") { return $false }
        if ($prefixOrigin -eq "WellKnown") { return $false }
        
        # Exclude virtual adapter interfaces
        $virtualKeywords = @("vEthernet", "WSL", "Hyper-V", "Docker", "Virtual", "Loopback")
        foreach ($keyword in $virtualKeywords) {
            if ($alias -like "*$keyword*") { return $false }
        }
        
        return $true
    } | Select-Object -ExpandProperty IPAddress -Unique
    
    # Extract mapping IPs and compute /24 prefixes
    $mappingSubnets = @()
    if ($Mapping -and $Mapping.physical_nodes) {
        $nodeKeys = if ($Mapping.physical_nodes -is [hashtable]) { 
            $Mapping.physical_nodes.Keys 
        } else { 
            $Mapping.physical_nodes.PSObject.Properties.Name 
        }
        
        foreach ($key in $nodeKeys) {
            $entry = $Mapping.physical_nodes.$key
            $mappingIP = if ($entry.ip_address) { $entry.ip_address } 
                        elseif ($entry.IP_address) { $entry.IP_address } 
                        elseif ($entry.ipAddress) { $entry.ipAddress } 
                        else { $null }
            
            if ($mappingIP) {
                # Compute /24 subnet prefix
                $ipParts = $mappingIP -split '\.'
                if ($ipParts.Count -eq 4) {
                    $subnet = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2])."
                    $mappingSubnets += $subnet
                }
            }
        }
    }
    
    # Prefer IPs matching mapping subnets
    $preferredIP = $null
    $reason = "fallback"
    
    if ($mappingSubnets.Count -gt 0) {
        foreach ($subnet in $mappingSubnets) {
            $matchingIP = $filteredIPs | Where-Object { $_ -like "$subnet*" } | Select-Object -First 1
            if ($matchingIP) {
                $preferredIP = $matchingIP
                $subnetBase = $subnet.TrimEnd('.')
                $reason = "matched mapping subnet ${subnetBase}.0/24"
                break
            }
        }
    }
    
    # Fallback to first filtered IP
    if (-not $preferredIP -and $filteredIPs.Count -gt 0) {
        $preferredIP = $filteredIPs[0]
    }
    
    return @{
        PreferredIP = $preferredIP
        AllIPs = $filteredIPs
        Reason = $reason
    }
}

function Get-PhysicalNodeFromMapping {
    param(
        [string]$Hostname,
        [string]$PreferredIP,
        [array]$AllIPs,
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
    
    # Method A: Match by hostname first (preferred, case-insensitive)
    foreach ($key in $nodeKeys) {
        $entry = $Mapping.physical_nodes.$key
        $entryHostname = if ($entry.hostname) { $entry.hostname } elseif ($entry.Hostname) { $entry.Hostname } else { $null }
        if ($entryHostname -and ($entryHostname.ToUpper() -eq $Hostname.ToUpper())) {
            $physicalNode = $key
            Write-Host "Matched physical_node '$physicalNode' by hostname: $Hostname" -ForegroundColor Green
            return $physicalNode
        }
    }
    
    # Method B: Match by preferred IP first, then any IP
    $ipsToCheck = @()
    if ($PreferredIP) { $ipsToCheck += $PreferredIP }
    $ipsToCheck += $AllIPs | Where-Object { $_ -ne $PreferredIP }
    
    foreach ($ipToCheck in $ipsToCheck) {
        foreach ($key in $nodeKeys) {
            $entry = $Mapping.physical_nodes.$key
            $entryIP = if ($entry.ip_address) { $entry.ip_address } elseif ($entry.IP_address) { $entry.IP_address } elseif ($entry.ipAddress) { $entry.ipAddress } else { $null }
            if ($entryIP -and ($entryIP -eq $ipToCheck)) {
                $physicalNode = $key
                Write-Host "Matched physical_node '$physicalNode' by IP: $entryIP" -ForegroundColor Green
                return $physicalNode
            }
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
    Write-Host "  Detected IPs: $($AllIPs -join ', ')" -ForegroundColor Yellow
    Write-Host "  Preferred IP: $PreferredIP" -ForegroundColor Yellow
    Write-Host "  Mapping hostnames: $($mappingHostnames -join ', ')" -ForegroundColor Yellow
    Write-Host "  Mapping IPs: $($mappingIPs -join ', ')" -ForegroundColor Yellow
    throw "Could not map this machine to a physical_node. hostname=$Hostname preferred_ip=$PreferredIP all_ips=$($AllIPs -join ',')"
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

function Get-WSLDistros {
    $distros = @()
    try {
        $wslOutput = wsl.exe --list --quiet 2>&1
        if ($LASTEXITCODE -eq 0 -and $wslOutput) {
            # Process output - handle both array and string formats
            $lines = if ($wslOutput -is [array]) { $wslOutput } else { $wslOutput -split "`r?`n" }
            $distros = $lines | ForEach-Object { 
                # Remove null bytes and trim
                $cleaned = $_ -replace "`0", "" | ForEach-Object { $_.Trim() }
                # Only include if it has printable characters (not just control chars or whitespace)
                if ($cleaned -and $cleaned.Length -gt 0 -and $cleaned -match '[a-zA-Z0-9]') { 
                    $cleaned 
                }
            } | Where-Object { $_ }
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
$mapping = Load-MappingYaml -Path $mappingPath

# Detect physical node
$hostname = $env:COMPUTERNAME
$ipInfo = Get-PreferredIPv4 -Mapping $mapping
$preferredIP = $ipInfo.PreferredIP
$allIPs = $ipInfo.AllIPs

Write-Host "Detected hostname: $hostname" -ForegroundColor Cyan
Write-Host "Detected IPs: $($allIPs -join ', ')" -ForegroundColor Cyan
Write-Host "Chosen IP: $preferredIP" -ForegroundColor Cyan
Write-Host "Reason: $($ipInfo.Reason)" -ForegroundColor Cyan

$physicalNode = Get-PhysicalNodeFromMapping -Hostname $hostname -PreferredIP $preferredIP -AllIPs $allIPs -Mapping $mapping
$ansibleHost = Get-DesiredAnsibleHost -PhysicalNode $physicalNode -Mapping $mapping

Write-Host "Physical node: $physicalNode" -ForegroundColor Green
Write-Host "Ansible host: $ansibleHost" -ForegroundColor Green
Write-Host ""

# Collect facts
Write-Host "Collecting facts..." -ForegroundColor Cyan

# Use preferred IP
$bestIP = if ($preferredIP) { $preferredIP } else { "0.0.0.0" }

# Configure WinRM HTTP
Write-Host "Configuring WinRM HTTP..." -ForegroundColor Cyan
winrm quickconfig -force | Out-Null
# This sets up:
# - WinRM HTTP listener on 5985
# - Firewall rules
# - Service startup
# No certs involved.

# Get WSL distros
$wslDistros = Get-WSLDistros
if ($wslDistros.Count -gt 0) {
    Write-Host "WSL distribution found: $($wslDistros -join ', ')" -ForegroundColor Green
} else {
    Write-Host "No WSL distros found" -ForegroundColor Yellow
}

# Build facts object
$facts = [ordered]@{
    physical_node = $physicalNode
    windows = [ordered]@{
        hostname = $hostname
        host_ip = $bestIP
        winrm_port = 5985
        winrm_transport = "ntlm"
        winrm_scheme = "http"
    }
    wsl = [ordered]@{
        distros = $wslDistros
    }
}

# Write facts JSON
$factsPath = Join-Path $repoRoot "facts\$physicalNode.json"
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
    ansible_port = 5985
    ansible_winrm_transport = "ntlm"
    ansible_winrm_scheme = "http"
    ansible_winrm_server_cert_validation = "ignore"
}

# Preserve existing values or set defaults
$winVars.ansible_user = if ($existingWinVars.win_user) { $existingWinVars.win_user } else { "josh" }
if ($existingWinVars.win_password) {
    $winVars.ansible_password = $existingWinVars.win_password
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

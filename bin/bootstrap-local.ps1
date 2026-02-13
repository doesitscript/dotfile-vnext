# bin/bootstrap-local.ps1
# Run as admin on the target Windows machine
# This script:
# 1. Auto-detects which physical node it's running on (by hostname or IP)
# 2. Collects runtime facts (hostname, IP, WSL distros)
# 3. Generates host_vars files for Windows and WSL surfaces
# 4. Writes facts JSON for auditing/reuse
#
# .QUICK COMMANDS
#   .\bin\bootstrap-local.ps1 -FactsOnly       Only collect facts (no host_vars, no chain)
#   .\bin\bootstrap-local.ps1 -RunAll:$false   Facts + host_vars only (no WSL/fz chain)
#   .\bin\bootstrap-local.ps1                  Full chain -> bootstrap-ansible-local.ps1 -> WSL -> fz

param(
    [bool]$RunAll = $true,
    [switch]$FactsOnly = $false
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
Write-Verbose "Verbose output enabled (VerbosePreference=Continue)"

function Write-Step([string]$Message) { Write-Host "[STEP] $Message" -ForegroundColor Cyan; Write-Verbose "[STEP] $Message" }
function Write-Check([string]$Message) { Write-Host "[CHECK] $Message" -ForegroundColor Yellow; Write-Verbose "[CHECK] $Message" }
function Write-Set([string]$Message) { Write-Host "[SET] $Message" -ForegroundColor Cyan; Write-Verbose "[SET] $Message" }
function Write-Skip([string]$Message) { Write-Host "[SKIP] $Message" -ForegroundColor Yellow; Write-Verbose "[SKIP] $Message" }
function Write-Ok([string]$Message) { Write-Host "[OK] $Message" -ForegroundColor Green; Write-Verbose "[OK] $Message" }
function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor White; Write-Verbose "[INFO] $Message" }

# Ensure the current user can run scripts without interactive prompts.
try {
    $currentUserPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Verbose "CurrentUser execution policy detected: $currentUserPolicy"
    if ($currentUserPolicy -ne "Bypass") {
        Write-Verbose "Setting CurrentUser execution policy to Bypass"
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
        Write-Host "Set CurrentUser execution policy to Bypass." -ForegroundColor Green
    } else {
        Write-Host "CurrentUser execution policy already Bypass." -ForegroundColor Green
    }
} catch {
    Write-Host "WARNING: Could not set CurrentUser execution policy: $_" -ForegroundColor Yellow
}

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Verbose "Elevation check result: isAdmin=$isAdmin"
if (-not $isAdmin) {
    Write-Error "[ERROR] This script must be run as Administrator." -ErrorAction Continue
    Write-Host "  Re-run this script from an elevated PowerShell terminal." -ForegroundColor Yellow
    Write-Host "  If Cursor terminal elevation is broken, run this first:" -ForegroundColor Yellow
    Write-Host "    .\bin\bootstrap-ide-cursor.ps1" -ForegroundColor Cyan
    Write-Host "  Then restart Cursor as Administrator and run this script again." -ForegroundColor Yellow
    exit 1
}

# Get script directory and repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
Write-Verbose "scriptDir=$scriptDir"
Write-Verbose "repoRoot=$repoRoot"

# ============================================================================
# YAML Loading Functions
# ============================================================================

function Load-MappingYaml {
    param([string]$Path)
    Write-Verbose "Load-MappingYaml: path=$Path"
    
    if (-not (Test-Path $Path)) {
        throw "YAML file not found: $Path"
    }
    
    # Try PowerShell-YAML module first
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Write-Verbose "PowerShell-YAML module found. Attempting ConvertFrom-Yaml path."
        Import-Module powershell-yaml -ErrorAction SilentlyContinue
        if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
            $raw = Get-Content -Raw -Path $Path -Encoding UTF8 -ErrorAction SilentlyContinue
            if (-not $raw) { $raw = Get-Content -Raw -Path $Path }
            $raw = Strip-YamlControlChars $raw
            $mapping = $raw | ConvertFrom-Yaml
            if (-not $mapping -or -not $mapping.physical_nodes) {
                throw "Mapping YAML loaded but missing physical_nodes. Check formatting in $Path"
            }
            return $mapping
        }
    }
    
    # Module not available, try to install it
    Write-Host "PowerShell-YAML module not found. Installing..." -ForegroundColor Yellow
    Write-Verbose "Attempting to install PowerShell-YAML module from PSGallery."
    try {
        # Trust PSGallery repository (non-interactive)
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue | Out-Null
        # Install module without prompts (non-interactive flags)
        Install-Module powershell-yaml -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -Confirm:$false -ErrorAction Stop
        Import-Module powershell-yaml -Force -ErrorAction Stop
        if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
            $raw = Get-Content -Raw -Path $Path -Encoding UTF8 -ErrorAction SilentlyContinue
            if (-not $raw) { $raw = Get-Content -Raw -Path $Path }
            $raw = Strip-YamlControlChars $raw
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
        Write-Verbose "Using Python fallback for YAML parsing: $($pythonCmd.Source)"
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
    
    Write-Verbose "Get-PreferredIPv4: collecting IPv4 addresses."
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
    Write-Verbose "Filtered IPv4 candidates: $($filteredIPs -join ', ')"
    
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
    Write-Verbose "Mapping subnets considered: $($mappingSubnets -join ', ')"
    
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
    
    Write-Verbose "Get-PhysicalNodeFromMapping: hostname=$Hostname preferredIP=$PreferredIP allIPs=$($AllIPs -join ', ')"
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
    
    Write-Error "[ERROR] Could not map this machine to a physical_node" -ErrorAction Continue
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
    Write-Verbose "Get-DesiredAnsibleHost: physical_node=$PhysicalNode use_dns=$useDns"
    $nodeEntry = $Mapping.physical_nodes.$PhysicalNode
    
    $hostname = if ($nodeEntry.hostname) { $nodeEntry.hostname } elseif ($nodeEntry.Hostname) { $nodeEntry.Hostname } else { $null }
    $ipAddress = if ($nodeEntry.ip_address) { $nodeEntry.ip_address } elseif ($nodeEntry.IP_address) { $nodeEntry.IP_address } elseif ($nodeEntry.ipAddress) { $nodeEntry.ipAddress } else { $null }
    
    if ($useDns) {
        return $hostname
    } else {
        return $ipAddress
    }
}

function Test-WSLInstalled {
    # Check if WSL feature is enabled
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        Write-Verbose "WSL feature state: $($wslFeature.State)"
        return ($wslFeature -and $wslFeature.State -eq "Enabled")
    } catch {
        # Non-admin or DISM unavailable in current session.
        Write-Verbose "Test-WSLInstalled failed to query feature state: $_"
        return $false
    }
}

function Install-WSLFeature {
    Write-Host "WSL feature not installed. Installing..." -ForegroundColor Yellow
    Write-Verbose "Running Enable-WindowsOptionalFeature for Microsoft-Windows-Subsystem-Linux"
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop | Out-Null
        Write-Host "WSL feature installed. Reboot may be required." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to install WSL feature: $_" -ForegroundColor Red
        return $false
    }
}

function Install-WSLDistro {
    param([string]$DistroName = "Ubuntu")
    
    Write-Host "Installing WSL distro: $DistroName" -ForegroundColor Yellow
    Write-Verbose "Running wsl.exe --install -d $DistroName"
    try {
        # Install the distro using wsl --install
        wsl.exe --install -d $DistroName 2>&1 | Out-Null
        
        # Wait a moment for installation to start/complete
        Start-Sleep -Seconds 3
        
        # Check if installation was successful
        $distros = Get-WSLDistros
        if ($distros -contains $DistroName) {
            Write-Host "WSL distro '$DistroName' installed successfully" -ForegroundColor Green
            return $true
        } else {
            # Installation may be in progress or require reboot
            Write-Host "WSL distro installation initiated for '$DistroName'" -ForegroundColor Yellow
            Write-Host "Note: Installation may take several minutes and a reboot may be required." -ForegroundColor Yellow
            Write-Host "After reboot, run 'wsl' to complete the setup." -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "Failed to install WSL distro: $_" -ForegroundColor Red
        return $false
    }
}

function Get-WSLDistros {
    $distros = @()
    Write-Verbose "Querying installed WSL distros via 'wsl.exe --list --quiet'"
    try {
        $wslOutput = wsl.exe --list --quiet 2>&1
        if ($LASTEXITCODE -eq 0 -and $wslOutput) {
            # Process output - handle both array and string formats
            $lines = if ($wslOutput -is [array]) { $wslOutput } else { $wslOutput -split "`r?`n" }
            $distros = @($lines | ForEach-Object { 
                # Remove null bytes and trim
                $cleaned = $_ -replace "`0", "" | ForEach-Object { $_.Trim() }
                # Only include if it has printable characters (not just control chars or whitespace)
                if ($cleaned -and $cleaned.Length -gt 0 -and $cleaned -match '[a-zA-Z0-9]') { 
                    $cleaned 
                }
            } | Where-Object { $_ })
            Write-Verbose "Parsed WSL distro list: $($distros -join ', ')"
        }
    } catch {
        # WSL not available, return empty array
        Write-Verbose "Get-WSLDistros failed: $_"
    }
    return $distros
}

# Remove control characters (0x00-0x1F) except tab, newline, carriage return. Prevents YAML "unacceptable character #x0000" errors.
function Strip-YamlControlChars {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $Text.ToCharArray()) {
        $code = [int][char]$c
        if ($code -ge 32 -or $code -eq 9 -or $code -eq 10 -or $code -eq 13) {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString()
}

function Write-Yaml {
    param(
        [string]$Path,
        [hashtable]$Data
    )
    
    Write-Verbose "Write-Yaml: path=$Path keys=$($Data.Keys -join ', ')"
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    $yamlLines = @("---")
    
    foreach ($key in $Data.Keys) {
        $value = $Data[$key]
        
        # Handle different value types (sanitize strings so no control chars reach YAML)
        if ($null -eq $value) {
            $yamlLines += "$key`: null"
        } elseif ($value -is [bool]) {
            $yamlLines += "$key`: $($value.ToString().ToLower())"
        } elseif ($value -is [int] -or $value -is [long]) {
            $yamlLines += "$key`: $value"
        } elseif ($value -is [string]) {
            $clean = Strip-YamlControlChars $value
            $escaped = $clean -replace '"', '\"'
            $yamlLines += "$key`: `"$escaped`""
        } elseif ($value -is [array]) {
            $yamlLines += "$key`:"
            foreach ($item in $value) {
                if ($item -is [string]) {
                    $cleanItem = Strip-YamlControlChars $item
                    $yamlLines += "  - `"$cleanItem`""
                } else {
                    $yamlLines += "  - $item"
                }
            }
        } else {
            $clean = Strip-YamlControlChars $value.ToString()
            $yamlLines += "$key`: `"$clean`""
        }
    }
    
    # Use System.IO.File to write UTF-8 without BOM (ensures compatibility with YAML parsers)
    # This prevents the UTF-16 encoding issue that was causing YAML parsing errors
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($Path, $yamlLines, $utf8NoBom)
}

function Write-Facts {
    param(
        [string]$Path,
        [object]$Obj
    )
    
    Write-Verbose "Write-Facts: path=$Path"
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    # This specific encoding method is the key to removing the 'invisible' header errors
    $jsonContent = $Obj | ConvertTo-Json -Depth 10
    $jsonLines = $jsonContent -split "`r?`n"
    [System.IO.File]::WriteAllLines($Path, $jsonLines)
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Step "Dynamic Bootstrap Local"
Write-Host ""
Write-Verbose "Starting main bootstrap execution."

# Load mapping
$mappingPath = Join-Path $repoRoot "inventory\hosts_mapping.yaml"
Write-Check "Loading mapping from: $mappingPath"
$mapping = Load-MappingYaml -Path $mappingPath
Write-Verbose "Mapping loaded successfully."

# Detect physical node
$hostname = $env:COMPUTERNAME
$ipInfo = Get-PreferredIPv4 -Mapping $mapping
$preferredIP = $ipInfo.PreferredIP
$allIPs = $ipInfo.AllIPs

Write-Info "Detected hostname: $hostname"
Write-Info "Detected IPs: $($allIPs -join ', ')"
Write-Info "Chosen IP: $preferredIP"
Write-Info "Reason: $($ipInfo.Reason)"
Write-Verbose "Preferred IP decision reason: $($ipInfo.Reason)"

$physicalNode = Get-PhysicalNodeFromMapping -Hostname $hostname -PreferredIP $preferredIP -AllIPs $allIPs -Mapping $mapping
$ansibleHost = Get-DesiredAnsibleHost -PhysicalNode $physicalNode -Mapping $mapping

Write-Ok "Physical node: $physicalNode"
Write-Ok "Ansible host: $ansibleHost"
Write-Host ""

# Collect facts
Write-Step "Collecting runtime facts"
Write-Verbose "Beginning privileged setup and fact collection."

# Use preferred IP
$bestIP = if ($preferredIP) { $preferredIP } else { "0.0.0.0" }

Write-Set "Configuring WinRM HTTP listener/service/firewall (port 5985)"
Write-Verbose "Running winrm quickconfig -force"
winrm quickconfig -force | Out-Null
# This sets up: WinRM HTTP listener on 5985, firewall rules, service startup. Mac connects via HTTP (5985).

# Check and install WSL if needed
Write-Check "Checking WSL feature state"
$wslInstalled = Test-WSLInstalled
Write-Verbose "Initial WSL installed check: $wslInstalled"

if (-not $wslInstalled) {
    $wslInstalled = Install-WSLFeature
    if (-not $wslInstalled) {
        Write-Host "WARNING: Could not install WSL feature. WSL functionality will be unavailable." -ForegroundColor Red
    }
}

# Get WSL distros
$wslDistros = Get-WSLDistros

if ($wslDistros.Count -eq 0) {
    if ($wslInstalled) {
        Write-Set "No WSL distros found. Installing Ubuntu..."
        Install-WSLDistro -DistroName "Ubuntu"
        # Refresh distro list after installation attempt
        Start-Sleep -Seconds 2
        $wslDistros = Get-WSLDistros
        Write-Verbose "WSL distros after install attempt: $($wslDistros -join ', ')"
    } else {
        Write-Host "WSL feature not available. Skipping distro installation." -ForegroundColor Yellow
    }
}

if ($wslDistros.Count -gt 0) {
    Write-Ok "WSL distribution found: $($wslDistros -join ', ')"
} else {
    Write-Skip "No WSL distros available"
}

# Build facts object (WinRM HTTP 5985 for Mac/Ansible)
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
Write-Set "Writing facts to: $factsPath"
Write-Facts -Path $factsPath -Obj $facts
Write-Verbose "Facts written successfully."

if ($FactsOnly) {
    Write-Ok "FactsOnly: stopping after fact collection (no host_vars, no chain)."
    exit 0
}

# Generate host_vars
$hostVarsDir = Join-Path $repoRoot "inventory\host_vars"

# Read existing host_vars to preserve secrets (win_password, etc.)
# BUG: Plaintext string parsing can fail if passwords contain special regex characters
# or non-standard YAML formatting. If regex parsing fails, the password will be lost.
# Consider using Ansible Vault for sensitive values instead of plaintext host_vars.
$winVarsPath = Join-Path $hostVarsDir "$physicalNode-win.yaml"
$wslVarsPath = Join-Path $hostVarsDir "$physicalNode-wsl.yaml"

$existingWinVars = @{}
$existingWslVars = @{}

if (Test-Path $winVarsPath) {
    Write-Verbose "Existing Windows host_vars found at: $winVarsPath"
    try {
        $rawWin = Get-Content $winVarsPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $rawWin) { $rawWin = Get-Content $winVarsPath -Raw }
        $existingWinContent = Strip-YamlControlChars $rawWin
        # Parse win_user (handle quoted and unquoted values)
        if ($existingWinContent -match 'win_user:\s*"?([^"\r\n]+)"?') { 
            $existingWinVars.win_user = $Matches[1].Trim().Trim('"')
        }
        # Parse win_ssh_port (Windows OpenSSH server port; must be in global section of sshd_config)
        if ($existingWinContent -match '(?m)^win_ssh_port:\s*(\d+)') {
            $existingWinVars.win_ssh_port = [int]$Matches[1]
        }
        # Parse win_password (handle quoted and unquoted values, including special characters)
        # Match: win_password: "value" or win_password: value (handles multiline and special chars)
        if ($existingWinContent -match '(?m)^win_password:\s*(.+?)(?=\r?\n\w+:|$)') { 
            $passwordValue = $Matches[1].Trim()
            # Remove surrounding quotes if present (handles both single and double quotes)
            if ($passwordValue -match '^["''](.+)["'']$') {
                $existingWinVars.win_password = $Matches[1]
            } else {
                $existingWinVars.win_password = $passwordValue
            }
            Write-Host "Preserved win_password from existing file" -ForegroundColor Green
        }
    } catch {
        Write-Host "Warning: Could not parse existing Windows host_vars: $_" -ForegroundColor Yellow
    }
}

if (Test-Path $wslVarsPath) {
    Write-Verbose "Existing WSL host_vars found at: $wslVarsPath"
    try {
        $rawWsl = Get-Content $wslVarsPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $rawWsl) { $rawWsl = Get-Content $wslVarsPath -Raw }
        $existingWslContent = Strip-YamlControlChars $rawWsl
        # Parse wsl_user (handle quoted and unquoted values)
        if ($existingWslContent -match 'wsl_user:\s*"?([^"\r\n]+)"?') { 
            $existingWslVars.wsl_user = $Matches[1].Trim().Trim('"')
        }
        # Parse wsl_ssh_port
        if ($existingWslContent -match 'wsl_ssh_port:\s*(\d+)') { 
            $existingWslVars.wsl_ssh_port = [int]$Matches[1]
        }
        # Parse wsl_distro (handle quoted and unquoted, including empty string)
        # Only preserve if it's a valid non-empty value
        if ($existingWslContent -match 'wsl_distro:\s*"?([^"\r\n]+)"?') { 
            $parsedDistro = $Matches[1].Trim().Trim('"')
            # Only keep if it looks like a valid distro name (has alphanumeric chars)
            if ($parsedDistro -match '[a-zA-Z0-9]') {
                $existingWslVars.wsl_distro = $parsedDistro
            }
        }
    } catch { }
}

# Generate Windows host_vars (WinRM HTTP 5985 for Mac management)
$winVars = [ordered]@{
    physical_node = $physicalNode
    surface_type = "windows_host"
    host_ip = $bestIP
    winrm_port = 5985
    win_user = if ($existingWinVars.win_user) { $existingWinVars.win_user } else { "josh" }
}

# Preserve win_password if it exists
if ($existingWinVars.win_password) {
    $winVars.win_password = $existingWinVars.win_password
    Write-Host "Preserved win_password in generated file" -ForegroundColor Green
} elseif (Test-Path $winVarsPath -and (Get-Content $winVarsPath -Raw) -match 'win_password') {
    Write-Host "WARNING: win_password found in existing file but could not be parsed. It may be lost!" -ForegroundColor Red
    Write-Host "Please manually re-add win_password after this script completes." -ForegroundColor Yellow
}

# Add Ansible connection settings (WinRM HTTP 5985; Mac runs playbooks from Mac)
$winVars.ansible_connection = "winrm"
$winVars.ansible_host = $ansibleHost
$winVars.ansible_user = $winVars.win_user
$winVars.ansible_password = if ($winVars.win_password) { $winVars.win_password } else { "" }
$winVars.ansible_winrm_password = if ($winVars.win_password) { $winVars.win_password } else { "" }
$winVars.ansible_port = 5985
$winVars.ansible_winrm_transport = "ntlm"
$winVars.ansible_winrm_scheme = "http"
$winVars.win_ssh_port = if ($existingWinVars.win_ssh_port) { $existingWinVars.win_ssh_port } else { 22 }

Write-Set "Writing Windows host_vars to: $winVarsPath"
Write-Yaml -Path $winVarsPath -Data $winVars
Write-Verbose "Windows host_vars write complete."

# Generate WSL host_vars (matching template format)
$wslVars = [ordered]@{
    physical_node = $physicalNode
    surface_type = "wsl"
    host_ip = $bestIP
    wsl_user = if ($existingWslVars.wsl_user) { $existingWslVars.wsl_user } else { "josh" }
    wsl_ssh_port = if ($existingWslVars.wsl_ssh_port) { $existingWslVars.wsl_ssh_port } else { 22 }
}

# Set wsl_distro - prefer detected distro over existing (which may be malformed)
if ($wslDistros.Count -gt 0) {
    # Ensure we get the first element as a string, not a character
    $firstDistro = if ($wslDistros -is [array]) { $wslDistros[0] } else { $wslDistros }
    $wslVars.wsl_distro = $firstDistro.ToString()
} elseif ($existingWslVars.wsl_distro -and $existingWslVars.wsl_distro -match '[a-zA-Z0-9]{2,}') {
    # Only use existing if it looks valid (at least 2 alphanumeric chars)
    $wslVars.wsl_distro = $existingWslVars.wsl_distro
} else {
    $wslVars.wsl_distro = ""
}

# Add Ansible connection settings (Mac uses id_ed25519_ansible to SSH to this host)
$wslVars.ansible_connection = "ssh"
$wslVars.ansible_host = $ansibleHost
$wslVars.ansible_user = $wslVars.wsl_user
$wslVars.ansible_port = $wslVars.wsl_ssh_port
$wslVars.ansible_python_interpreter = "/usr/bin/python3"
$wslVars.ansible_ssh_private_key_file = "~/.ssh/id_ed25519_ansible"

Write-Set "Writing WSL host_vars to: $wslVarsPath"
Write-Yaml -Path $wslVarsPath -Data $wslVars
Write-Verbose "WSL host_vars write complete."

Write-Host ""
Write-Ok "Bootstrap Complete"
Write-Step "Generated files"
Write-Host "  - $factsPath" -ForegroundColor White
Write-Host "  - $winVarsPath" -ForegroundColor White
Write-Host "  - $wslVarsPath" -ForegroundColor White
Write-Host ""

# ============================================================================
# OpenSSH Server (Windows): install, port from Ansible (win_ssh_port), firewall, default shell = WSL bash
# Uses distro from our ansible (wsl_distro). Keys: same pattern as WSL so Mac/Win/WSL can talk.
# ============================================================================
$winSshPort = if ($winVars.win_ssh_port) { $winVars.win_ssh_port } else { 22 }
Write-Step "Configuring OpenSSH Server on Windows (port $winSshPort, default shell WSL bash)"

$openSshCapability = Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'OpenSSH.Server*' }
if ($openSshCapability -and $openSshCapability.State -ne 'Installed') {
    Write-Set "Installing OpenSSH Server"
    try {
        $capResult = Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        if ($capResult.RestartNeeded) {
            Write-Host "  [INFO] Reboot may be required for OpenSSH Server." -ForegroundColor Yellow
        }
        Write-Ok "OpenSSH Server installed"
    } catch {
        Write-Host "  [WARNING] OpenSSH Server install failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Skip "OpenSSH Server already installed"
}

# Firewall and sshd config before starting: ensure port from Ansible (win_ssh_port) and config are ready
$fwRule = Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue
if (-not $fwRule) {
    New-NetFirewallRule -Name sshd `
        -DisplayName "OpenSSH Server (Port $winSshPort)" `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort $winSshPort | Out-Null
    Write-Ok "Firewall rule 'sshd' (port $winSshPort) created"
} else {
    Write-Skip "Firewall rule 'sshd' already exists"
}

$sshdConfigPath = 'C:\ProgramData\ssh\sshd_config'
if (Test-Path $sshdConfigPath) {
    $sshdContent = Get-Content $sshdConfigPath -Raw
    # Port must be in global section only (not inside a Match block). Comment out any existing Port lines everywhere.
    $sshdContent = $sshdContent -replace '(?m)^(\s*)(Port\s+\d+)', '$1# $2'
    $portDirective = "Port $winSshPort"
    if ($sshdContent -notmatch [regex]::Escape($portDirective)) {
        # Insert Port in global section: before the first "Match" line (or at end if no Match).
        if ($sshdContent -match '(?ms)^(.*?)(^\s*Match\s.*)') {
            $globalSection = $Matches[1].TrimEnd()
            $fromMatchToEnd = $Matches[2]
            $sshdContent = $globalSection + "`r`n$portDirective`r`n`r`n" + $fromMatchToEnd
        } else {
            $sshdContent = $sshdContent.TrimEnd() + "`r`n$portDirective`r`n"
        }
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($sshdConfigPath, $sshdContent, $utf8NoBom)
        Write-Ok "sshd_config set to $portDirective (global section)"
    } else {
        Write-Verbose "sshd_config already has $portDirective in global section"
    }
}

# Default shell = WSL bash so SSH to Windows drops into our Ubuntu distro
$defaultWslDistro = if ($wslVars.wsl_distro) { $wslVars.wsl_distro } else { 'Ubuntu' }
$defaultWslDistro = Strip-YamlControlChars $defaultWslDistro
if (-not $defaultWslDistro) { $defaultWslDistro = 'Ubuntu' }

if (-not (Test-Path 'HKLM:\SOFTWARE\OpenSSH')) {
    New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null
}
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\wsl.exe' -PropertyType String -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShellCommandOption -Value "-d $defaultWslDistro" -PropertyType String -Force | Out-Null
Write-Ok "Default shell set to WSL ($defaultWslDistro)"

# Ensure host keys exist: idempotent. If we have project keys, replace server keys every time (no prompt).
# Source: bootstrap/openssh_host_keys/ (drop keys from Mac or generate once; names: ssh_host_ed25519_key, ssh_host_rsa_key, etc. + .pub)
$sshDataDir = 'C:\ProgramData\ssh'
$ourHostKeysDir = Join-Path $repoRoot 'bootstrap\openssh_host_keys'
if (-not (Test-Path $sshDataDir)) {
    New-Item -ItemType Directory -Path $sshDataDir -Force | Out-Null
    Write-Verbose "Created $sshDataDir (OpenSSH may not have created it yet)"
}
$ourPrivateKeys = @(Get-ChildItem -Path (Join-Path $ourHostKeysDir 'ssh_host_*_key') -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '\.pub$' })
$weHaveOurKeys = (Test-Path $ourHostKeysDir) -and ($ourPrivateKeys.Count -gt 0)
if ($weHaveOurKeys) {
    Write-Set "Replacing OpenSSH host keys with project keys from bootstrap/openssh_host_keys (idempotent)"
    $allHostKeyFiles = @(Get-ChildItem -Path (Join-Path $ourHostKeysDir 'ssh_host_*') -File -ErrorAction SilentlyContinue)
    foreach ($f in $allHostKeyFiles) {
        Copy-Item -Path $f.FullName -Destination (Join-Path $sshDataDir $f.Name) -Force
        Write-Verbose "Copied $($f.Name) to $sshDataDir"
    }
    Write-Ok "OpenSSH host keys set from project (bootstrap/openssh_host_keys)"
} else {
    $existingHostKeys = @(Get-ChildItem -Path (Join-Path $sshDataDir 'ssh_host_*_key') -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '\.pub$' })
    $needKeys = ($existingHostKeys.Count -eq 0)
    if ($needKeys) {
        Write-Set "Generating temporary OpenSSH host keys (required for sshd to start)"
    } else {
        Write-Set "Ensuring all OpenSSH host key types exist (ssh-keygen -A adds only missing keys)"
    }
    $sshKeygen = Get-Command ssh-keygen -ErrorAction SilentlyContinue
    if ($sshKeygen) {
        try {
            Push-Location $sshDataDir
            & $sshKeygen.Source -A 2>&1 | Out-Null
            Pop-Location
            Write-Host ""
            Write-Host "  ****************************************" -ForegroundColor Red
            Write-Host "  ***  TEMPORARY / DEFAULT HOST KEYS  ***" -ForegroundColor Red
            Write-Host "  ****************************************" -ForegroundColor Red
            Write-Host "  These keys are only so sshd can start." -ForegroundColor Yellow
            Write-Host "  To use your own keys: place them in" -ForegroundColor Yellow
            Write-Host "  $ourHostKeysDir" -ForegroundColor Cyan
            Write-Host "  (e.g. ssh_host_ed25519_key, ssh_host_rsa_key + .pub)." -ForegroundColor Yellow
            Write-Host "  Re-run this script; it will replace with yours (idempotent)." -ForegroundColor Yellow
            Write-Host "  ****************************************" -ForegroundColor Red
            Write-Host ""
            if ($needKeys) { Write-Ok "Temporary host keys generated (add keys to bootstrap/openssh_host_keys and re-run)" } else { Write-Ok "Host key set verified/updated" }
        } catch {
            Write-Host "  [WARNING] ssh-keygen -A failed: $_" -ForegroundColor Yellow
            Pop-Location -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "  [WARNING] ssh-keygen not found; run manually from $sshDataDir : ssh-keygen -A" -ForegroundColor Yellow
    }
}

$sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshdService) {
    if ($sshdService.StartType -ne 'Automatic') {
        Set-Service -Name sshd -StartupType Automatic
        Write-Verbose "sshd set to Automatic"
    }
    if ($sshdService.Status -ne 'Running') {
        try {
            Start-Service sshd
            Write-Ok "sshd started"
        } catch {
            Write-Host "  [WARNING] sshd failed to start: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "  Check: port 22 not in use, C:\ProgramData\ssh permissions, Event Viewer (Windows Logs / Application)." -ForegroundColor Yellow
            Write-Host "  Bootstrap will continue (firewall, config, default shell, authorized_keys are still applied)." -ForegroundColor Yellow
        }
    } else {
        Write-Skip "sshd already running"
    }
} else {
    Write-Host "  [WARNING] sshd service not found. OpenSSH Server may not be installed." -ForegroundColor Yellow
}

# Restart sshd so config and default shell take effect (best-effort)
if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    try {
        Restart-Service sshd -Force -ErrorAction Stop
        Write-Verbose "sshd restarted"
    } catch {
        Write-Verbose "sshd restart skipped or failed (non-fatal): $($_.Exception.Message)"
    }
}

# Windows authorized_keys: same pattern as WSL so Mac / Windows / WSL can talk
# 1) Use ansible key from .mgmt/ansible_ssh.pub (written by WSL bootstrap from vault)
# 2) Or optional bootstrap/mac_ssh_key.pub (user-placed Mac key)
$winSshDir = Join-Path $env:USERPROFILE '.ssh'
$winAuthorizedKeys = Join-Path $winSshDir 'authorized_keys'
if (-not (Test-Path $winSshDir)) {
    New-Item -ItemType Directory -Path $winSshDir -Force | Out-Null
    Write-Verbose "Created $winSshDir"
}

$keyAdded = $false
$ansibleKeyPath = Join-Path $repoRoot '.mgmt\ansible_ssh.pub'
$macKeyPath = Join-Path $repoRoot 'bootstrap\mac_ssh_key.pub'

foreach ($keyPath in @($ansibleKeyPath, $macKeyPath)) {
    if (-not (Test-Path $keyPath)) { continue }
    $keyLine = Get-Content $keyPath -Raw -ErrorAction SilentlyContinue | Strip-YamlControlChars
    $keyLine = $keyLine.Trim()
    if (-not $keyLine -or $keyLine -notmatch '^\S+\s+\S+') { continue }
    $existing = if (Test-Path $winAuthorizedKeys) { Get-Content $winAuthorizedKeys -Raw } else { '' }
    if ($existing -notmatch [regex]::Escape($keyLine)) {
        Add-Content -Path $winAuthorizedKeys -Value $keyLine -Encoding UTF8
        $keyName = if ($keyPath -eq $ansibleKeyPath) { 'ansible (from vault)' } else { 'Mac (bootstrap/mac_ssh_key.pub)' }
        Write-Ok "Added $keyName public key to Windows authorized_keys"
        $keyAdded = $true
    }
}
if (-not $keyAdded) {
    Write-Host "  [INFO] No SSH public key found for Windows authorized_keys." -ForegroundColor Yellow
    Write-Host "  To fix (pick one):" -ForegroundColor Cyan
    Write-Host "    1) From Mac: run  ./bin/fz bootstrap --limit server-225-win   (deploys .mgmt/ansible_ssh.pub to this host, then re-run this script)" -ForegroundColor White
    Write-Host "    2) Or: copy your Mac public key into repo as  bootstrap/mac_ssh_key.pub  (e.g.  cat ~/.ssh/id_ed25519.pub > bootstrap/mac_ssh_key.pub  on Mac), sync repo, then re-run this script" -ForegroundColor White
}

Write-Host ""

$nextScriptPath = Join-Path $scriptDir "bootstrap-ansible-local.ps1"
if ($RunAll) {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  >>> CALLING NEXT: bin\bootstrap-ansible-local.ps1 (WSL bootstrap then fz)" -ForegroundColor Cyan
    Write-Host "  TO RUN WITHOUT CHAINING: .\bin\bootstrap-local.ps1 -RunAll:`$false" -ForegroundColor Yellow
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
    & $nextScriptPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "bootstrap-ansible-local.ps1 exited with code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} else {
    Write-Step "Next steps"
    Write-Host "  1. Review generated host_vars files" -ForegroundColor White
    Write-Host "  2. Run bin\bootstrap-ansible-local.ps1 to continue the chain (WSL + fz)" -ForegroundColor White
    Write-Host "  3. Or run bin\bootstrap-local.sh inside WSL with --skip-fz-bootstrap" -ForegroundColor White
}

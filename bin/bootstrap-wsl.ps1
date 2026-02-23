# bin/bootstrap-wsl.ps1
# Run as admin on the target Windows machine.
#
# PURPOSE: Install and configure WSL, generate WSL host_vars and update facts.
#   - Enables the WSL Windows feature if not already installed
#   - Installs Ubuntu distro if no distros are present
#   - Generates WSL host_vars for Ansible
#   - Merges WSL data into the existing facts JSON
#
# Typically called from bootstrap-local.ps1 -ConfigureWSL, but can be run standalone.
#
# .QUICK COMMANDS
#   .\bin\bootstrap-wsl.ps1 -PhysicalNode pn1 -RepoRoot C:\repo -BestIP 10.0.0.5 -AnsibleHost 10.0.0.5
#   Called automatically by: .\bin\bootstrap-local.ps1 -ConfigureWSL

param(
    [Parameter(Mandatory=$true)][string]$PhysicalNode,
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$BestIP,
    [Parameter(Mandatory=$true)][string]$AnsibleHost
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

function Write-Step([string]$Message) { Write-Host "[STEP] $Message" -ForegroundColor Cyan; Write-Verbose "[STEP] $Message" }
function Write-Check([string]$Message) { Write-Host "[CHECK] $Message" -ForegroundColor Yellow; Write-Verbose "[CHECK] $Message" }
function Write-Set([string]$Message) { Write-Host "[SET] $Message" -ForegroundColor Cyan; Write-Verbose "[SET] $Message" }
function Write-Skip([string]$Message) { Write-Host "[SKIP] $Message" -ForegroundColor Yellow; Write-Verbose "[SKIP] $Message" }
function Write-Ok([string]$Message) { Write-Host "[OK] $Message" -ForegroundColor Green; Write-Verbose "[OK] $Message" }
function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor White; Write-Verbose "[INFO] $Message" }

# ============================================================================
# Helper Functions
# ============================================================================

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

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $yamlLines = @("---")

    foreach ($key in $Data.Keys) {
        $value = $Data[$key]

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

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($Path, $yamlLines, $utf8NoBom)
}

# ============================================================================
# WSL Functions
# ============================================================================

function Test-WSLInstalled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        Write-Verbose "WSL feature state: $($wslFeature.State)"
        return ($wslFeature -and $wslFeature.State -eq "Enabled")
    } catch {
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
        wsl.exe --install -d $DistroName 2>&1 | Out-Null
        Start-Sleep -Seconds 3

        $distros = Get-WSLDistros
        if ($distros -contains $DistroName) {
            Write-Host "WSL distro '$DistroName' installed successfully" -ForegroundColor Green
            return $true
        } else {
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
            $lines = if ($wslOutput -is [array]) { $wslOutput } else { $wslOutput -split "`r?`n" }
            $distros = @($lines | ForEach-Object {
                $cleaned = $_ -replace "`0", "" | ForEach-Object { $_.Trim() }
                if ($cleaned -and $cleaned.Length -gt 0 -and $cleaned -match '[a-zA-Z0-9]') {
                    $cleaned
                }
            } | Where-Object { $_ })
            Write-Verbose "Parsed WSL distro list: $($distros -join ', ')"
        }
    } catch {
        Write-Verbose "Get-WSLDistros failed: $_"
    }
    return $distros
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Step "WSL Bootstrap for physical node: $PhysicalNode"
Write-Host ''

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "[ERROR] This script must be run as Administrator." -ErrorAction Continue
    exit 1
}

# Check and install WSL feature
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

# Update facts file with WSL data
$factsPath = Join-Path $RepoRoot "facts\$PhysicalNode.json"
if (Test-Path $factsPath) {
    Write-Set "Updating facts with WSL data: $factsPath"
    try {
        $factsJson = Get-Content $factsPath -Raw | ConvertFrom-Json
        $factsJson | Add-Member -MemberType NoteProperty -Name 'wsl' -Value ([ordered]@{
            distros = $wslDistros
        }) -Force
        $jsonContent = $factsJson | ConvertTo-Json -Depth 10
        $jsonLines = $jsonContent -split "`r?`n"
        [System.IO.File]::WriteAllLines($factsPath, $jsonLines)
        Write-Ok "Facts updated with WSL data"
    } catch {
        Write-Host "WARNING: Could not update facts file: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: Facts file not found at $factsPath - run bootstrap-local.ps1 first" -ForegroundColor Yellow
}

# Generate WSL host_vars
$hostVarsDir = Join-Path $RepoRoot "inventory\host_vars"
$wslVarsPath = Join-Path $hostVarsDir "$PhysicalNode-wsl.yaml"

$existingWslVars = @{}

if (Test-Path $wslVarsPath) {
    Write-Verbose "Existing WSL host_vars found at: $wslVarsPath"
    try {
        $rawWsl = Get-Content $wslVarsPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $rawWsl) { $rawWsl = Get-Content $wslVarsPath -Raw }
        $existingWslContent = Strip-YamlControlChars $rawWsl
        if ($existingWslContent -match 'wsl_user:\s*"?([^"\r\n]+)"?') {
            $existingWslVars.wsl_user = $Matches[1].Trim().Trim('"')
        }
        if ($existingWslContent -match 'wsl_ssh_port:\s*(\d+)') {
            $existingWslVars.wsl_ssh_port = [int]$Matches[1]
        }
        if ($existingWslContent -match 'wsl_distro:\s*"?([^"\r\n]+)"?') {
            $parsedDistro = $Matches[1].Trim().Trim('"')
            if ($parsedDistro -match '[a-zA-Z0-9]') {
                $existingWslVars.wsl_distro = $parsedDistro
            }
        }
    } catch { }
}

$wslVars = [ordered]@{
    physical_node = $PhysicalNode
    surface_type = "wsl"
    host_ip = $BestIP
    wsl_user = if ($existingWslVars.wsl_user) { $existingWslVars.wsl_user } else { "joshc" }
    wsl_ssh_port = if ($existingWslVars.wsl_ssh_port) { $existingWslVars.wsl_ssh_port } else { 22 }
}

if ($wslDistros.Count -gt 0) {
    $firstDistro = if ($wslDistros -is [array]) { $wslDistros[0] } else { $wslDistros }
    $wslVars.wsl_distro = $firstDistro.ToString()
} elseif ($existingWslVars.wsl_distro -and $existingWslVars.wsl_distro -match '[a-zA-Z0-9]{2,}') {
    $wslVars.wsl_distro = $existingWslVars.wsl_distro
} else {
    $wslVars.wsl_distro = ""
}

$wslVars.ansible_connection = "ssh"
$wslVars.ansible_host = $AnsibleHost
$wslVars.ansible_user = $wslVars.wsl_user
$wslVars.ansible_port = $wslVars.wsl_ssh_port
$wslVars.ansible_python_interpreter = "/usr/bin/python3"
$wslVars.ansible_ssh_private_key_file = "~/.ssh/id_ed25519_ansible"

Write-Set "Writing WSL host_vars to: $wslVarsPath"
Write-Yaml -Path $wslVarsPath -Data $wslVars
Write-Verbose "WSL host_vars write complete."

Write-Host ''
Write-Ok "WSL Bootstrap Complete"
Write-Step "Generated files"
Write-Host "  - $wslVarsPath" -ForegroundColor White
if (Test-Path $factsPath) {
    Write-Host "  - $factsPath (updated with WSL data)" -ForegroundColor White
}
Write-Host ''

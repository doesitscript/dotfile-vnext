# bin/desktop/bootstrap-ansible-local.ps1
# DESKTOP ONLY — configures Ubuntu (WSL) and runs bootstrap-local.sh inside it.
# Do not use on Hyper-V server lanes; see docs/reference/connection-surfaces.md.
# Does NOT run playbooks against Windows (<node>-win); run those from the Mac.
# Reads username and password from <node>-wsl and <node>-win host_vars.
#
# Can be called standalone or chained from bootstrap-local.ps1.
# When chained, -PhysicalNode is passed automatically.
# When run standalone, auto-detects from hostname or requires -PhysicalNode.

# ============================================================================
# Configuration Variables (commented out - values are read from host_vars files)
# ============================================================================
# These variables can cause script failure if null/empty or are used to insert
# values into file contents. Uncomment and set these if you want to override
# the values read from host_vars files.
#
# $wslUser = "joshc"                    # WSL username (inserted into cloud-init user-data)
# $wslPassword = "Pass@w0rd1"          # WSL password (inserted into cloud-init user-data)
#
# File paths (determined dynamically from script location + PhysicalNode):
# $repoRoot = "D:\develop\dotfile-vnext"  # Repository root (auto-detected from script location)
# $wslHostVarsPath = "$repoRoot\inventory\host_vars\<node>-wsl.yaml"
# $winHostVarsPath = "$repoRoot\inventory\host_vars\<node>-win.yaml"
# $cloudInitDir = "$env:USERPROFILE\.cloud-init"  # Cloud-init directory (auto-created)
# $userDataFile = "$cloudInitDir\$wslDistro.user-data"  # Cloud-init user-data file
# ============================================================================
#
# .QUICK COMMANDS
#   Run from repo root (after bootstrap-local.ps1): .\bin\bootstrap-ansible-local.ps1
#   Explicit node:  .\bin\bootstrap-ansible-local.ps1 -PhysicalNode hom-lab-ctl-hvh-02
#   Skip fz at the end:  .\bin\bootstrap-ansible-local.ps1 -RunWslBootstrap:$false

param(
    # Physical node name (e.g., hom-lab-ctl-hvh-02, dev-3090, hom-lab-ctl-hvh-01).
    # Auto-detected from hostname if not provided.
    [string]$PhysicalNode = "",
    # If $true (default), unregister the WSL distribution if it already exists (wsl --unregister)
    # then redeploy from cache (wsl --install). Set to $false to keep existing instance and use wsl -d.
    [bool]$UnregisterIfExists = $true,
    # Only this switch runs wsl --install when the distro is already present (unregister then re-download).
    # Without it we never run wsl --install when distro is in wsl --list; after unregister we redeploy from cache.
    [switch]$ForceDownload = $false,
    # If $true (default), run WSL bootstrap (bootstrap-local.sh) inside the distro.
    [bool]$RunWslBootstrap = $true
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
Write-Verbose "Verbose output enabled (VerbosePreference=Continue)"
function Write-Step([string]$Message) { Write-Host "[STEP] $Message" -ForegroundColor Cyan; Write-Verbose "[STEP] $Message" }
function Write-Check([string]$Message) { Write-Host "[CHECK] $Message" -ForegroundColor Yellow; Write-Verbose "[CHECK] $Message" }
function Write-Set([string]$Message) { Write-Host "[SET] $Message" -ForegroundColor Cyan; Write-Verbose "[SET] $Message" }
function Write-Skip([string]$Message) { Write-Host "[SKIP] $Message" -ForegroundColor Yellow; Write-Verbose "[SKIP] $Message" }
function Write-Ok([string]$Message) { Write-Host "[OK] $Message" -ForegroundColor Green; Write-Verbose "[OK] $Message" }

# Get script directory and repo root (same pattern as bootstrap-local.ps1)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
Write-Verbose "scriptDir=$scriptDir"
Write-Verbose "repoRoot=$repoRoot"

# ============================================================================
# Auto-detect physical node if not provided
# ============================================================================
if (-not $PhysicalNode) {
    $detectedHostname = $env:COMPUTERNAME.ToUpper()
    $mappingPath = Join-Path $repoRoot "inventory\hosts_mapping.yaml"
    Write-Verbose "PhysicalNode not provided; auto-detecting from hostname '$detectedHostname'"

    if (Test-Path $mappingPath) {
        $lines = Get-Content $mappingPath
        $currentNode = $null
        foreach ($line in $lines) {
            # Match 2-space indented node name under physical_nodes (e.g., "  hom-lab-ctl-hvh-02:")
            if ($line -match '^\s{2}([a-z0-9_-]+):\s*$') {
                $currentNode = $Matches[1]
            }
            if ($currentNode -and $line -match 'hostname:\s*"?([^"#\s]+)"?') {
                if ($Matches[1].ToUpper() -eq $detectedHostname) {
                    $PhysicalNode = $currentNode
                    break
                }
            }
            if ($currentNode -and $line -match 'os_hostname:\s*"?([^"#\s]+)"?') {
                if ($Matches[1].ToUpper() -eq $detectedHostname) {
                    $PhysicalNode = $currentNode
                    break
                }
            }
        }
    }

    if (-not $PhysicalNode) {
        Write-Error "[ERROR] Could not auto-detect physical node from hostname '$($env:COMPUTERNAME)'." -ErrorAction Continue
        Write-Host "  Pass -PhysicalNode <name> explicitly (e.g., hom-lab-ctl-hvh-02, dev-3090, hom-lab-ctl-hvh-01)" -ForegroundColor Yellow
        Write-Host "  Or ensure this machine's hostname is in inventory/hosts_mapping.yaml" -ForegroundColor Yellow
        exit 1
    }
    Write-Ok "Auto-detected physical node: $PhysicalNode (from hostname $detectedHostname)"
} else {
    Write-Verbose "PhysicalNode provided: $PhysicalNode"
}

# ============================================================================
# File paths from hosts_mapping inventory host aliases (compact schema)
# ============================================================================
$mappingPath = Join-Path $repoRoot "inventory\hosts_mapping.yaml"
$winInventoryHost = $PhysicalNode
$linuxInventoryHost = $null
if (Test-Path $mappingPath) {
    $inNode = $false
    foreach ($line in Get-Content $mappingPath) {
        if ($line -match "^\s{2}$([regex]::Escape($PhysicalNode)):\s*`$") {
            $inNode = $true
            continue
        }
        if ($inNode -and $line -match '^\s{2}[a-z0-9_-]+:\s*$') {
            break
        }
        if ($inNode -and $line -match 'inventory_windows_host:\s*([a-z0-9_-]+)') {
            $winInventoryHost = $Matches[1]
        }
        if ($inNode -and $line -match 'inventory_linux_vm_host:\s*([a-z0-9_-]+)') {
            $linuxInventoryHost = $Matches[1]
        }
    }
}
$winHostVarsPath = Join-Path $repoRoot "inventory\host_vars\$winInventoryHost.yaml"
if ($linuxInventoryHost) {
    $wslHostVarsPath = Join-Path $repoRoot "inventory\host_vars\$linuxInventoryHost.yaml"
} else {
    $wslHostVarsPath = Join-Path $repoRoot "inventory\host_vars\$PhysicalNode-wsl.yaml"
}
Write-Verbose "wslHostVarsPath=$wslHostVarsPath"
Write-Verbose "winHostVarsPath=$winHostVarsPath"

# Default lab password when win_password is missing (no vault). Must match bootstrap-local.ps1.
$DefaultLabPassword = 'Pass@w0rd'

Write-Step "Reading $PhysicalNode WSL configuration"
Write-Host "Repository root: $repoRoot" -ForegroundColor Cyan
Write-Host "Physical node: $PhysicalNode" -ForegroundColor Cyan

# Read WSL username from host_vars (required, no fallback)
$wslUser = $null
if (-not (Test-Path $wslHostVarsPath)) {
    Write-Error "[ERROR] Required file not found: $PhysicalNode-wsl.yaml" -ErrorAction Continue
    Write-Host "  Expected location: $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  This file must contain 'wsl_user:' and 'wsl_distro:' entries" -ForegroundColor Yellow
    Write-Host "  Run bootstrap-local.ps1 first to generate host_vars files" -ForegroundColor Yellow
    exit 1
}

$hostVarsContent = Get-Content $wslHostVarsPath -Raw
if ($hostVarsContent -match 'wsl_user:\s*"?([^"\r\n]+)"?') {
    $wslUser = $Matches[1].Trim().Trim('"')
    Write-Host "  Found WSL user: $wslUser" -ForegroundColor Green
    Write-Host "  Username source: $wslHostVarsPath" -ForegroundColor Yellow
} else {
    Write-Error "[ERROR] Required field 'wsl_user:' not found in file: $PhysicalNode-wsl.yaml" -ErrorAction Continue
    Write-Host "  File location: $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  Please ensure the file contains 'wsl_user: <username>'" -ForegroundColor Yellow
    exit 1
}

# Ensure wsl_user was successfully retrieved - exit if still null
if (-not $wslUser -or $wslUser -eq $null) {
    Write-Error "[ERROR] WSL user is null or empty after reading host_vars file" -ErrorAction Continue
    Write-Host "  File: $PhysicalNode-wsl.yaml at $wslHostVarsPath" -ForegroundColor Red
    exit 1
}

# Read win_password from Windows host_vars; fall back to default lab password (no vault required)
# Note: This script uses win_password from Windows host_vars as the WSL password
$wslPassword = $null
if (-not (Test-Path $winHostVarsPath)) {
    Write-Host "  $PhysicalNode-win.yaml not found; using default lab password." -ForegroundColor Cyan
    $wslPassword = $DefaultLabPassword
} else {
    $winHostVarsContent = Get-Content $winHostVarsPath -Raw
    if ($winHostVarsContent -match 'win_password:\s*"?([^"\r\n]+)"?') {
        $wslPassword = $Matches[1].Trim().Trim('"')
        if ($wslPassword) {
            Write-Host "  Found win_password: ***" -ForegroundColor Green
            Write-Host "  Password source: $winHostVarsPath" -ForegroundColor Yellow
        }
    }
    if (-not $wslPassword) {
        Write-Host "  win_password not in host_vars or empty; using default lab password." -ForegroundColor Cyan
        $wslPassword = $DefaultLabPassword
    }
}

# Ensure we have a password (default is always set)
if (-not $wslPassword) { $wslPassword = $DefaultLabPassword }

Write-Host "  [INFO] This script is not currently compatible with Ansible Vault" -ForegroundColor Green

# Determine WSL distro name from host_vars
$wslDistro = $null
if (Test-Path $wslHostVarsPath) {
    $hostVarsContent = Get-Content $wslHostVarsPath -Raw
    if ($hostVarsContent -match 'wsl_distro:\s*"?([^"\r\n]+)"?') {
        $detectedDistro = $Matches[1].Trim().Trim('"')
        # Map common distro names to WSL distribution names
        if ($detectedDistro -like "*Ubuntu*22*" -or $detectedDistro -eq "Ubuntu-22.04") {
            $wslDistro = "Ubuntu-22.04"
        } elseif ($detectedDistro -like "*Ubuntu*24*" -or $detectedDistro -eq "Ubuntu-24.04") {
            $wslDistro = "Ubuntu-24.04"
        } elseif ($detectedDistro -eq "Ubuntu") {
            $wslDistro = "Ubuntu"
        } else {
            # Accept any distro name from host_vars as-is
            $wslDistro = $detectedDistro
        }
        Write-Host "  Found WSL distro in host_vars: $wslDistro" -ForegroundColor Green

        # Warning: Only Ubuntu-24.04 is advertised as fully automated
        if ($wslDistro -ne "Ubuntu-24.04") {
            Write-Host "  [WARNING] ONLY Ubuntu-24.04 advertised as fully automated user/pass provisioning and auto app trigger" -ForegroundColor Red
        }
    } else {
        Write-Host "  [WARNING] 'wsl_distro:' not found in file: $PhysicalNode-wsl.yaml" -ForegroundColor Yellow
        Write-Host "  File location: $wslHostVarsPath" -ForegroundColor Yellow
    }
}

if (-not $wslDistro) {
    Write-Error "[ERROR] No WSL distro found in host_vars for $PhysicalNode" -ErrorAction Continue
    Write-Host "  File: $PhysicalNode-wsl.yaml at $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  Ensure the file contains 'wsl_distro: Ubuntu-24.04' (or your target distro)" -ForegroundColor Yellow
    exit 1
}

# Critical warning: Only Ubuntu-24.04 is fully supported
if ($wslDistro -ne "Ubuntu-24.04") {
    Write-Host "  [WARNING] ONLY Ubuntu-24.04 advertised as fully automated user/pass provisioning and auto app trigger" -ForegroundColor Red
}

# Create cloud-init directory
# This file lives on the bootstrapping host and will automate creating the username and password
# on our test Ubuntu WSL distribution
Write-Host ""
Write-Step "Automating username and password creation"
Write-Host "  This cloud-init user-data file lives on the bootstrapping host" -ForegroundColor Cyan
Write-Host "  It will automate creating the username '$wslUser' and password on test Ubuntu WSL" -ForegroundColor Cyan

$cloudInitDir = "$env:USERPROFILE\.cloud-init"
if (-not (Test-Path $cloudInitDir)) {
    New-Item -ItemType Directory -Path $cloudInitDir -Force | Out-Null
    Write-Host "  Created cloud-init directory: $cloudInitDir" -ForegroundColor Green
    Write-Verbose "Created cloud-init directory at $cloudInitDir"
} else {
    Write-Verbose "cloud-init directory already exists: $cloudInitDir"
}

# Generate cloud-init user-data
# Note: passwd in cloud-init needs to be a hashed password. For simplicity, we'll use plain text
# but cloud-init will hash it automatically if it's not already hashed
Write-Host "  The name of this file name has to match the name of the distro instance that will be created in the next step." -ForegroundColor Yellow
$userData = @"
#cloud-config
users:
  - name: $wslUser
    groups: [sudo, adm]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $wslPassword
    
write_files:
- path: /etc/wsl.conf
  append: true
  content: |
    [boot]
    systemd=true
    [user]
    default=$wslUser
"@

# These are optional and can be added later if needed
# packages: [ginac-tools, octave]

# runcmd:
#    - sudo git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg
#    - sudo apt-get install zip curl -y

$userDataFile = Join-Path $cloudInitDir "$wslDistro.user-data"
# Idempotent: overwrite existing file if it exists
if (Test-Path $userDataFile) {
    Write-Host "  [INFO] Overwriting existing cloud-init user-data file: $userDataFile" -ForegroundColor Yellow
    Write-Verbose "user-data file exists and will be overwritten: $userDataFile"
}
# This specific encoding flag is the key to removing the 'invisible' header errors
$userDataLines = $userData -split "`r?`n"
[System.IO.File]::WriteAllLines($userDataFile, $userDataLines)
Write-Host "  Created/updated cloud-init user-data file: $userDataFile" -ForegroundColor Green

Write-Host ""
Write-Step "WSL distribution: $wslDistro"

# Ensure this run ends with a deployed distro:
# - present + UnregisterIfExists $false => keep existing (no wsl --install)
# - present + UnregisterIfExists $true  => unregister then redeploy in same run
# - not present                         => deploy now (wsl --install)
# - ForceDownload                       => force unregister + redeploy (fresh download path)
$installedDistros = wsl --list --quiet 2>$null
$distroInList = ($installedDistros -contains $wslDistro)
Write-Verbose "Initial distro list contains '$wslDistro': $distroInList"

if ($distroInList) {
    Write-Host "  Distribution $wslDistro is already present (wsl --list)" -ForegroundColor Green
    if ($ForceDownload) {
        Write-Host "  ForceDownload is true: unregistering $wslDistro then running wsl --install (re-download)..." -ForegroundColor Cyan
        wsl --terminate $wslDistro 2>$null
        wsl --unregister $wslDistro
        if ($LASTEXITCODE -ne 0) {
            Write-Error "[ERROR] Failed to unregister WSL distribution: $wslDistro" -ErrorAction Continue
            exit 1
        }
        Write-Host "  [OK] Unregistered." -ForegroundColor Green
        $installedDistros = wsl --list --quiet 2>$null
        $distroInList = $false
        Write-Verbose "ForceDownload path: distro unregistered; will run wsl --install"
    } elseif ($UnregisterIfExists) {
        Write-Host "  UnregisterIfExists is true (without ForceDownload): distro already downloaded, skipping wsl --install and download." -ForegroundColor Cyan
        Write-Host "  [SKIP DOWNLOAD] Keeping existing distro and continuing bootstrap via wsl -d." -ForegroundColor Green
        Write-Verbose "UnregisterIfExists=true and ForceDownload=false: keeping existing distro and skipping wsl --install"
        wsl --terminate $wslDistro 2>$null
    } else {
        Write-Host "  UnregisterIfExists is false: using existing distro (wsl -d for bootstrap; no wsl --install, no download)" -ForegroundColor Cyan
        wsl --terminate $wslDistro 2>$null
    }
}

# Run wsl --install when distro is not present (first deploy or post-unregister), or when ForceDownload is set.
$runWslInstall = (-not $distroInList) -or $ForceDownload
Write-Verbose "runWslInstall=$runWslInstall (distroInList=$distroInList, ForceDownload=$ForceDownload)"
if ($runWslInstall) {
    Write-Set "Running wsl --install $wslDistro --no-launch"
    Write-Verbose "Executing: wsl --install $wslDistro --no-launch"
    wsl --install $wslDistro  --no-launch
    # This instance will then be configured automatically by cloud-init. The process can take several minutes
    # https://documentation.ubuntu.com/wsl/stable/howto/cloud-init/

    if ($LASTEXITCODE -ne 0) {
        Write-Error "[ERROR] wsl --install failed for distribution: $wslDistro" -ErrorAction Continue
        exit 1
    }
    Write-Ok "wsl --install completed successfully"
} else {
    Write-Skip "Distribution already present; using wsl -d $wslDistro for bootstrap (no wsl --install)"
    Write-Verbose "wsl --install skipped because distro already present and no force flag"
}

Write-Host ""
Write-Step "Launching WSL (cloud-init will configure user automatically)"
Write-Host "  User: $wslUser" -ForegroundColor Cyan
Write-Host "  Passwordless sudo: Configured" -ForegroundColor Cyan
Write-Host "  Distribution: $wslDistro" -ForegroundColor Cyan
Write-Host "  Boot: wsl -d $wslDistro" -ForegroundColor Cyan

# First launch so cloud-init runs and writes /etc/wsl.conf; then shutdown so wsl.conf takes effect
Write-Set "First launch to apply wsl.conf (cloud-init)"
wsl -d $wslDistro -e true 2>$null
Start-Sleep -Seconds 8
Write-Host "  Close the WSL distribution terminal if you have one open." -ForegroundColor Yellow
Write-Host "  Shutting down all WSL distributions so wsl.conf takes effect..." -ForegroundColor Cyan
wsl --shutdown
Start-Sleep -Seconds 2
Write-Ok "WSL shutdown complete; proceeding with bootstrap"

Write-Host ""
Write-Step "Running Ansible Local Bootstrap (destructive idempotent process)"
Write-Host "  [WARNING] This is a destructive idempotent process for provisioning Ansible in WSL" -ForegroundColor Red
Write-Host "  It will configure SSH server, passwordless sudo, and other Ansible requirements" -ForegroundColor Yellow
Write-Host "  Running: ./bin/bootstrap-local.sh --physical-node $PhysicalNode inside WSL distribution: $wslDistro" -ForegroundColor Cyan

# Get the repo path in WSL format (convert Windows path to WSL path)
# Convert D:\develop\dotfile-vnext to /mnt/d/develop/dotfile-vnext
if ($repoRoot -match '^([A-Za-z]):') {
    $driveLetter = $Matches[1].ToLower()
    $wslRepoPath = $repoRoot -replace '^[A-Za-z]:', "/mnt/$driveLetter" -replace '\\', '/'
} else {
    # If no drive letter, assume it's already a WSL path or use as-is
    $wslRepoPath = $repoRoot -replace '\\', '/'
}

# Run bootstrap-local.sh inside WSL
# IMPORTANT: We must specify the distribution by name (--distribution / -d) so we target
# the target distro (e.g. Ubuntu-24.04), NOT the default (e.g. Ubuntu).
# See: wsl --help -> "Run a specific distribution: wsl -d <DistroName>"
$wslDistroForBootstrap = $wslDistro
Write-Host "  Targeting WSL distribution by name: $wslDistroForBootstrap (not the default)" -ForegroundColor Cyan
Write-Verbose "WSL bootstrap command target distro: $wslDistroForBootstrap"

$bootstrapScriptPath = "$wslRepoPath/bin/bootstrap-local.sh"
# Pass --skip-fz-bootstrap and --physical-node so the script knows which node and does not run fz
$wslCommand = "cd '$wslRepoPath' && bash '$bootstrapScriptPath' --skip-fz-bootstrap --physical-node '$PhysicalNode'"

$wslBootstrapSucceeded = $false
if (-not $RunWslBootstrap) {
    Write-Skip "Skipping WSL bootstrap (RunWslBootstrap=false)."
    $wslBootstrapSucceeded = $true
} else {
$prevErrorAction = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $result = wsl --distribution $wslDistroForBootstrap bash -c $wslCommand 2>&1
    $exitCode = $LASTEXITCODE
    $resultText = if ($result -is [array]) { $result -join "`n" } else { $result.ToString() }

    if ($exitCode -eq 0) {
        Write-Host "  [OK] Ansible local bootstrap completed successfully" -ForegroundColor Green
        $wslBootstrapSucceeded = $true
    } else {
        Write-Host "[ERROR] Ansible local bootstrap failed with exit code: $exitCode" -ForegroundColor Red
        Write-Host "  Output: $resultText" -ForegroundColor Yellow

        if ($resultText -match 'cannot determine non-root WSL user') {
            Write-Host "" -ForegroundColor Red
            Write-Host "  *** THIS SCRIPT MUST BE RUN AS ADMINISTRATOR ***" -ForegroundColor Red
            Write-Host "  Right-click PowerShell and choose 'Run as administrator', then run this script again." -ForegroundColor Yellow
            Write-Host "" -ForegroundColor Red
        }
        Write-Host "  You may need to run './bin/bootstrap-local.sh --physical-node $PhysicalNode' manually inside WSL" -ForegroundColor Yellow
    }
} catch {
    $errMsg = $_.ToString()
    Write-Host "[ERROR] Failed to run bootstrap-local.sh: $errMsg" -ForegroundColor Red
    if ($errMsg -match 'cannot determine non-root WSL user|sudoers') {
        Write-Host "" -ForegroundColor Red
        Write-Host "  *** THIS SCRIPT MUST BE RUN AS ADMINISTRATOR ***" -ForegroundColor Red
        Write-Host "  Right-click PowerShell and choose 'Run as administrator', then run this script again." -ForegroundColor Yellow
        Write-Host "" -ForegroundColor Red
    }
    Write-Host "  You may need to run './bin/bootstrap-local.sh --physical-node $PhysicalNode' manually inside WSL" -ForegroundColor Yellow
} finally {
    $ErrorActionPreference = $prevErrorAction
}
}

Write-Host ""
Write-Ok "WSL setup complete"
Write-Host "  Physical node: $PhysicalNode" -ForegroundColor Cyan
Write-Host "  WSL distribution: $wslDistro" -ForegroundColor Cyan
Write-Host "  WSL user: $wslUser" -ForegroundColor Cyan
Write-Host "  To access WSL manually: wsl -d $wslDistro" -ForegroundColor Cyan
Write-Host ""
Write-Host "  To run Windows bootstrap (WinRM) from the Mac: ./bin/fz bootstrap --limit $PhysicalNode-win" -ForegroundColor Yellow
Write-Host "  This script only configures the Ubuntu distro; it does not target Windows." -ForegroundColor Yellow

if (-not $wslBootstrapSucceeded) {
    exit 1
}

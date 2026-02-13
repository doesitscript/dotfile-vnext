# bin/bootstrap-ansible-local.ps1
# Automated WSL deploy with cloud-init for server-225
# This script automates deploying the ansible container and uses the WSL username and password
# as the assumed ansible user and password.
# Reads username and password from server-225-wsl and server-225-win host_vars files

# ============================================================================
# Configuration Variables (commented out - values are read from host_vars files)
# ============================================================================
# These variables can cause script failure if null/empty or are used to insert
# values into file contents. Uncomment and set these if you want to override
# the values read from host_vars files.
#
# $wslUser = "josh"                    # WSL username (inserted into cloud-init user-data)
# $wslPassword = "Pass@w0rd1"          # WSL password (inserted into cloud-init user-data)
# $wslDistroOverride = "Ubuntu-24.04" # WSL distribution name (used in file paths and commands)
#                                      # Set to $null to use value from host_vars instead
#
# File paths (determined dynamically from script location):
# $repoRoot = "D:\develop\dotfile-vnext"  # Repository root (auto-detected from script location)
# $wslHostVarsPath = "$repoRoot\inventory\host_vars\server-225-wsl.yaml"
# $winHostVarsPath = "$repoRoot\inventory\host_vars\server-225-win.yaml"
# $cloudInitDir = "$env:USERPROFILE\.cloud-init"  # Cloud-init directory (auto-created)
# $userDataFile = "$cloudInitDir\$wslDistro.user-data"  # Cloud-init user-data file
# ============================================================================
#
# .QUICK COMMANDS
#   Run from repo root (after bootstrap-local.ps1): .\bin\bootstrap-ansible-local.ps1
#   Skip fz at the end:  .\bin\bootstrap-ansible-local.ps1 -RunFzBootstrap:$false

param(
    # If $true (default), unregister the WSL distribution if it already exists (wsl --unregister)
    # then redeploy from cache (wsl --install). Set to $false to keep existing instance and use wsl -d.
    [bool]$UnregisterIfExists = $true,
    # Only this switch runs wsl --install when the distro is already present (unregister then re-download).
    # Without it we never run wsl --install when distro is in wsl --list; after unregister we redeploy from cache.
    [switch]$ForceDownload = $false,
    # If $true (default), run WSL bootstrap (bootstrap-local.sh). Set $false to skip and only run fz.
    [bool]$RunWslBootstrap = $true,
    # If $true (default), after WSL bootstrap run: ./bin/fz bootstrap --limit server-225-win
    [bool]$RunFzBootstrap = $true
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

# File paths used by this script:
# - inventory\host_vars\server-225-wsl.yaml (required) - WSL host vars containing wsl_user and wsl_distro
# - inventory\host_vars\server-225-win.yaml (required) - Windows host vars containing win_password
# - $env:USERPROFILE\.cloud-init\$wslDistro.user-data (created) - Cloud-init user data file

$wslHostVarsPath = Join-Path $repoRoot "inventory\host_vars\server-225-wsl.yaml"
$winHostVarsPath = Join-Path $repoRoot "inventory\host_vars\server-225-win.yaml"
Write-Verbose "wslHostVarsPath=$wslHostVarsPath"
Write-Verbose "winHostVarsPath=$winHostVarsPath"

Write-Step "Reading server-225 WSL configuration"
Write-Host "Repository root: $repoRoot" -ForegroundColor Cyan

# Read WSL username from host_vars (required, no fallback)
$wslUser = $null
if (-not (Test-Path $wslHostVarsPath)) {
    Write-Error "[ERROR] Required file not found: server-225-wsl.yaml" -ErrorAction Continue
    Write-Host "  Expected location: $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  This file must contain 'wsl_user:' and 'wsl_distro:' entries" -ForegroundColor Yellow
    exit 1
}

$hostVarsContent = Get-Content $wslHostVarsPath -Raw
if ($hostVarsContent -match 'wsl_user:\s*"?([^"\r\n]+)"?') {
    $wslUser = $Matches[1].Trim().Trim('"')
    Write-Host "  Found WSL user: $wslUser" -ForegroundColor Green
    Write-Host "  Username source: $wslHostVarsPath" -ForegroundColor Yellow
} else {
    Write-Error "[ERROR] Required field 'wsl_user:' not found in file: server-225-wsl.yaml" -ErrorAction Continue
    Write-Host "  File location: $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  Please ensure the file contains 'wsl_user: <username>'" -ForegroundColor Yellow
    exit 1
}

# Ensure wsl_user was successfully retrieved - exit if still null
if (-not $wslUser -or $wslUser -eq $null) {
    Write-Error "[ERROR] WSL user is null or empty after reading host_vars file" -ErrorAction Continue
    Write-Host "  File: server-225-wsl.yaml at $wslHostVarsPath" -ForegroundColor Red
    exit 1
}

# Read win_password from Windows host_vars (required, no fallback)
# Note: This script uses win_password from Windows host_vars as the WSL password
$wslPassword = $null
if (-not (Test-Path $winHostVarsPath)) {
    Write-Error "[ERROR] Required file not found: server-225-win.yaml" -ErrorAction Continue
    Write-Host "  Expected location: $winHostVarsPath" -ForegroundColor Red
    Write-Host "  This file must contain 'win_password:' entry (used as WSL password)" -ForegroundColor Yellow
    exit 1
}

$winHostVarsContent = Get-Content $winHostVarsPath -Raw
if ($winHostVarsContent -match 'win_password:\s*"?([^"\r\n]+)"?') {
    $wslPassword = $Matches[1].Trim().Trim('"')
    Write-Host "  Found win_password: ***" -ForegroundColor Green
    Write-Host "  Password source: $winHostVarsPath" -ForegroundColor Yellow
} else {
    Write-Error "[ERROR] Required field 'win_password:' not found in file: server-225-win.yaml" -ErrorAction Continue
    Write-Host "  File location: $winHostVarsPath" -ForegroundColor Red
    Write-Host "  Please ensure the file contains 'win_password: <password>'" -ForegroundColor Yellow
    Write-Host "  Note: This password will be used as the WSL user password" -ForegroundColor Yellow
    exit 1
}

# Ensure win_password was successfully retrieved - exit if still null
if (-not $wslPassword -or $wslPassword -eq $null) {
    Write-Error "[ERROR] win_password is null or empty after reading host_vars file" -ErrorAction Continue
    Write-Host "  File: server-225-win.yaml at $winHostVarsPath" -ForegroundColor Red
    exit 1
}

Write-Host "  [INFO] This script is not currently compatible with Ansible Vault" -ForegroundColor Green

# Determine WSL distro name from host_vars (with override support for testing)
$wslDistroFromHostVars = $null
# Re-read host_vars content (already loaded above, but keeping for clarity)
if (Test-Path $wslHostVarsPath) {
    $hostVarsContent = Get-Content $wslHostVarsPath -Raw
    if ($hostVarsContent -match 'wsl_distro:\s*"?([^"\r\n]+)"?') {
        $detectedDistro = $Matches[1].Trim().Trim('"')
        # Map common distro names to WSL distribution names
        if ($detectedDistro -like "*Ubuntu*22*" -or $detectedDistro -eq "Ubuntu-22.04") {
            $wslDistroFromHostVars = "Ubuntu-22.04"
        } elseif ($detectedDistro -like "*Ubuntu*24*" -or $detectedDistro -eq "Ubuntu-24.04") {
            $wslDistroFromHostVars = "Ubuntu-24.04"
        } elseif ($detectedDistro -eq "Ubuntu") {
            $wslDistroFromHostVars = "Ubuntu"
        }
        Write-Host "  Found WSL distro in host_vars: $wslDistroFromHostVars" -ForegroundColor Green
        
        # Warning: Only Ubuntu-24.04 is advertised as fully automated
        if ($wslDistroFromHostVars -ne "Ubuntu-24.04") {
            Write-Host "  [WARNING] ONLY Ubuntu-24.04 advertised as fully automated user/pass provisioning and auto app trigger" -ForegroundColor Red
        }
    } else {
        Write-Host "  [WARNING] 'wsl_distro:' not found in file: server-225-wsl.yaml" -ForegroundColor Yellow
        Write-Host "  File location: $wslHostVarsPath" -ForegroundColor Yellow
    }
}

# Override value for testing (set this variable to override host_vars value)
# Set $wslDistroOverride to a value (e.g., "Ubuntu-24.04") to use it instead of host_vars value
$wslDistroOverride = "Ubuntu-24.04"  # Override value for testing - set to $null to use host_vars instead

# Use override if set, otherwise use value from host_vars
if ($wslDistroOverride -and $wslDistroOverride -ne $null) {
    $wslDistro = $wslDistroOverride
    Write-Host "  [OVERRIDE] Using test override value: $wslDistro" -ForegroundColor Yellow
    if ($wslDistroFromHostVars) {
        Write-Host "    (Overriding value from host_vars: $wslDistroFromHostVars)" -ForegroundColor Yellow
    }
} elseif ($wslDistroFromHostVars) {
    $wslDistro = $wslDistroFromHostVars
    Write-Verbose "Using wsl_distro from host_vars: $wslDistro"
} else {
    Write-Error "[ERROR] No WSL distro found in host_vars and no override set" -ErrorAction Continue
    Write-Host "  File: server-225-wsl.yaml at $wslHostVarsPath" -ForegroundColor Red
    Write-Host "  Either add 'wsl_distro: Ubuntu-24.04' to the file, or set `$wslDistroOverride variable" -ForegroundColor Yellow
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
    ystemd=true
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
Write-Host "  Running: ./bin/bootstrap-local.sh inside WSL distribution: $wslDistro" -ForegroundColor Cyan

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
# Pass --skip-fz-bootstrap so the script does not run fz; we run fz from here after success.
$wslCommand = "cd '$wslRepoPath' && bash '$bootstrapScriptPath' --skip-fz-bootstrap"

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
        Write-Host "  You may need to run './bin/bootstrap-local.sh' manually inside WSL" -ForegroundColor Yellow
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
    Write-Host "  You may need to run './bin/bootstrap-local.sh' manually inside WSL" -ForegroundColor Yellow
} finally {
    $ErrorActionPreference = $prevErrorAction
}
}

Write-Host ""
Write-Ok "WSL setup complete"
Write-Host "  WSL distribution: $wslDistro" -ForegroundColor Cyan
Write-Host "  WSL user: $wslUser" -ForegroundColor Cyan
Write-Host "  To access WSL manually: wsl -d $wslDistro" -ForegroundColor Cyan

# Add ansible public key to Windows authorized_keys (created by WSL playbook at repo\.mgmt\ansible_ssh.pub)
$ansiblePubKeyPath = Join-Path $repoRoot ".mgmt\ansible_ssh.pub"
$winSshDir = Join-Path $env:USERPROFILE ".ssh"
$winAuthorizedKeys = Join-Path $winSshDir "authorized_keys"
if ($wslBootstrapSucceeded -and (Test-Path $ansiblePubKeyPath)) {
    if (-not (Test-Path $winSshDir)) { New-Item -ItemType Directory -Path $winSshDir -Force | Out-Null }
    $keyLine = (Get-Content $ansiblePubKeyPath -Raw -ErrorAction SilentlyContinue) -replace "[\x00-\x08\x0b\x0c\x0e-\x1f]", ""
    $keyLine = $keyLine.Trim()
    if ($keyLine -and $keyLine -match '^\S+\s+\S+') {
        $existing = if (Test-Path $winAuthorizedKeys) { Get-Content $winAuthorizedKeys -Raw } else { '' }
        if ($existing -notmatch [regex]::Escape($keyLine)) {
            Add-Content -Path $winAuthorizedKeys -Value $keyLine -Encoding UTF8
            Write-Ok "Added ansible public key to Windows authorized_keys (Mac can SSH to this host with id_ed25519_ansible)"
        }
    }
}

if ($RunFzBootstrap -and $wslBootstrapSucceeded) {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  >>> CALLING: ./bin/fz bootstrap --limit server-225-win (inside WSL)" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
    $fzCommand = "cd '$wslRepoPath' && ./bin/fz bootstrap --limit server-225-win"
    wsl --distribution $wslDistroForBootstrap bash -c $fzCommand
    if ($LASTEXITCODE -ne 0) {
        Write-Host "fz bootstrap exited with code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} elseif (-not $wslBootstrapSucceeded) {
    Write-Host "Skipping fz bootstrap because WSL bootstrap failed." -ForegroundColor Yellow
    exit 1
}
# wsl_auto.ps1
# Automated WSL installation with cloud-init for server-225
# Reads username and password from server-225-wsl host_vars and vault

$ErrorActionPreference = "Stop"

# Get repository root (assuming script is run from repo root or adjust path)
# $repoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$repoRoot = "D:\develop\dotfile-vnext"
$wslHostVarsPath = Join-Path $repoRoot "inventory\host_vars\server-225-wsl.yaml"
$vaultPath = Join-Path $repoRoot "vault\shared.vault.yml" # not use, but keep for reference

Write-Host "=== Reading server-225 WSL configuration ===" -ForegroundColor Cyan

# Read WSL username from host_vars (required, no fallback)
$wslUser = $null
if (-not (Test-Path $wslHostVarsPath)) {
    Write-Host "  [ERROR] WSL host_vars file not found at: $wslHostVarsPath" -ForegroundColor Red
    exit 1
}

$hostVarsContent = Get-Content $wslHostVarsPath -Raw
if ($hostVarsContent -match 'wsl_user:\s*"?([^"\r\n]+)"?') {
    $wslUser = $Matches[1].Trim().Trim('"')
    Write-Host "  Found WSL user: $wslUser" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Could not find wsl_user in host_vars file: $wslHostVarsPath" -ForegroundColor Red
    exit 1
}

# Ensure wsl_user was successfully retrieved - exit if still null
if (-not $wslUser -or $wslUser -eq $null) {
    Write-Host "  [ERROR] WSL user is null or empty after reading host_vars file" -ForegroundColor Red
    exit 1
}

# Read win_password from Windows host_vars (required, no fallback)
$wslPassword = $null
$winHostVarsPath = Join-Path $repoRoot "inventory\host_vars\server-225-win.yaml"
if (-not (Test-Path $winHostVarsPath)) {
    Write-Host "  [ERROR] Windows host_vars file not found at: $winHostVarsPath" -ForegroundColor Red
    exit 1
}

$winHostVarsContent = Get-Content $winHostVarsPath -Raw
if ($winHostVarsContent -match 'win_password:\s*"?([^"\r\n]+)"?') {
    $wslPassword = $Matches[1].Trim().Trim('"')
    Write-Host "  Found win_password: ***" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Could not find win_password in host_vars file: $winHostVarsPath" -ForegroundColor Red
    exit 1
}

# Ensure win_password was successfully retrieved - exit if still null
if (-not $wslPassword -or $wslPassword -eq $null) {
    Write-Host "  [ERROR] win_password is null or empty after reading host_vars file" -ForegroundColor Red
    exit 1
}

# Determine WSL distro name from host_vars (with override support for testing)
$wslDistroFromHostVars = $null
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
    }
}

# Override value for testing (set this variable to override host_vars value)
# Set $wslDistroOverride to a value (e.g., "Ubuntu-24.04") to use it instead of host_vars value
$wslDistroOverride = "Ubuntu-24.04"  # Override value for testing - set to $null to use host_vars instead

Write-Host "  [WARNING] Passwordless cloud-init container setup only works with Ubuntu-24.04" -ForegroundColor Yellow
Write-Host "    (and maybe previous versions), but officially with this version (Ubuntu-24.04)" -ForegroundColor Yellow

# Use override if set, otherwise use value from host_vars
if ($wslDistroOverride -and $wslDistroOverride -ne $null) {
    $wslDistro = $wslDistroOverride
    Write-Host "  [OVERRIDE] Using test override value: $wslDistro" -ForegroundColor Yellow
    if ($wslDistroFromHostVars) {
        Write-Host "    (Overriding value from host_vars: $wslDistroFromHostVars)" -ForegroundColor Yellow
    }
} elseif ($wslDistroFromHostVars) {
    $wslDistro = $wslDistroFromHostVars
} else {
    Write-Host "  [ERROR] No WSL distro found in host_vars and no override set" -ForegroundColor Red
    exit 1
}

# Create cloud-init directory
# This file lives on the bootstrapping host and will automate creating the username and password
# on our test Ubuntu WSL distribution
Write-Host ""
Write-Host "=== Automating username and password creation ===" -ForegroundColor Cyan
Write-Host "  This cloud-init user-data file lives on the bootstrapping host" -ForegroundColor Cyan
Write-Host "  It will automate creating the username '$wslUser' and password on test Ubuntu WSL" -ForegroundColor Cyan

$cloudInitDir = "$env:USERPROFILE\.cloud-init"
if (-not (Test-Path $cloudInitDir)) {
    New-Item -ItemType Directory -Path $cloudInitDir -Force | Out-Null
    Write-Host "  Created cloud-init directory: $cloudInitDir" -ForegroundColor Green
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
}
$userData | Out-File -FilePath $userDataFile -Encoding UTF8 -NoNewline
Write-Host "  Created/updated cloud-init user-data file: $userDataFile" -ForegroundColor Green

Write-Host ""
Write-Host "=== Installing WSL distribution: $wslDistro ===" -ForegroundColor Cyan

# Check if distro is already installed
$installedDistros = wsl --list --quiet 2>$null
if ($installedDistros -contains $wslDistro) {
    Write-Host "  [WARNING] Distribution $wslDistro is already installed" -ForegroundColor Yellow
    Write-Host "  [TEST SCRIPT] This is a test script - terminating existing Ubuntu to test user/password automation" -ForegroundColor Yellow
    # BUG: Testing automated container deploy without prompt - interactive prompt is commented out
    # This automatically terminates existing distributions without user confirmation, which could
    # cause data loss in production. Should restore interactive prompt for production use.
    # Commented out interactive prompt - using automated termination for testing
    # $continue = Read-Host "  Continue anyway? (y/N)"
    # if ($continue -ne "y" -and $continue -ne "Y") {
    #     Write-Host "  Installation cancelled." -ForegroundColor Yellow
    #     exit 0
    # }
    Write-Host "  Terminating existing distribution (for retesting cloud-init): $wslDistro" -ForegroundColor Yellow
    wsl --terminate $wslDistro
} else {
    # Install the distribution without launching (allows cloud-init to run)
    Write-Host "  Installing $wslDistro with --no-launch flag..." -ForegroundColor Cyan
    wsl --install $wslDistro
    . This instance will then be configured automatically by cloud-init. The process can take several minutes
    #https://documentation.ubuntu.com/wsl/stable/howto/cloud-init/
    # wsl --install -d $wslDistro --no-launch

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] Failed to install WSL distribution" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  [OK] Distribution installed successfully" -ForegroundColor Green

Write-Host ""
Write-Host "=== Launching WSL (cloud-init will configure user automatically) ===" -ForegroundColor Cyan
Write-Host "  User: $wslUser" -ForegroundColor Cyan
Write-Host "  Passwordless sudo: Configured" -ForegroundColor Cyan
Write-Host "  Distribution: $wslDistro" -ForegroundColor Cyan
Write-Host ""

# Launch WSL - cloud-init will detect the .user-data file and configure the user
# wsl -d $wslDistro

Write-Host ""
Write-Host "=== WSL setup complete ===" -ForegroundColor Green
Write-Host "  You can now run: ./bin/bootstrap-local.sh inside WSL" -ForegroundColor Cyan
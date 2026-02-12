# repair-wsl.ps1
# Run as Administrator. Repairs WSL/VirtualMachinePlatform + component store, then reinstalls WSL.

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Write-Info($msg) {
    Write-Host "    $msg" -ForegroundColor Gray
}

function Write-Ok($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "! $msg" -ForegroundColor Yellow
}

function Write-ErrMsg($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

# Basic sanity
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-ErrMsg "Run this script as Administrator."
    exit 1
}

Write-Step "Stopping WSL (if present) and cleaning VHDX artifacts"

# Best-effort shutdown; ignore failures
try {
    wsl --shutdown 2>$null
} catch { }

# LxssManager may not exist; ignore failure
try {
    Stop-Service LxssManager -ErrorAction SilentlyContinue
} catch { }

# Clean WSL data under current profile (adjust if you use a different account)
$wslRoot = Join-Path $env:LOCALAPPDATA "wsl"
if (Test-Path $wslRoot) {
    Write-Info "Removing VHDX files under $wslRoot"
    Get-ChildItem $wslRoot -Recurse -Include *.vhdx -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
} else {
    Write-Info "No WSL data directory found at $wslRoot"
}
Write-Ok "WSL data cleanup step complete"

Write-Step "Disabling WSL-related features (WSL + VirtualMachinePlatform)"

$featuresToDisable = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

foreach ($f in $featuresToDisable) {
    Write-Info "Disabling feature: $f"
    try {
        dism /online /disable-feature /featurename:$f /norestart | Out-Null
    } catch {
        Write-Warn "Failed to disable $f (may already be disabled). Continuing."
    }
}
Write-Warn "A reboot is recommended after disabling features, but continuing to repair component store."

Write-Step "Repairing component store with DISM /restorehealth"

try {
    dism /online /cleanup-image /restorehealth
    Write-Ok "DISM /restorehealth completed"
} catch {
    Write-ErrMsg "DISM /restorehealth failed: $($_.Exception.Message)"
    Write-Warn "You may need to inspect C:\Windows\Logs\DISM\dism.log"
}

Write-Step "Running SFC /scannow"

try {
    sfc /scannow
    Write-Ok "SFC /scannow completed"
} catch {
    Write-ErrMsg "SFC failed: $($_.Exception.Message)"
}

Write-Warn "At this point, a reboot is strongly recommended before re-enabling WSL features."
Write-Host ""
$resp = Read-Host "Reboot now? (Y/N)"
if ($resp -match '^[Yy]') {
    Write-Info "Rebooting system..."
    Restart-Computer
    exit 0
}

Write-Step "Re-enabling WSL features (WSL + VirtualMachinePlatform)"

$featuresToEnable = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

foreach ($f in $featuresToEnable) {
    Write-Info "Enabling feature: $f"
    dism /online /enable-feature /featurename:$f /all /norestart | Out-Null
}

Write-Warn "You MUST reboot before WSL will function correctly."
$resp2 = Read-Host "Reboot now to complete feature enablement? (Y/N)"
if ($resp2 -match '^[Yy]') {
    Write-Info "Rebooting system..."
    Restart-Computer
    exit 0
}

Write-Step "Post-reboot actions (run these manually after reboot)"

# $postRebootMsg = @"
# After reboot, run the following in an elevated PowerShell:

#     # Verify LxssManager exists
#     sc query LxssManager

#     # Install Ubuntu (or your distro of choice)
#     wsl --install -d Ubuntu

# When sc query LxssManager shows the service and wsl --install completes,
# your WSL stack is repaired.
# "@
# Write-Host $postRebootMsg
# from me
wsl --uninstall

Get-Service LxssManager
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all # should give LxssManager Appear

wsl.exe --install -d Ubuntu
# C:\Users\Administrator\AppData\Local\wsl\Ubuntu\ext4.vhdx

wsl.exe --list --online            
The following is a list of valid distributions that can be installed.
Install using 'wsl.exe --install <Distro>'.

NAME                            FRIENDLY NAME
Ubuntu                          Ubuntu
Ubuntu-24.04                    Ubuntu 24.04 LTS
openSUSE-Tumbleweed             openSUSE Tumbleweed
openSUSE-Leap-16.0              openSUSE Leap 16.0
SUSE-Linux-Enterprise-15-SP7    SUSE Linux Enterprise 15 SP7
SUSE-Linux-Enterprise-16.0      SUSE Linux Enterprise 16.0
kali-linux                      Kali Linux Rolling
Debian                          Debian GNU/Linux
AlmaLinux-8                     AlmaLinux OS 8
AlmaLinux-9                     AlmaLinux OS 9
AlmaLinux-Kitten-10             AlmaLinux OS Kitten 10
AlmaLinux-10                    AlmaLinux OS 10
archlinux                       Arch Linux
FedoraLinux-43                  Fedora Linux 43
FedoraLinux-42                  Fedora Linux 42
eLxr                            eLxr 12.12.0.0 GNU/Linux
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_10                Oracle Linux 8.10
OracleLinux_9_5                 Oracle Linux 9.5
openSUSE-Leap-15.6              openSUSE Leap 15.6
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6

wsl --install -d Ubuntu-22.04
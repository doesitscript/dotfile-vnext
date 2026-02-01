# bin/optional-bootstrap-local-wsl-check.ps1
# Run as admin on the target Windows machine
# This script checks if Ubuntu is set as the default WSL distro, and installs it if not present

$ErrorActionPreference = "Stop"

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Check if WSL distro is installed
Write-Host "Checking for WSL distribution..." -ForegroundColor Cyan
try {
    $wslListOutput = wsl.exe -l -v 2>&1
    $hasWslDistro = $false
    $defaultDistro = $null
    
    if ($LASTEXITCODE -eq 0 -and $wslListOutput) {
        $installedDistros = $wslListOutput | Where-Object { $_ -and $_.Trim().Length -gt 0 -and $_ -notmatch "NAME" -and $_ -notmatch "---" }
        $hasWslDistro = $installedDistros.Count -gt 0
        
        if ($hasWslDistro) {
            # Find the default distro (marked with *)
            foreach ($line in $installedDistros) {
                if ($line -match "^\*\s+(\S+)") {
                    $defaultDistro = $matches[1]
                    break
                } elseif ($installedDistros.Count -eq 1) {
                    # If only one distro, it's the default
                    $defaultDistro = ($line -split '\s+')[0]
                    break
                }
            }
            
            if ($defaultDistro -match "Ubuntu" -or $defaultDistro -match "ubuntu") {
                Write-Host "Ubuntu is set as default WSL distribution: $defaultDistro" -ForegroundColor Green
                exit 0
            } else {
                Write-Host "WSL distribution found but Ubuntu is not default. Default: $defaultDistro" -ForegroundColor Yellow
                Write-Host "To set Ubuntu as default, run: wsl --set-default Ubuntu" -ForegroundColor Yellow
                exit 0
            }
        }
    }
    
    # No WSL distro found, install Ubuntu
    if (-not $hasWslDistro) {
        Write-Host "No WSL distribution found. Installing Ubuntu..." -ForegroundColor Yellow
        $installOutput = wsl.exe --install -d Ubuntu 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Ubuntu installation initiated successfully." -ForegroundColor Green
            Write-Host "WSL distro setup complete. The installation may continue in the background." -ForegroundColor Green
            exit 0
        } else {
            $installOutputString = $installOutput | Out-String
            Write-Host "Failed to install Ubuntu. Exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "If the install process hangs, try: wsl --install --web-download -d Ubuntu" -ForegroundColor Yellow
            Write-Host "Output: $installOutputString" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "Error checking/installing WSL: $_" -ForegroundColor Red
    exit 1
}

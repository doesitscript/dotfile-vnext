# bin/bootstrap-local-post-install-check-step.ps1
# Run as admin on the target Windows machine
# This script checks if WSL distro is installed, and installs Ubuntu if not

$ErrorActionPreference = "Stop"

# Check prerequisites
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Check if WSL distro is installed, install Ubuntu if not
Write-Host "Checking for WSL distribution..." -ForegroundColor Cyan
try {
    $wslListOutput = wsl.exe -l -q 2>&1
    $hasWslDistro = $false
    if ($LASTEXITCODE -eq 0 -and $wslListOutput) {
        $installedDistros = $wslListOutput | Where-Object { $_ -and $_.Trim().Length -gt 0 }
        $hasWslDistro = $installedDistros.Count -gt 0
        if ($hasWslDistro) {
            Write-Host "WSL distribution found: $($installedDistros -join ', ')" -ForegroundColor Green
            Write-Host "WSL distro setup complete. Skipping installation." -ForegroundColor Green
            exit 0
        }
    }
    
    if (-not $hasWslDistro) {
        Write-Host "No WSL distribution found. Checking available distributions..." -ForegroundColor Yellow
        $onlineListOutput = wsl.exe --list --online 2>&1
        if ($LASTEXITCODE -eq 0 -and $onlineListOutput) {
            # Try installing "Ubuntu" directly (it's the default distro name)
            # If that fails, we'll try parsing the list
            Write-Host "Attempting to install Ubuntu..." -ForegroundColor Yellow
            $installOutput = wsl.exe --install -d Ubuntu 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Ubuntu installation initiated successfully." -ForegroundColor Green
                Write-Host "WSL distro setup complete. The installation may continue in the background." -ForegroundColor Green
                exit 0
            } else {
                # Installation failed, try to find Ubuntu in the list and use exact name
                $installOutputString = $installOutput | Out-String
                Write-Host "Default 'Ubuntu' install failed, checking available distributions..." -ForegroundColor Yellow
                
                # Parse output to find Ubuntu distro name
                # Convert output to a single string and search for Ubuntu
                $outputText = if ($onlineListOutput -is [array]) { 
                    ($onlineListOutput | ForEach-Object { $_.ToString() }) -join "`n"
                } else { 
                    $onlineListOutput.ToString() 
                }
                
                # Try to find Ubuntu using IndexOf (more reliable than regex with encoding issues)
                $ubuntuDistroName = $null
                if ($outputText.IndexOf("Ubuntu") -ge 0 -or $outputText.IndexOf("ubuntu") -ge 0) {
                    # Found Ubuntu in output, try common distro names
                    $possibleNames = @("Ubuntu", "Ubuntu-24.04", "Ubuntu-22.04", "Ubuntu-20.04")
                    foreach ($name in $possibleNames) {
                        if ($outputText.IndexOf($name) -ge 0) {
                            $ubuntuDistroName = $name
                            break
                        }
                    }
                    # If no exact match, try to extract from the line
                    if (-not $ubuntuDistroName) {
                        $outputLines = $outputText -split "`n"
                        foreach ($line in $outputLines) {
                            if ($line.IndexOf("Ubuntu") -ge 0) {
                                # Extract first word that contains Ubuntu
                                $words = $line -split '\s+'
                                foreach ($word in $words) {
                                    if ($word.IndexOf("Ubuntu") -ge 0 -and $word.Length -gt 0) {
                                        $ubuntuDistroName = $word
                                        break
                                    }
                                }
                                if ($ubuntuDistroName) { break }
                            }
                        }
                    }
                }
                
                if ($ubuntuDistroName) {
                    Write-Host "Found Ubuntu distribution: $ubuntuDistroName. Installing..." -ForegroundColor Yellow
                    $installOutput2 = wsl.exe --install -d $ubuntuDistroName 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Ubuntu installation initiated successfully." -ForegroundColor Green
                        Write-Host "WSL distro setup complete. The installation may continue in the background." -ForegroundColor Green
                        exit 0
                    } else {
                        Write-Host "Failed to install $ubuntuDistroName. Exit code: $LASTEXITCODE" -ForegroundColor Red
                        Write-Host "Output: $($installOutput2 | Out-String)" -ForegroundColor Red
                        exit 1
                    }
                } else {
                    Write-Host "Ubuntu not found in available distributions." -ForegroundColor Red
                    Write-Host "Available distributions:" -ForegroundColor Yellow
                    Write-Host $onlineListOutput -ForegroundColor Yellow
                    exit 1
                }
            }
        } else {
            Write-Host "Failed to list online distributions. Exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "Output: $onlineListOutput" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "Error checking/installing WSL: $_" -ForegroundColor Red
    exit 1
}

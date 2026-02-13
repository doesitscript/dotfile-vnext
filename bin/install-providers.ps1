# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Add Chocolatey to PATH for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Install git using Chocolatey (idempotent - won't reinstall if already installed)
choco install -y git

# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
# variable and importing the Chocolatey profile module.
# Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed to.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# refreshenv is now an alias for Update-SessionEnvironment
# (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
# This should make git.exe accessible via the refreshed $env:PATH, so that it
# can be called by name only.
refreshenv

# Verify that git can be called.
git --version

# Configure Git credential manager if not already configured
$currentHelper = git config --global credential.helper 2>$null
if ($null -eq $currentHelper -or $currentHelper -notlike "*manager*") {
    Write-Host "Configuring Git credential manager..."
    git config --global credential.helper manager
} else {
    Write-Host "Git credential manager already configured."
}

# Configure Git user email and name globally
# This makes Git config available immediately in the current terminal session
$gitEmail = "1589359+doesitscript@users.noreply.github.com"
$gitName = "Joshua Castillo"

Write-Host ""
Write-Host "=== Configuring Git User Identity ===" -ForegroundColor Cyan

# Get current config (use full path to git.exe to ensure it works)
$gitExe = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitExe) {
    Write-Host "ERROR: Git command not found after installation" -ForegroundColor Red
    exit 1
}

$currentEmail = & $gitExe.Source config --global user.email 2>$null
$currentName = & $gitExe.Source config --global user.name 2>$null

# Set email (always set to ensure it's correct)
Write-Host "Setting Git email: $gitEmail"
& $gitExe.Source config --global user.email $gitEmail
$verifyEmail = & $gitExe.Source config --global user.email 2>$null
if ($verifyEmail -eq $gitEmail) {
    Write-Host "  [OK] Git email configured: $verifyEmail" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Failed to set Git email" -ForegroundColor Red
}

# Set name (only if not set, or if different)
if ([string]::IsNullOrEmpty($currentName) -or $currentName -ne $gitName) {
    Write-Host "Setting Git user name: $gitName"
    & $gitExe.Source config --global user.name $gitName
} else {
    Write-Host "Git user name already set: $currentName"
}
$verifyName = & $gitExe.Source config --global user.name 2>$null
if ($verifyName) {
    Write-Host "  [OK] Git user name configured: $verifyName" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Failed to set Git user name" -ForegroundColor Red
}

# Verify configuration is available in current session
Write-Host ""
Write-Host "=== Verifying Git Configuration ===" -ForegroundColor Cyan
$finalEmail = git config --global user.email 2>$null
$finalName = git config --global user.name 2>$null

if ($finalEmail -eq $gitEmail -and $finalName) {
    Write-Host "[OK] Git is configured and ready to use in this terminal session" -ForegroundColor Green
    Write-Host "  Email: $finalEmail" -ForegroundColor Cyan
    Write-Host "  Name:  $finalName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now use Git commands like:" -ForegroundColor Yellow
    Write-Host '  git commit -m "Your message"' -ForegroundColor White
    Write-Host "  git push" -ForegroundColor White
    Write-Host "  git pull" -ForegroundColor White
} else {
    Write-Host "[WARNING] Git configuration verification failed" -ForegroundColor Red
    Write-Host "  Email: $finalEmail" -ForegroundColor Yellow
    Write-Host "  Name:  $finalName" -ForegroundColor Yellow
}
Write-Host ""

# Check if API token/credentials are set up
$repoUrl = "https://github.com/doesitscript/dotfile-vnext.git"
Write-Host "Checking if GitHub credentials are configured..."

# First, check if we can access the remote (this is the most reliable check)
# If we can access it, credentials are working and we don't need to prompt
$credCheck = git ls-remote $repoUrl 2>&1
$canAccess = $LASTEXITCODE -eq 0

if ($canAccess) {
    Write-Host "GitHub credentials are working. No sign-in needed."
} else {
    Write-Host "GitHub credentials not configured or expired. Triggering credential prompt..."
    Write-Host "You will be prompted for your GitHub username and personal access token."
    # This forces Git to ask for username/token interactively (browser or prompt)
    Write-Host "Please enter your GitHub credentials when prompted..."
    git ls-remote $repoUrl
    # Verify credentials are now set
    $credCheck = git ls-remote $repoUrl 2>&1
    $credentialsSet = $LASTEXITCODE -eq 0
    if ($credentialsSet) {
        Write-Host "Credentials configured successfully."
    } else {
        Write-Host "Warning: Failed to configure credentials. Continuing anyway..."
    }
}

# Check if we're already in the dotfile-vnext directory or if it exists
$repoName = "dotfile-vnext"
$currentDir = Get-Location
$currentDirName = Split-Path -Leaf $currentDir

# Check if we're already in a dotfile-vnext git repository (check current dir and parent dirs)
$isInRepo = $false
$repoRootPath = $null

# First check current directory
if (Test-Path ".git") {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl -like "*dotfile-vnext*") {
        $isInRepo = $true
        $repoRootPath = $currentDir
    }
}

# If not in repo, check parent directories
if (-not $isInRepo) {
    $checkDir = $currentDir
    $maxDepth = 10
    $depth = 0
    while ($depth -lt $maxDepth -and $checkDir) {
        $gitPath = Join-Path $checkDir ".git"
        if (Test-Path $gitPath) {
            Push-Location $checkDir
            $remoteUrl = git remote get-url origin 2>$null
            Pop-Location
            if ($remoteUrl -like "*dotfile-vnext*") {
                $isInRepo = $true
                $repoRootPath = $checkDir
                break
            }
        }
        $parentDir = Split-Path -Parent $checkDir
        if ($parentDir -eq $checkDir) {
            # Reached root
            break
        }
        $checkDir = $parentDir
        $depth++
    }
}

# Only check for repo as subdirectory if we're not already in it
$repoPath = $null
$repoExists = $false
if (-not $isInRepo) {
    # Only check for repo as subdirectory if current dir name is not the repo name
    if ($currentDirName -ne $repoName) {
        $repoPath = Join-Path $currentDir $repoName
        if (Test-Path $repoPath) {
            $gitPath = Join-Path $repoPath ".git"
            if (Test-Path $gitPath) {
                # Verify it's actually a git repo by checking the remote
                Push-Location $repoPath
                $remoteUrl = git remote get-url origin 2>$null
                Pop-Location
                if ($remoteUrl -like "*dotfile-vnext*") {
                    $repoExists = $true
                } else {
                    Write-Host "Warning: Directory $repoPath exists but is not the correct git repository."
                    Write-Host "Skipping removal (directory may be in use). Please remove manually if needed."
                }
            } else {
                Write-Host "Warning: Directory $repoPath exists but is not a git repository."
                Write-Host "Skipping removal (directory may be in use). Please remove manually if needed."
            }
        }
    }
}

if ($isInRepo) {
    Write-Host "Already inside dotfile-vnext repository (found at: $repoRootPath)"
    if ($currentDir -ne $repoRootPath) {
        Write-Host "Changing to repository root directory..."
        Set-Location $repoRootPath
    }
    Write-Host "Pulling latest changes..."
    git pull
} elseif ($repoExists) {
    Write-Host "Repository already cloned at $repoPath"
    Set-Location $repoPath
    Write-Host "Changed to repository directory."
    Write-Host "Pulling latest changes..."
    git pull
} else {
    # Determine where to clone - never clone inside the repo if we're already in it
    $cloneDir = $currentDir
    
    # If current directory name is the repo name but it's not a git repo, clone to parent
    if ($currentDirName -eq $repoName -and -not (Test-Path ".git")) {
        Write-Host "Current directory is named '$repoName' but is not a git repository."
        Write-Host "Cloning to parent directory..."
        $cloneDir = Split-Path -Parent $currentDir
        Set-Location $cloneDir
    }
    
    # Make sure we're not trying to clone inside an existing repo
    $checkDir = $cloneDir
    $maxDepth = 10
    $depth = 0
    $wouldCloneInsideRepo = $false
    while ($depth -lt $maxDepth -and $checkDir) {
        $gitPath = Join-Path $checkDir ".git"
        if (Test-Path $gitPath) {
            Push-Location $checkDir
            $remoteUrl = git remote get-url origin 2>$null
            Pop-Location
            if ($remoteUrl -like "*dotfile-vnext*") {
                $wouldCloneInsideRepo = $true
                Write-Host "Warning: Would clone inside existing repository. Cloning to parent directory instead..."
                $cloneDir = Split-Path -Parent $checkDir
                Set-Location $cloneDir
                break
            }
        }
        $parentDir = Split-Path -Parent $checkDir
        if ($parentDir -eq $checkDir) {
            break
        }
        $checkDir = $parentDir
        $depth++
    }
    
    Write-Host "Cloning repository to: $cloneDir"
    git clone $repoUrl
    $repoPath = Join-Path $cloneDir $repoName
    if (Test-Path $repoPath) {
        Set-Location $repoPath
        Write-Host "Changed to repository directory."
    }
}

# --- Python + Windows Ansible venv (.venv-win) for fz role-local ---
$RepoRoot = Get-Location
$VenvWin = Join-Path $RepoRoot ".venv-win"
$VenvWinPlaybook = Join-Path $VenvWin "Scripts\ansible-playbook.exe"
$RequirementsTxt = Join-Path $RepoRoot "scripts\requirements.txt"

if (Test-Path $VenvWinPlaybook) {
    Write-Host ""
    Write-Host "[OK] Windows Ansible venv already present at .venv-win" -ForegroundColor Green
} elseif (Test-Path $RequirementsTxt) {
    Write-Host ""
    Write-Host "=== Ensuring Python and Windows Ansible venv (.venv-win) ===" -ForegroundColor Cyan

    $PythonExe = $null
    try {
        $null = & py -3 -c "import sys; sys.exit(0)" 2>$null
        if ($LASTEXITCODE -eq 0) { $PythonExe = 'py' }
    } catch {}
    if (-not $PythonExe) {
        try {
            $null = & python -c "import sys; sys.exit(0)" 2>$null
            if ($LASTEXITCODE -eq 0) { $PythonExe = 'python' }
        } catch {}
    }
    # If not found, install Python via winget (hands-free) then refresh PATH and retry
    if (-not $PythonExe) {
        Write-Host "Python not found in PATH. Installing via winget (Python.Python.3.12)..."
        $wingetOk = $false
        try {
            winget install --id Python.Python.3.12 --source winget --silent --accept-package-agreements --accept-source-agreements
            $wingetOk = $LASTEXITCODE -eq 0
        } catch {
            Write-Warning "winget install failed: $_"
        }
        if ($wingetOk) {
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Start-Sleep -Seconds 2
            try {
                $null = & py -3 -c "import sys; sys.exit(0)" 2>$null
                if ($LASTEXITCODE -eq 0) { $PythonExe = 'py' }
            } catch {}
            try {
                $null = & python -c "import sys; sys.exit(0)" 2>$null
                if ($LASTEXITCODE -eq 0) { $PythonExe = 'python' }
            } catch {}
        }
    }
    if (-not $PythonExe) {
        Write-Warning "Python could not be detected or installed. Skip creating .venv-win. Install from https://www.python.org/downloads/ or run: winget install Python.Python.3.12"
    } else {
        Write-Host "Creating .venv-win and installing Ansible dependencies..."
        Push-Location $RepoRoot
        try {
            if ($PythonExe -eq 'py') { & py -3 -m venv $VenvWin } else { & python -m venv $VenvWin }
            if (-not (Test-Path (Join-Path $VenvWin "Scripts\pip.exe"))) {
                Write-Warning "venv creation failed; .venv-win\Scripts\pip.exe not found."
            } else {
                & (Join-Path $VenvWin "Scripts\pip.exe") install --quiet -r $RequirementsTxt
                if (Test-Path $VenvWinPlaybook) {
                    Write-Host "[OK] Windows Ansible venv ready at .venv-win (use: .\bin\fz role-local git)" -ForegroundColor Green
                } else {
                    Write-Warning "pip install completed but ansible-playbook.exe not found in .venv-win."
                }
            }
        } finally {
            Pop-Location
        }
    }
} else {
    Write-Host "scripts\requirements.txt not found; skipping Python/.venv-win setup."
}

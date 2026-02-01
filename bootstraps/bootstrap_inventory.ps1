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

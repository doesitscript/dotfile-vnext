# Run a single Ansible role on Windows localhost (no WSL).
# Usage: .\bin\fz-role-local.ps1 <role> [ansible-playbook args...]
# Example: .\bin\fz-role-local.ps1 git
#          .\bin\fz-role-local.ps1 git --check --diff
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$RoleName,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$DotfilesHome = $RepoRoot
$DotfilesUserHome = $env:USERPROFILE

# Prefer Windows-native venv (.venv-win) so we don't rely on WSL-created .venv
$VenvWin = Join-Path $RepoRoot ".venv-win"
$VenvWinPlaybook = Join-Path $VenvWin "Scripts\ansible-playbook.exe"
$VenvPlaybook = Join-Path $RepoRoot ".venv\Scripts\ansible-playbook.exe"

if (Test-Path $VenvWinPlaybook) {
    $VenvPlaybook = $VenvWinPlaybook
} elseif (Test-Path $VenvPlaybook) {
    # Use existing .venv if it has Windows ansible-playbook
} else {
    # Create .venv-win and install deps (repo .venv is usually WSL/Linux)
    $RequirementsTxt = Join-Path $RepoRoot "scripts\requirements.txt"
    if (-not (Test-Path $RequirementsTxt)) {
        Write-Error "ansible-playbook not found. No Windows venv at $VenvWinPlaybook or $VenvPlaybook, and scripts\requirements.txt not found to create one."
        exit 1
    }
    # Prefer 'py -3' (Python launcher) then 'python' on Windows
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
    if (-not $PythonExe) {
        Write-Host "Python is required to create the Windows venv (.venv-win)." -ForegroundColor Red
        Write-Host "Install Python from https://www.python.org/downloads/ or the Microsoft Store, ensure it is in PATH, then re-run." -ForegroundColor Yellow
        Write-Host "From PowerShell you can use: winget install Python.Python.3.12" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Creating Windows venv at .venv-win and installing dependencies..."
    Push-Location $RepoRoot
    try {
        if ($PythonExe -eq 'py') { & py -3 -m venv $VenvWin } else { & python -m venv $VenvWin }
        if (-not (Test-Path (Join-Path $VenvWin "Scripts\pip.exe"))) {
            Write-Host "Python is required to create the Windows venv (.venv-win)." -ForegroundColor Red
            Write-Host "Install Python from https://www.python.org/downloads/ or run: winget install Python.Python.3.12" -ForegroundColor Yellow
            exit 1
        }
        & (Join-Path $VenvWin "Scripts\pip.exe") install --quiet -r $RequirementsTxt
    } finally {
        Pop-Location
    }
    if (-not (Test-Path $VenvWinPlaybook)) {
        Write-Error "Failed to create ansible-playbook at $VenvWinPlaybook after installing from scripts\requirements.txt"
        exit 1
    }
    $VenvPlaybook = $VenvWinPlaybook
    Write-Host "Windows venv ready. Running role..."
}

# So Ansible finds roles and config when the temp playbook is in %TEMP%
$env:ANSIBLE_ROLES_PATH = Join-Path $RepoRoot "roles"
$env:ANSIBLE_CONFIG = Join-Path $RepoRoot "ansible.cfg"

$TempPlaybook = [System.IO.Path]::GetTempFileName() + ".yml"
$PlaybookContent = @"
- hosts: localhost
  connection: local
  gather_facts: true
  roles:
    - role: $RoleName
"@
Set-Content -Path $TempPlaybook -Value $PlaybookContent -Encoding UTF8

# On Windows, ansible-playbook.exe can raise OSError in check_blocking_io (os.get_blocking).
# Use the Python wrapper so the check is patched before Ansible loads.
$VenvPython = Join-Path (Split-Path $VenvPlaybook -Parent) "python.exe"
$WinWrapper = Join-Path $PSScriptRoot "run-ansible-playbook-win.py"
$UseWrapper = ($env:OS -eq "Windows_NT") -and (Test-Path $WinWrapper) -and (Test-Path $VenvPython)

try {
    Push-Location $RepoRoot
    # Ansible requires UTF-8 locale on Windows (CP1252 fails); Python 3.7+ respects PYTHONUTF8=1
    if ($env:OS -eq "Windows_NT") { $env:PYTHONUTF8 = "1" }
    $AllArgs = @(
        "-i", "localhost,"
        "-c", "local"
        $TempPlaybook
        "-e", "dotfiles_home=$DotfilesHome"
        "-e", "dotfiles_user_home=$DotfilesUserHome"
    )
    if ($ExtraArgs) { $AllArgs += $ExtraArgs }
    if ($UseWrapper) {
        & $VenvPython $WinWrapper @AllArgs
    } else {
        & $VenvPlaybook @AllArgs
    }
    exit $LASTEXITCODE
} finally {
    Pop-Location
    Remove-Item -Path $TempPlaybook -Force -ErrorAction SilentlyContinue
}

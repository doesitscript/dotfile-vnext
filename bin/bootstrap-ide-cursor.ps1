Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
Write-Verbose "Verbose output enabled (VerbosePreference=Continue)"

function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[STEP] $Message"
    Write-Verbose "[STEP-DETAIL] $Message"
}

function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[INFO] $Message"
    Write-Verbose "[INFO-DETAIL] $Message"
}
function Write-Check { param([string]$Message) Write-Host "[CHECK] $Message"; Write-Verbose "[CHECK-DETAIL] $Message" }
function Write-Set { param([string]$Message) Write-Host "[SET] $Message"; Write-Verbose "[SET-DETAIL] $Message" }
function Write-Skip { param([string]$Message) Write-Host "[SKIP] $Message"; Write-Verbose "[SKIP-DETAIL] $Message" }
function Write-Ok { param([string]$Message) Write-Host "[OK] $Message"; Write-Verbose "[OK-DETAIL] $Message" }

function Set-JsonSetting {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Value
    )

    $valueJson = $Value | ConvertTo-Json -Compress
    $existing = $Object.PSObject.Properties[$Name]
    if ($null -eq $existing) {
        Write-Info "Adding missing setting '$Name' with value: $valueJson"
        $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        return $true
    }

    $previousJson = $existing.Value | ConvertTo-Json -Compress
    Write-Info "Current value for '$Name': $previousJson"
    if ($previousJson -eq $valueJson) {
        Write-Info "No change needed for '$Name'."
        return $false
    }

    Write-Info "Updating '$Name' to: $valueJson"
    $Object.$Name = $Value
    return $true
}

Write-Step "Resolving Cursor settings path"
$settingsPath = Join-Path $env:APPDATA "Cursor\User\settings.json"
$settingsDir = Split-Path -Parent $settingsPath
Write-Info "settingsPath = $settingsPath"
Write-Info "settingsDir  = $settingsDir"

Write-Step "Ensuring settings directory exists"
if (-not (Test-Path -LiteralPath $settingsDir)) {
    Write-Set "Directory missing, creating: $settingsDir"
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}
else {
    Write-Skip "Directory already exists."
}

Write-Step "Loading existing settings JSON"
if (Test-Path -LiteralPath $settingsPath) {
    Write-Info "Found settings file."
    $raw = Get-Content -LiteralPath $settingsPath -Raw
    Write-Info "settings.json size (chars): $($raw.Length)"
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Write-Info "settings.json is empty. Starting from an empty object."
        $settings = [pscustomobject]@{}
    }
    else {
        Write-Info "Parsing settings.json"
        $settings = $raw | ConvertFrom-Json
    }
}
else {
    Write-Info "settings.json does not exist. Starting from an empty object."
    $settings = [pscustomobject]@{}
}

Write-Step "Applying required terminal settings"
$changed = $false
if (Set-JsonSetting -Object $settings -Name "terminal.integrated.defaultProfile.windows" -Value "PowerShell") {
    $changed = $true
}
if (Set-JsonSetting -Object $settings -Name "terminal.integrated.enablePersistentSessions" -Value $false) {
    $changed = $true
}
if (Set-JsonSetting -Object $settings -Name "terminal.integrated.inheritEnv" -Value $true) {
    $changed = $true
}

Write-Step "Writing settings back to disk"
$settings | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settingsPath -Encoding utf8
if ($changed) {
    Write-Ok "settings.json updated."
}
else {
    Write-Skip "No effective setting changes were required."
}

Write-Step "Verifying elevation state"
$elevationCommand = "([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
Write-Info "Elevation command: $elevationCommand"
$isElevated = Invoke-Expression $elevationCommand

Write-Ok "Updated Cursor settings at: $settingsPath"
Write-Check "Elevation check: $isElevated"

if (-not $isElevated) {
    Write-Warning "Current shell is not elevated. Run Cursor as Administrator to ensure elevated integrated terminals."
}

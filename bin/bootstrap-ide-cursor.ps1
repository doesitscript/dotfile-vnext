Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
Write-Verbose "Verbose output enabled (VerbosePreference=Continue)"

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
        Write-Host "[SET] Adding missing setting '$Name' with value: $valueJson"
        $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        return $true
    }

    $previousJson = $existing.Value | ConvertTo-Json -Compress
    Write-Host "[CHECK] Current value for '$Name': $previousJson"
    if ($previousJson -eq $valueJson) {
        Write-Host "[SKIP] No change needed for '$Name'."
        return $false
    }

    Write-Host "[SET] Updating '$Name' to: $valueJson"
    $Object.$Name = $Value
    return $true
}

Write-Host "[STEP] Resolving Cursor settings path"
$settingsPath = Join-Path $env:APPDATA "Cursor\User\settings.json"
$settingsDir = Split-Path -Parent $settingsPath
Write-Host "[INFO] settingsPath = $settingsPath"
Write-Host "[INFO] settingsDir  = $settingsDir"

Write-Host "[STEP] Ensuring settings directory exists"
if (-not (Test-Path -LiteralPath $settingsDir)) {
    Write-Host "[SET] Directory missing, creating: $settingsDir"
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}
else {
    Write-Host "[SKIP] Directory already exists."
}

Write-Host "[STEP] Loading existing settings JSON"
if (Test-Path -LiteralPath $settingsPath) {
    Write-Host "[INFO] Found settings file."
    $raw = Get-Content -LiteralPath $settingsPath -Raw
    Write-Host "[INFO] settings.json size (chars): $($raw.Length)"
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Write-Host "[INFO] settings.json is empty. Starting from an empty object."
        $settings = [pscustomobject]@{}
    }
    else {
        Write-Host "[INFO] Parsing settings.json"
        $settings = $raw | ConvertFrom-Json
    }
}
else {
    Write-Host "[INFO] settings.json does not exist. Starting from an empty object."
    $settings = [pscustomobject]@{}
}

Write-Host "[STEP] Applying required terminal settings"
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

Write-Host "[STEP] Writing settings back to disk"
$settings | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settingsPath -Encoding utf8
if ($changed) {
    Write-Host "[OK] settings.json updated."
}
else {
    Write-Host "[SKIP] No effective setting changes were required."
}

Write-Host "[STEP] Verifying elevation state"
$elevationCommand = "([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
Write-Host "[CHECK] Elevation command: $elevationCommand"
$isElevated = Invoke-Expression $elevationCommand

Write-Host "[OK] Updated Cursor settings at: $settingsPath"
Write-Host "[CHECK] Elevation check: $isElevated"

if (-not $isElevated) {
    Write-Warning "Current shell is not elevated. Run Cursor as Administrator to ensure elevated integrated terminals."
}

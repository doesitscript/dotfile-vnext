#Requires -Version 5.1
<#
.SYNOPSIS
  Merge declared Steam library folder paths into libraryfolders.vdf without
  wiping existing apps/contentid blocks. Does not create directories.
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$SteamInstallPath,

  [Parameter(Mandatory = $true)]
  [string[]]$LibraryRoots,

  [switch]$WhatIfCompareOnly
)

$ErrorActionPreference = 'Stop'

function Normalize-SteamPath([string]$Path) {
  # Steam VDF stores Windows paths with escaped backslashes (D:\\SteamLibrary).
  $bs = [string][char]92
  $p = $Path.Trim().TrimEnd($bs[0])
  $p = $p.Replace($bs + $bs, $bs)
  $p = $p.Replace([char]47, $bs[0])  # /
  return $p.ToLowerInvariant().TrimEnd($bs[0])
}

function Get-LibraryPathsFromVdf([string]$Text) {
  $paths = New-Object System.Collections.Generic.List[string]
  $rx = [regex]'\"path\"\s+\"([^\"]+)\"'
  foreach ($m in $rx.Matches($Text)) {
    $paths.Add($m.Groups[1].Value)
  }
  return $paths
}

function Get-NextLibraryIndex([string]$Text) {
  $max = -1
  $rx = [regex]'(?m)^\t\"(\d+)\"\s*$'
  foreach ($m in $rx.Matches($Text)) {
    $n = [int]$m.Groups[1].Value
    if ($n -gt $max) { $max = $n }
  }
  return $max + 1
}

$vdfPath = Join-Path $SteamInstallPath 'config\libraryfolders.vdf'
$result = [ordered]@{
  vdf_path = $vdfPath
  vdf_exists = (Test-Path -LiteralPath $vdfPath)
  desired = @($LibraryRoots)
  existing = @()
  missing = @()
  changed = $false
  action = 'none'
}

if (-not $result.vdf_exists) {
  if ($WhatIfCompareOnly) {
    $result.missing = @($LibraryRoots)
    $result.action = 'missing_vdf'
    $Ansible.Result = $result
    return
  }
  $configDir = Split-Path -Parent $vdfPath
  if (-not (Test-Path -LiteralPath $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
  }
  $body = "`"libraryfolders`"`n{`n}`n"
  [System.IO.File]::WriteAllText($vdfPath, $body)
  $result.vdf_exists = $true
  $result.action = 'created_empty_vdf'
}

$text = Get-Content -LiteralPath $vdfPath -Raw
$existing = @(Get-LibraryPathsFromVdf $text)
$result.existing = $existing

$existingNorm = @{}
foreach ($p in $existing) {
  $existingNorm[(Normalize-SteamPath $p)] = $p
}

$missing = New-Object System.Collections.Generic.List[string]
foreach ($root in $LibraryRoots) {
  if ([string]::IsNullOrWhiteSpace($root)) { continue }
  $key = Normalize-SteamPath $root
  if (-not $existingNorm.ContainsKey($key)) {
    $missing.Add($root.Trim().TrimEnd('\'))
  }
}
$result.missing = @($missing)

if ($WhatIfCompareOnly) {
  $result.changed = ($missing.Count -gt 0)
  $result.action = if ($result.changed) { 'would_merge' } else { 'match' }
  $Ansible.Changed = $false
  $Ansible.Result = $result
  return
}

if ($missing.Count -eq 0) {
  $result.action = 'match'
  $Ansible.Changed = $false
  $Ansible.Result = $result
  return
}

# Insert new folder entries before the closing brace of libraryfolders.
$trimmed = $text.TrimEnd()
if (-not $trimmed.EndsWith('}')) {
  throw "Unexpected libraryfolders.vdf shape (no trailing closing brace): $vdfPath"
}
$insertAt = $trimmed.LastIndexOf('}')
$prefix = $trimmed.Substring(0, $insertAt)
$suffix = $trimmed.Substring($insertAt)
$next = Get-NextLibraryIndex $trimmed
$blocks = New-Object System.Collections.Generic.List[string]
foreach ($root in $missing) {
  $escaped = $root -replace '\\', '\\'
  $block = @(
    "`t`"$next`""
    "`t{"
    "`t`t`"path`"`t`t`"$escaped`""
    "`t`t`"label`"`t`t`"`""
    "`t`t`"contentid`"`t`t`"0`""
    "`t`t`"totalsize`"`t`t`"0`""
    "`t`t`"update_clean_bytes_tally`"`t`t`"0`""
    "`t`t`"time_last_update_verified`"`t`t`"0`""
    "`t`t`"apps`""
    "`t`t{"
    "`t`t}"
    "`t}"
  ) -join "`n"
  $blocks.Add($block)
  $next++
}
$newText = $prefix.TrimEnd() + "`n" + ($blocks -join "`n") + "`n" + $suffix + "`n"
[System.IO.File]::WriteAllText($vdfPath, $newText)
$result.changed = $true
$result.action = 'merged'
$Ansible.Changed = $true
$Ansible.Result = $result

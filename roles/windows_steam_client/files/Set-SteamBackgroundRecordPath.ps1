#Requires -Version 5.1
<#
.SYNOPSIS
  Set GameRecording BackgroundRecordPath in every userdata/*/config/localconfig.vdf.
  Does not create recording directories. Creates the GameRecording block if missing
  when a localconfig.vdf already exists.
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$SteamInstallPath,

  [Parameter(Mandatory = $true)]
  [string]$RecordingRoot,

  [switch]$WhatIfCompareOnly
)

$ErrorActionPreference = 'Stop'

function Normalize-SteamPath([string]$Path) {
  # Steam VDF stores Windows paths with escaped backslashes (I:\\Gamerecordings).
  $bs = [string][char]92
  $p = $Path.Trim().TrimEnd($bs[0])
  $p = $p.Replace($bs + $bs, $bs)
  $p = $p.Replace([char]47, $bs[0])  # /
  return $p.ToLowerInvariant().TrimEnd($bs[0])
}

$desired = $RecordingRoot.Trim().TrimEnd('\')
$desiredNorm = Normalize-SteamPath $desired
$userdata = Join-Path $SteamInstallPath 'userdata'

$result = @{
  userdata_exists = (Test-Path -LiteralPath $userdata)
  desired = $desired
  files = @()
  changed = $false
  action = 'none'
}

if (-not $result.userdata_exists) {
  $result.action = 'no_userdata'
  $Ansible.Changed = $false
  $Ansible.Result = $result
  return
}

$fileResults = @()
$anyChanged = $false
$anyDrift = $false

foreach ($dir in (Get-ChildItem -LiteralPath $userdata -Directory)) {
  $lc = Join-Path $dir.FullName 'config\localconfig.vdf'
  $entry = @{
    steamid = $dir.Name
    path = $lc
    exists = (Test-Path -LiteralPath $lc)
    current = $null
    match = $false
    action = 'skip'
  }

  if (-not $entry.exists) {
    $entry.action = 'missing_localconfig'
    $anyDrift = $true
    $fileResults += $entry
    continue
  }

  $text = [System.IO.File]::ReadAllText($lc)
  $rx = [regex]'\"BackgroundRecordPath\"\s+\"([^\"]*)\"'
  $m = $rx.Match($text)

  if ($m.Success) {
    $entry.current = $m.Groups[1].Value
    $entry.match = ((Normalize-SteamPath $entry.current) -eq $desiredNorm)
    if ($entry.match) {
      $entry.action = 'match'
    } elseif ($WhatIfCompareOnly) {
      $entry.action = 'would_replace'
      $anyDrift = $true
    } else {
      $escaped = $desired -replace '\\', '\\'
      $text = $rx.Replace($text, "`"BackgroundRecordPath`"`t`t`"$escaped`"", 1)
      [System.IO.File]::WriteAllText($lc, $text)
      $entry.action = 'replaced'
      $anyChanged = $true
    }
  } else {
    $gr = [regex]'(?s)\"GameRecording\"\s*\{'
    $gm = $gr.Match($text)
    $escaped = $desired -replace '\\', '\\'
    $line = "`t`t`"BackgroundRecordPath`"`t`t`"$escaped`""
    if ($WhatIfCompareOnly) {
      if ($gm.Success) {
        $entry.action = 'would_insert_key'
      } else {
        $entry.action = 'would_insert_block'
      }
      $anyDrift = $true
    } elseif ($gm.Success) {
      $insertAt = $gm.Index + $gm.Length
      $text = $text.Insert($insertAt, "`n$line")
      [System.IO.File]::WriteAllText($lc, $text)
      $entry.action = 'inserted_key'
      $anyChanged = $true
    } else {
      $block = @(
        "`t`"GameRecording`""
        "`t{"
        $line
        "`t}"
      ) -join "`n"
      $trimmed = $text.TrimEnd()
      $lastBrace = $trimmed.LastIndexOf('}')
      if ($lastBrace -lt 0) { throw "Cannot locate closing brace in $lc" }
      $text = $trimmed.Substring(0, $lastBrace) + $block + "`n" + $trimmed.Substring($lastBrace) + "`n"
      [System.IO.File]::WriteAllText($lc, $text)
      $entry.action = 'inserted_block'
      $anyChanged = $true
    }
  }

  $fileResults += $entry
}

$result.files = $fileResults
$result.changed = $anyChanged
if ($WhatIfCompareOnly) {
  if ($anyDrift) {
    $result.action = 'drift'
  } else {
    $result.action = 'match'
  }
} elseif ($anyChanged) {
  $result.action = 'updated'
} else {
  $result.action = 'match'
}

$Ansible.Changed = $anyChanged -and (-not $WhatIfCompareOnly.IsPresent)
$Ansible.Result = $result

# collect-gpu-evidence.ps1 — deployed to D:\ai\diagnostics\probes\
$ErrorActionPreference = 'Continue'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$root = if ($env:GPU_DIAGNOSTICS_ROOT) { $env:GPU_DIAGNOSTICS_ROOT } else { 'D:\ai\diagnostics' }

Write-Output "=== collect-gpu-evidence $stamp ==="
Write-Output "HOST: $env:COMPUTERNAME"

Write-Output '=== GPU WMI ==='
Get-CimInstance Win32_VideoController |
  Where-Object { $_.Name -match 'AMD|Radeon' } |
  Select-Object Name, DriverVersion, PNPDeviceID |
  Format-List

Write-Output '=== 3D utilization (top) ==='
try {
  (Get-Counter '\GPU Engine(*engtype_3D)\Utilization Percentage').CounterSamples |
    Where-Object { $_.CookedValue -gt 1 } |
    Sort-Object CookedValue -Descending |
    Select-Object -First 8 InstanceName, @{ N = 'Pct'; E = { [math]::Round($_.CookedValue, 1) } }
}
catch {
  Write-Output $_.Exception.Message
}

Write-Output '=== Dedicated VRAM (MB) ==='
try {
  (Get-Counter '\GPU Adapter Memory(*)\Dedicated Usage').CounterSamples |
    Sort-Object CookedValue -Descending |
    Select-Object -First 3 InstanceName, @{ N = 'MB'; E = { [int]($_.CookedValue / 1MB) } }
}
catch {
  Write-Output $_.Exception.Message
}

Write-Output '=== Diagnostics-Performance 500 (last 5) ==='
try {
  Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-Diagnostics-Performance/Operational'
    Id      = 500
  } -MaxEvents 5 -ErrorAction Stop |
    Select-Object TimeCreated, Message
}
catch {
  Write-Output $_.Exception.Message
}

Write-Output '=== HWiNFO CSV files ==='
Get-ChildItem -Path (Join-Path $root 'hwinfo') -Filter '*.csv' -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 5 FullName, LastWriteTime, Length

Write-Output '=== Afterburner HML files ==='
Get-ChildItem -Path (Join-Path $root 'afterburner') -Filter '*.hml' -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 5 FullName, LastWriteTime, Length

Write-Output '=== AMD CN exports (ericc) ==='
$amd = 'C:\Users\ericc\AppData\Local\AMD\CN'
@(
  (Join-Path $amd 'RAG_CNDB_GAME\Games_Session_Info.md')
  (Join-Path $amd 'RAG_CNDB_GAME\Dead_by_Daylight.md')
) | ForEach-Object {
  if (Test-Path $_) {
    Get-Item $_ | Select-Object FullName, LastWriteTime, Length
    Select-String -Path $_ -Pattern '95th percentile|FSR|frame time|Power' -CaseSensitive:$false |
      ForEach-Object { $_.Line.Trim() } |
      Select-Object -First 8
  }
}

Write-Output '=== Probe complete ==='

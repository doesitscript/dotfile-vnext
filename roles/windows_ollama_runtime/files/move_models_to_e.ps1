$ErrorActionPreference = "Stop"
$src = "D:\ai\models\ollama"
$dst = "E:\ai\models\ollama"
$log = "C:\ProgramData\Ansible\windows_ollama_runtime\models_move.log"

function GB([long]$b) { [math]::Round($b/1GB, 2) }

$dBefore = (Get-PSDrive D).Free
$eBefore = (Get-PSDrive E).Free
"D_free_before_GB=$(GB $dBefore)" | Tee-Object -FilePath $log
"E_free_before_GB=$(GB $eBefore)" | Tee-Object -FilePath $log -Append

# Stop Ollama so files are not locked
schtasks /End /TN ollama-runtime 2>$null | Out-Null
Get-Process ollama*, "Ollama*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

if (-not (Test-Path $src)) {
  "SRC_MISSING $src" | Tee-Object -FilePath $log -Append
  exit 2
}

New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null

if ((Test-Path $dst) -and (Get-ChildItem $dst -Force -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
  "DST_NONEMPTY $dst - will merge with robocopy then remove src" | Tee-Object -FilePath $log -Append
}

# Mirror copy then delete source (safer than /MOVE mid-flight)
$rc = Start-Process -FilePath robocopy.exe -ArgumentList @(
  $src, $dst, "/E", "/COPY:DAT", "/R:2", "/W:5", "/NFL", "/NDL", "/NP"
) -Wait -PassThru
# robocopy exit codes 0-7 are success
if ($rc.ExitCode -ge 8) {
  "ROBOCOPY_FAILED exit=$($rc.ExitCode)" | Tee-Object -FilePath $log -Append
  exit $rc.ExitCode
}
"ROBOCOPY_OK exit=$($rc.ExitCode)" | Tee-Object -FilePath $log -Append

# Verify destination has blobs
if (-not (Test-Path (Join-Path $dst "blobs"))) {
  "DST_MISSING_BLOBS" | Tee-Object -FilePath $log -Append
  exit 3
}

Remove-Item -LiteralPath $src -Recurse -Force
"SRC_REMOVED $src" | Tee-Object -FilePath $log -Append

# Point machine env immediately (Ansible will also converge)
[Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $dst, "Machine")
$env:OLLAMA_MODELS = $dst
"OLLAMA_MODELS=$dst" | Tee-Object -FilePath $log -Append

# Restart Ollama task
schtasks /Run /TN ollama-runtime 2>$null | Out-Null
Start-Sleep 8

$dAfter = (Get-PSDrive D).Free
$eAfter = (Get-PSDrive E).Free
"D_free_after_GB=$(GB $dAfter)" | Tee-Object -FilePath $log -Append
"E_free_after_GB=$(GB $eAfter)" | Tee-Object -FilePath $log -Append
"D_freed_GB=$(GB ($dAfter - $dBefore))" | Tee-Object -FilePath $log -Append
"E_used_GB=$(GB ($eBefore - $eAfter))" | Tee-Object -FilePath $log -Append

# Health
try {
  $tags = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 30
  "models=" + (($tags.models | ForEach-Object { $_.name }) -join ",") | Tee-Object -FilePath $log -Append
} catch {
  "HEALTH_ERR $($_.Exception.Message)" | Tee-Object -FilePath $log -Append
  exit 4
}

Get-Content $log
exit 0

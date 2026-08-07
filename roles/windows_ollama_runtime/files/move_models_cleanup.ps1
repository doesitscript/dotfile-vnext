$ErrorActionPreference = "Continue"
$src = "D:\ai\models\ollama"
$dst = "E:\ai\models\ollama"
$log = "C:\ProgramData\Ansible\windows_ollama_runtime\models_move_cleanup.log"

function GB([long]$b) { [math]::Round($b/1GB, 2) }

$dBefore = (Get-PSDrive D).Free
"D_free_before_cleanup_GB=$(GB $dBefore)" | Tee-Object -FilePath $log

# Hard-stop anything that could lock blobs
schtasks /End /TN ollama-runtime 2>$null | Out-Null
schtasks /End /TN 'Ollama' 2>$null | Out-Null
Get-Process | Where-Object { $_.ProcessName -match 'ollama' } | ForEach-Object {
  "KILL $($_.ProcessName) pid=$($_.Id)" | Tee-Object -FilePath $log -Append
  Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep 5

if (-not (Test-Path (Join-Path $dst "blobs"))) {
  "DST_MISSING_BLOBS abort" | Tee-Object -FilePath $log -Append
  exit 3
}

$dstSize = (Get-ChildItem $dst -Recurse -Force -EA SilentlyContinue | Measure-Object Length -Sum).Sum
"DST_GB=$(GB ([long]$dstSize))" | Tee-Object -FilePath $log -Append

if (Test-Path $src) {
  # Clear read-only attributes then delete
  Get-ChildItem $src -Recurse -Force -EA SilentlyContinue | ForEach-Object {
    try { $_.Attributes = 'Normal' } catch {}
  }
  cmd /c "rmdir /s /q `"$src`""
  if (Test-Path $src) {
    # Second pass with takeown/icacls for stubborn files
    takeown /F $src /R /D Y | Out-Null
    icacls $src /grant Administrators:F /T /C | Out-Null
    cmd /c "rmdir /s /q `"$src`""
  }
}

if (Test-Path $src) {
  "SRC_STILL_PRESENT" | Tee-Object -FilePath $log -Append
  Get-ChildItem $src -Recurse -Force -EA SilentlyContinue | Select-Object -First 20 FullName | ForEach-Object { "$_" | Tee-Object -FilePath $log -Append }
  exit 5
}

"SRC_REMOVED" | Tee-Object -FilePath $log -Append
[Environment]::SetEnvironmentVariable("OLLAMA_MODELS", $dst, "Machine")
$env:OLLAMA_MODELS = $dst
"OLLAMA_MODELS=$dst" | Tee-Object -FilePath $log -Append

schtasks /Run /TN ollama-runtime 2>$null | Out-Null
Start-Sleep 10

$dAfter = (Get-PSDrive D).Free
$eAfter = (Get-PSDrive E).Free
"D_free_after_GB=$(GB $dAfter)" | Tee-Object -FilePath $log -Append
"E_free_after_GB=$(GB $eAfter)" | Tee-Object -FilePath $log -Append
"D_freed_GB=$(GB ($dAfter - $dBefore))" | Tee-Object -FilePath $log -Append

try {
  $tags = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 60
  "models=" + (($tags.models | ForEach-Object { $_.name }) -join ",") | Tee-Object -FilePath $log -Append
  "model_count=$($tags.models.Count)" | Tee-Object -FilePath $log -Append
} catch {
  "HEALTH_ERR $($_.Exception.Message)" | Tee-Object -FilePath $log -Append
  exit 4
}

Get-Content $log
exit 0

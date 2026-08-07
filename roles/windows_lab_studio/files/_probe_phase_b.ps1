$ErrorActionPreference = "Continue"
Write-Output "=== GPU ==="
Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion | Format-List | Out-String
Write-Output "=== Python launches ==="
py -0p 2>&1 | Out-String
Write-Output "=== Drives ==="
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -in @('C','D','E') } | Format-Table Name, @{N='FreeGB';E={[math]::Round($_.Free/1GB,1)}}, @{N='UsedGB';E={[math]::Round($_.Used/1GB,1)}} -AutoSize | Out-String
Write-Output "=== AI roots ==="
foreach ($p in @('D:\ai','E:\ai','D:\ai\stacks','E:\ai\models','D:\ai\comfyui','E:\ai\comfyui')) {
  if (Test-Path $p) { Write-Output "EXISTS $p"; Get-ChildItem $p -ErrorAction SilentlyContinue | Select-Object -First 8 Name | ForEach-Object { Write-Output ("  " + $_.Name) } }
  else { Write-Output "MISSING $p" }
}
Write-Output "=== Git ==="
git --version 2>&1 | Out-String

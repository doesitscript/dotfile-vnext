Write-Output "=== sshd service ==="
Get-Service sshd | Format-Table Name, Status, StartType -AutoSize | Out-String | Write-Output

Write-Output "=== sshd_config relevant lines ==="
Select-String -Path "C:\ProgramData\ssh\sshd_config" -Pattern "Port|LogLevel|SyslogFacility|DefaultShell|AuthorizedKeys" |
    ForEach-Object { $_.Line.Trim() } | Write-Output

Write-Output ""
Write-Output "=== file-based log dir ==="
if (Test-Path "C:\ProgramData\ssh\logs") {
    Get-ChildItem "C:\ProgramData\ssh\logs" | Format-Table Name, Length, LastWriteTime | Out-String | Write-Output
} else {
    Write-Output "Not present - ETW Event Log only"
}

Write-Output ""
Write-Output "=== OpenSSH/Operational last 10 events ==="
$events = Get-WinEvent -LogName "OpenSSH/Operational" -MaxEvents 10 -ErrorAction SilentlyContinue
if ($events) {
    $events | ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" } | Write-Output
} else {
    Write-Output "No events or log not enabled"
}

Write-Output ""
Write-Output "=== OpenSSH/Admin last 10 events ==="
$adminEvents = Get-WinEvent -LogName "OpenSSH/Admin" -MaxEvents 10 -ErrorAction SilentlyContinue
if ($adminEvents) {
    $adminEvents | ForEach-Object { "$($_.TimeCreated.ToString('s'))  $($_.Message)" } | Write-Output
} else {
    Write-Output "No events or log not enabled"
}

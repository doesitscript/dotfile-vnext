# Requires admin
$base = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability"

# 1) Disable the Shutdown Event Tracker (the "why are you shutting down/restarting" prompt)
New-Item -Path $base -Force | Out-Null
New-ItemProperty -Path $base -Name "ShutdownReasonOn" -PropertyType DWord -Value 0 -Force | Out-Null

# 2) Do not display the "Event Tracker" UI at shutdown
New-ItemProperty -Path $base -Name "ShutdownReasonUI" -PropertyType DWord -Value 0 -Force | Out-Null

# 3) Don't show the "unexpected shutdown" reason dialog after an improper shutdown
New-ItemProperty -Path $base -Name "ShutdownReasonPrompt" -PropertyType DWord -Value 0 -Force | Out-Null

# Apply immediately where possible
gpupdate /target:computer /force | Out-Null

# Show current values
Get-ItemProperty -Path $base | Select-Object ShutdownReasonOn, ShutdownReasonUI, ShutdownReasonPrompt

#####################
Purge ubuntu
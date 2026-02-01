@echo off
REM Set PowerShell execution policy to Bypass permanently for CurrentUser
powershell.exe -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force"

REM Run the PowerShell bootstrap script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0bootstrap_inventory.ps1"

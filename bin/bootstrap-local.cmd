@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%bootstrap-local.ps1"

if not exist "%PS_SCRIPT%" (
  echo [ERROR] Missing script: "%PS_SCRIPT%"
  exit /b 1
)

echo [INFO] Running: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo [ERROR] bootstrap-local.ps1 failed with exit code %EXIT_CODE%
  exit /b %EXIT_CODE%
)

echo [INFO] bootstrap-local.ps1 completed successfully.
exit /b 0

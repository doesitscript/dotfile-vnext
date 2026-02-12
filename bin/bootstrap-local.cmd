@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%bootstrap-local.ps1"

if not exist "%PS_SCRIPT%" (
  echo [ERROR] Missing script: "%PS_SCRIPT%"
  exit /b 1
)

echo.
echo ================================================================================
echo   NEXT SCRIPT: bin\bootstrap-local.ps1 (this .cmd always runs it)
echo   TO RUN ONLY FACT COLLECTION (no host_vars, no Ansible chain):
echo     Run instead: .\bin\bootstrap-local.ps1 -FactsOnly
echo   TO RUN FACTS + HOST_VARS BUT NOT THE REST OF THE CHAIN:
echo     Run instead (in PowerShell): .\bin\bootstrap-local.ps1 -RunAll:$false
echo ================================================================================
echo.

echo [INFO] Running: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo [ERROR] bootstrap-local.ps1 failed with exit code %EXIT_CODE%
  exit /b %EXIT_CODE%
)

echo [INFO] bootstrap-local.ps1 completed successfully.
exit /b 0

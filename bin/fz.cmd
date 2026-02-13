@echo off
setlocal
REM Run fz (bash) via WSL from repo root. Requires WSL. Usage: bin\fz.cmd ping server-225-wsl
REM role-local: run on Windows localhost (no WSL) so the git role uses Windows paths.
cd /d "%~dp0.."
if "%~1"=="role-local" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fz-role-local.ps1" %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
wsl bash -c './bin/fz "$@"' _ %*
exit /b %ERRORLEVEL%

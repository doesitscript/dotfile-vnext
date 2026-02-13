@echo off
setlocal
REM Run fz (bash) via WSL from repo root. Requires WSL. Usage: bin\fz.cmd ping server-225-wsl
cd /d "%~dp0.."
wsl bash -c './bin/fz "$@"' _ %*
exit /b %ERRORLEVEL%

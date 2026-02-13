@echo off
setlocal
REM Run fz via WSL from repo root. Ansible is run from Mac (or WSL); this entrypoint delegates to WSL.
REM Usage: bin\fz.cmd ping server-225-wsl, bin\fz.cmd bootstrap --limit server-225-win, etc.
cd /d "%~dp0.."
wsl bash -c './bin/fz "$@"' _ %*
exit /b %ERRORLEVEL%

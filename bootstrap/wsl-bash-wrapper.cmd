@echo off
setlocal
set WSL_DISTRO=Ubuntu-24.04
rem Written by bootstrap for OpenSSH default shell -> WSL bash
wsl -d %WSL_DISTRO% -e /bin/bash -l -c "%~2"

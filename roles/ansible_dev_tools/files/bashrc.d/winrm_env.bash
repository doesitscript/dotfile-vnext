# WinRM env vars — required for Ansible WinRM connections on macOS.
# Deployed centrally by the shell_config role to ~/.bashrc.d/.
# This file lives here per the convention: roles/<rolename>/files/bashrc.d/<name>.bash
# See roles/SHELL-CONFIG-PATTERN.md for the full pattern description.
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes
export no_proxy=*

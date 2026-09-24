Package Managers
================

Ensures package-manager clients are usable. Does **not** upgrade-all by default.

- Ubuntu: optional `apt update` when `package_update`
- Windows: ensure Chocolatey present; optional `choco upgrade all` when `package_upgrade`
- macOS: optional brew update / upgrade_all when flags are true

Defaults (`package_update` / `package_upgrade`: false) keep hosts under
Ansible-pinned state. Use `roles/managed_update_policy` to disable OS
unattended updaters.

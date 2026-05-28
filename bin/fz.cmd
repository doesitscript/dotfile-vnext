@echo off
REM fz via WSL is retired for server automation. Use the Mac controller:
REM   bin/codex-env ansible-playbook playbooks/... -i inventory/inventory.yaml
REM Optional desktop WSL: bin/desktop/bootstrap-ansible-local.ps1
echo [ERROR] bin\fz.cmd is retired. Run Ansible from mac-dev with bin/codex-env ansible-playbook.
exit /b 1

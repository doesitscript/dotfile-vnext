# Bootstrap Updates - File Creation Guide

This folder contains all the files that need to be created or updated for the local bootstrap functionality.

## Files to Create (New)

1. **bin/bootstrap-local.ps1** → `bin_bootstrap-local.ps1`
   - Windows PowerShell script run as admin on target machine
   - Configures WinRM HTTPS and WSL features
   - Writes facts to `facts/server-225.json`

2. **bin/bootstrap-local.sh** → `bin_bootstrap-local.sh`
   - Bash script run inside WSL on target machine
   - Installs ansible if needed and runs local bootstrap playbook

3. **bootstrap/local/local_bootstrap.yml** → `bootstrap_local_local_bootstrap.yml`
   - Ansible playbook that configures SSH in WSL and writes host_vars

4. **bootstrap/local/templates/host_vars_windows.yml.j2** → `bootstrap_local_templates_host_vars_windows.yml.j2`
   - Jinja2 template for Windows host_vars

5. **bootstrap/local/templates/host_vars_wsl.yml.j2** → `bootstrap_local_templates_host_vars_wsl.yml.j2`
   - Jinja2 template for WSL host_vars

6. **inventory/host_vars/server-225-win.yaml** → `inventory_host_vars_server-225-win.yaml.example`
   - Example of generated file (bootstrap creates this)

7. **inventory/host_vars/server-225-wsl.yaml** → `inventory_host_vars_server-225-wsl.yaml.example`
   - Example of generated file (bootstrap creates this)

## Files to Update (Existing)

1. **inventory/inventory.yaml** → `inventory_inventory.yaml.update`
   - Update server-225-win and server-225-wsl entries to use variables from host_vars
   - See update instructions in the file

2. **vault/shared.vault.yml** → `vault_shared.vault.yml.update`
   - Add `vault_server_225_win_password` variable
   - See update instructions in the file

## Usage

1. Copy files from this folder to their proper locations in the repo
2. Follow the update instructions for existing files
3. Run `bin/bootstrap-local.ps1` on the target Windows machine (as admin)
4. If reboot required, reboot and run again
5. Run `bin/bootstrap-local.sh` inside WSL on the same machine
6. Host_vars will be automatically generated

## Important Notes

- The bootstrap never writes real secrets - only vault variable references
- Host_vars files are generated automatically - do not hand-edit them
- The inventory.yaml should reference variables, not hardcoded values
- Keep `inventory/host_vars/server-225.yaml` as-is for node-level truths

# Bootstrap Scripts Context

## Purpose

Bootstrap scripts prepare bare Windows machines for Ansible management. They run **before** Ansible can reach the machine and handle the chicken-and-egg problem of initial access.

## Script Chain

```
[Windows Admin PowerShell]
  └─ bin/bootstrap-local.ps1
       ├─ Detects physical node (hostname/IP matching against params/site.yaml)
       ├─ Configures WinRM listener (HTTP 5985) + firewall
       ├─ Generates host_vars/<node>-win.yaml and host_vars/<node>-wsl.yaml
       ├─ Optionally installs OpenSSH Server (-InstallOpenSSH flag)
       └─ Chains to bin/bootstrap-ansible-local.ps1 (if -RunAll, which is default)
            ├─ Reads WSL config from generated host_vars
            ├─ Creates cloud-init user-data for WSL user provisioning
            ├─ Installs/launches WSL distro (Ubuntu-24.04)
            └─ Runs bin/bootstrap-local.sh inside WSL
                 ├─ Configures passwordless sudo
                 ├─ Installs openssh-server
                 └─ Enables pubkey authentication
```

## Key Design Decisions

- Bootstrap scripts are **idempotent** — safe to re-run
- `win_password` in host_vars is preserved across re-runs (not overwritten)
- WSL user creation uses **cloud-init** for automated provisioning
- Path conversion between Windows and WSL is handled (e.g., `D:\develop\` → `/mnt/d/develop/`)

## When Editing Bootstrap Scripts

- Always maintain the idempotent design — check before modifying
- Follow the PowerShell help contract (see `powershell_help_contract.md` rule)
- Test with `-WhatIf` or `-DryRun` parameters where available
- The scripts use `params/site.yaml` as their source of truth — keep them aligned

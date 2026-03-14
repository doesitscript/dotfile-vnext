# Bootstrap Windows for Mac Management (WinRM HTTP + OpenSSH)

The **Mac** is the control node: you run Ansible from the Mac to manage Windows (and WSL) nodes over **WinRM HTTP (5985)** and **OpenSSH (port 22)**. Ansible is not run natively on Windows.

## Overview

- **WinRM HTTP (5985)** – Ansible on the Mac connects to Windows over WinRM HTTP with NTLM. Used for `fz bootstrap --limit server-225-win`, `fz bootstrap-winrm`, and all deploy playbooks. If you see "Module result deserialization failed" or "ConvertFrom-Json ... System.Object[]", see [WinRM troubleshooting](winrm_troubleshooting.md).
- **OpenSSH Server (port 22)** – So you can `ssh user@<host>` to the Windows box (default shell is WSL bash). Same `authorized_keys` pattern as WSL; the Mac’s key is deployed so the Mac can remote in.

## One-time setup on the Windows node (run as Administrator)

1. **Clone/copy the repo** on the Windows machine (e.g. `D:\develop\dotfile-vnext`).

2. **Ensure the Mac’s SSH key is available for authorized_keys** (pick one):
   - Put the controller public key in **`bootstrap/id_ed25519_ansible.pub`** in the repo (so when the script runs it adds it to Windows `authorized_keys`), or
   - The controller key lives at **`~/.ssh/id_ed25519_ansible.pub`** on the Mac. Playbooks read it from the execution node at run time.

3. **Set or preserve `win_password`** in host_vars (script preserves existing when regenerating):
   - Ensure `inventory/host_vars/<physical_node>-win.yaml` has `win_password` (or use vault).

4. **Run the local bootstrap script** (elevated PowerShell):
   ```powershell
   cd D:\develop\dotfile-vnext
   .\bin\bootstrap-local.ps1
   ```
   This script:
   - Configures **WinRM HTTP (5985)** (listener + firewall via `winrm quickconfig`).
   - Installs/configures **OpenSSH Server** (port 22, firewall, `sshd_config`, default shell = WSL bash).
   - Writes **host_vars** (`inventory/host_vars/<node>-win.yaml`, `-wsl.yaml`) so the Mac can connect (ansible_host, ansible_port 5985, etc.).
   - Optionally appends a key to Windows **authorized_keys** from `bootstrap/id_ed25519_ansible.pub` if present (deprecated: `bootstrap/mac_ssh_key.pub`). The main path is: run the playbook from the Mac so it deploys the execution node’s `~/.ssh/id_ed25519_ansible.pub`.

**Is the Windows box ready to accept connections from the Mac after this?**

- **WinRM**: Yes. The Mac can run playbooks as soon as the repo on the Mac has the same host_vars (sync the repo so the Mac has the generated `ansible_host`, `ansible_port: 5985`, and credentials).
- **OpenSSH**: Yes, **if** you run the playbook from the Mac once (it connects via WinRM and deploys the execution node’s `~/.ssh/id_ed25519_ansible.pub` to `authorized_keys`). Or place the key in `bootstrap/id_ed25519_ansible.pub` and the script will add it.

5. **Optional – facts only:**  
   `.\bin\bootstrap-local.ps1 -FactsOnly` – only refreshes facts; does not overwrite host_vars or chain to other scripts.

Sync the repo to the Mac (or pull) so the Mac has the updated host_vars (and keys if needed).

## From the Mac

- **Bootstrap the Windows host** (reinforce WinRM HTTP + OpenSSH + deploy controller key):
  ```bash
  ./bin/fz bootstrap --limit server-225-win
  ```
  Runs `playbooks/bootstrap_windows.yaml`: WinRM HTTP (5985) firewall, OpenSSH Server (port 22), and adds the controller’s public key (`~/.ssh/id_ed25519_ansible.pub`, read at run time) to Windows `authorized_keys`.

- **Node-specific bootstrap (more roles over WinRM):**
  ```bash
  ./bin/fz bootstrap-winrm --limit server-225-win
  ```
  Runs the node-specific playbook (e.g. `bootstrap_server_225.yaml`) over WinRM HTTP.

- **Verify:**
  ```bash
  ./bin/fz ping server-225-win
  ./bin/fz verify
  ```

- **SSH to the Windows box** (after OpenSSH and keys are set):
  ```bash
  ssh joshc@<ansible_host>
  ```
  You land in WSL (default shell is WSL bash). Use the same key the repo uses (e.g. `~/.ssh/id_ed25519_ansible`); its public half should be in `authorized_keys`.

## Requirements

- **WinRM (HTTP 5985)**  
  In `inventory/host_vars/<node>-win.yaml`:
  - `ansible_connection: winrm`
  - `ansible_port: 5985`
  - `ansible_winrm_scheme: http`
  - `ansible_winrm_transport: ntlm`
  - `ansible_user` and `ansible_password` (or `ansible_winrm_password`) for NTLM.

- **OpenSSH**  
  The controller public key must be in the Windows user’s `~/.ssh/authorized_keys`. The playbook reads it from the execution node’s `~/.ssh/id_ed25519_ansible.pub` and deploys it; the local script can also use `bootstrap/id_ed25519_ansible.pub` (deprecated: `bootstrap/mac_ssh_key.pub`). For fixed OpenSSH **host keys**, on the Mac run `./bin/fz bootstrap-openssh-host-keys`, sync the repo, then run `.\bin\bootstrap-local.ps1` on Windows—see `bootstrap/openssh_host_keys/README.md`.

## Summary

| Step | Where | What |
|------|--------|------|
| 1 | Windows (Admin) | Run `.\bin\bootstrap-local.ps1` → WinRM HTTP (5985), OpenSSH (22), host_vars; authorized_keys from playbook (~/.ssh/id_ed25519_ansible.pub) or bootstrap/id_ed25519_ansible.pub |
| 2 | Mac | Sync repo so Mac has host_vars (and keys if needed) |
| 3 | Mac | `./bin/fz bootstrap --limit server-225-win` → reinforce WinRM HTTP + OpenSSH + deploy controller key |
| 4 | Mac | `./bin/fz ping server-225-win` and `./bin/fz verify`; then `ssh user@<host>` to remote in |

All management is from the Mac over WinRM HTTP (5985) and OpenSSH (port 22); no Ansible runs natively on Windows.

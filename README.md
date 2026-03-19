# FUZLANG Infrastructure

Multi-node AI infrastructure automation using Ansible.

## Execution Preference

Prefer native `ansible-playbook` commands and focused playbooks over custom CLI
wrappers. `./bin/fz` is being de-emphasized for normal execution and should be
treated as transitional convenience/orchestration glue, not the preferred
long-term interface.

See [docs/ansible/native-ansible-first.md](docs/ansible/native-ansible-first.md).

## Hands-free flow

The only manual steps are: **(1)** put your vault secret in `.vault_pass` at repo root (see `config/README_vault_pass.md`), and **(2)** run the first kick-off command for the node (e.g. `.\bin\bootstrap-local.cmd` on Windows, or `./bin/fz bootstrap --limit mac-dev` on the Mac). Everything else (venv, collections, SSH key generation, host_vars, WSL bootstrap) is automated.

## Most up-to-date capabilities (two sides of the same coin)

Two playbooks represent the current, stable automation: the **execution node** (Mac) and **Windows OpenSSH via WinRM**. Run them in order from the Mac.

**1. Execution node (Mac)** – Ensures the Mac has the Ansible SSH key and is ready as the control plane. Creates `~/.ssh` and `~/.ssh/id_ed25519_ansible` (and `.pub`) if missing.

```bash
cd /path/to/dotfile-vnext
ansible-playbook playbooks/bootstrap_execution_node.yaml -i inventory/inventory.yaml --limit execution_nodes
```

**2. Windows OpenSSH (via WinRM)** – Sets up OpenSSH Server on Windows: capability, sshd service, firewall rule, `administrators_authorized_keys` file and ACL, installs the execution node’s public key, restarts sshd when needed. Assumes WinRM is already reachable. Target any Windows host(s) with `--limit` (e.g. `server-225-win`).

```bash
ansible-playbook playbooks/boostrap_windows_ssh_via_winrm.yaml -i inventory/inventory.yaml --limit server-225-win
```

Run the execution-node playbook first so the SSH key exists; then run the Windows OpenSSH playbook against the desired Windows host(s).

## Structure

- `playbooks/bootstrap_execution_node.yaml` - Execution node (Mac): SSH key and control-plane readiness
- `playbooks/boostrap_windows_ssh_via_winrm.yaml` - Windows OpenSSH via WinRM (key from execution node)
- `playbooks/bootstrap_server_225.yaml` - Server-225 full bootstrap (WinRM, roles; separate from the SSH pair above)
- `playbooks/bootstrap_local.yml` - Local bootstrap playbook (runs in WSL on each Windows node)
- `playbooks/deploy_shell_config.yaml` - Standalone shell configuration deployment (direnv, cursor, aliases)
- `contracts/` - Canonical contract definitions
- `inventory/` - Ansible inventory and variables
- `playbooks/` - Ansible playbooks
- `roles/` - Ansible roles
- `stacks/` - Docker Compose stack definitions
- `vault/` - Encrypted secrets (Ansible Vault)
- `rendered/` - Generated configuration files

## Nodes

- **mac-dev**: Development control plane (macOS)
- **Server-225**: Primary GPU node (Windows Server 2025, RTX 5090)
- **network-server**: Storage and observability node (Windows Server 2025)
- **dev-3090**: Development GPU node (Windows 11, RTX 3090)

## Prerequisites for Windows Servers

Before running bootstrap on a new Windows server, ensure:

1. **Repository Cloned**: The dotfile-vnext repository is present on the target server (for example `D:\develop\dotfile-vnext`)
2. **Administrator Privileges**: Run the terminal as Administrator (required for full Windows feature/bootstrap steps)
3. **Network Access**: The server can reach required package/endpoints (for example WSL distro install)

`bin/bootstrap-local.cmd` is the Windows entrypoint. It launches `bin/bootstrap-local.ps1` with:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "...\bin\bootstrap-local.ps1"
```

That means you do not have to pre-configure a process-level execution policy before starting bootstrap.

## Developer setup (Cursor)

**New devs:** Follow **`instructions.md`** to add the listed Ansible doc URLs to Cursor Docs. That indexing reduces hallucination and lets the AI see playbook/inventory structure instead of guessing from snippets.

- **llms.txt:** Some sites expose `llms.txt` at their root—a markdown summary for AI. Ansible’s official docs don’t yet; watch for it in third-party collections.
- **Why these URLs:** They’re chosen to minimize “hallucination noise” and maximize the AI’s view of the system’s structure, not just individual YAML lines.
- **Optional:** Consider a custom `.cursorrules` (or rules in `.cursor/rules/`) to enforce “Architect”-level Ansible standards.
- **MCP + Ansible:** For agentic Ansible workflows in Cursor, set up the MCP server for Ansible; see the [step-by-step video](https://www.youtube.com/watch?v=...) for integration (replace with your actual video URL when you have it).

## Running for Server-225 (this machine)

Server-225 is the primary GPU node. Two parts:

### 1. One-time setup **on** Server-225 (Windows)

On the Windows machine (as Administrator):

1. Clone the repo (for example `D:\develop\dotfile-vnext`).
2. In an elevated terminal:
   ```powershell
   cd D:\develop\dotfile-vnext
   .\bin\bootstrap-local.cmd
   ```
3. `bootstrap-local.cmd` starts `bootstrap-local.ps1` as the first-stage bootstrap. The PowerShell script detects node identity, configures WinRM/WSL prerequisites, and writes generated facts and host vars.
4. After that local bootstrap completes, use `bin/fz` from your control environment to run Ansible bootstrap/deploy/verify phases.

`bootstrap-local.ps1` will also set `CurrentUser` execution policy to `Bypass` non-interactively so future local PowerShell bootstrap runs are not blocked by prompts.

**Chosen values (any Windows/WSL target):** Ports and connection details are stored in the repo under `inventory/host_vars/<physical_node>-win.yaml` and `<physical_node>-wsl.yaml`. These files are created or updated when you run `.\bin\bootstrap-local.ps1` on that Windows machine. Key variables: `win_ssh_port` (OpenSSH Server, default 22), `wsl_ssh_port` (WSL SSH, default 22), `ansible_host`, `win_user`/`wsl_user`. The bootstrap playbooks and firewall logic use these values so the same code works for every Windows/WSL host in the inventory.

### 2. Run Ansible **against** Server-225

From your **Mac** (mac-dev), with the repo cloned and inventory/host_vars in place (or synced from Server-225):

```bash
cd /path/to/dotfile-vnext

# Bootstrap Windows (WinRM): features, WSL, dirs, GPU check
./bin/fz bootstrap --limit server-225-win

# Deploy main stacks (Ollama, LiteLLM, OpenWebUI) via SSH to WSL
./bin/fz deploy main --limit server-225-wsl

# Optional: verify
./bin/fz verify --limit server-225-win
./bin/fz verify --limit server-225-wsl
```

If you have the repo in **WSL on Server-225**, run the same `./bin/fz` commands from there (WSL can use WinRM to `localhost` or the Windows hostname for `server-225-win`, and SSH to the same host for `server-225-wsl`). Ensure `inventory/host_vars/server-225-win.yaml` has `ansible_host` set to the Windows hostname or IP (e.g. `DESKTOP-VLLM` or `127.0.0.1` for local).

Vault password is needed for deploy if you use encrypted vault files: add `--ask-vault-pass` to the deploy command.

## Bootstrap Mac (control node)

Run **on the Mac** so it can act as the Ansible control node. Inventory already has `mac-dev` (e.g. `Joshs-MBP`, user `joshc`); no extra setup for hostname/username.

**Single command (after clone and vault password)**

```bash
git clone https://github.com/doesitscript/dotfile-vnext.git
cd dotfile-vnext
echo -n 'YOUR_VAULT_PASSWORD' > .vault_pass   # or use --ask-vault-pass when running fz

./bin/fz bootstrap --limit mac-dev
```

`fz bootstrap --limit mac-dev` does everything: creates `.venv`, installs Python deps and Ansible Galaxy collections (`requirements.yml`), then runs the Mac bootstrap playbook. The playbook ensures the Ansible SSH key exists at **`~/.ssh/id_ed25519_ansible`** (and `.pub`) on the Mac—generating it only if missing; the key is never copied into the repo. It then runs baseline, python, git, hub, homebrew, ansible_runner. Windows/WSL bootstrap playbooks read the public key from the execution node (Mac) at run time. After that, from this repo run `./bin/fz deploy main --limit server-225-wsl` and similar.

For focused local Ansible toolchain convergence on the Mac, prefer:

```bash
.venv/bin/ansible-playbook playbooks/mac/ansible_dev_tools.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

instead of `./bin/fz role-local ansible_dev_tools`.

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.
See `AGENTS.md` for durable repo-specific Codex guidance.
See `docs/codex_framework/README.md` for the Codex framework capability used inside this repo.
See `docs/codex_framework/partner_process.md` for the human + AI working process used to keep research, idempotency, verification, and rollback explicit.

## Deploy Shell Configuration

Deploy direnv, cursor editor, and shell aliases independently of bootstrap:

```bash
# Deploy to Mac
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev

# Deploy to WSL
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit server-225-wsl
```

See `docs/deploy_shell_config.md` for detailed usage and troubleshooting.

## Contract

All configuration is driven by `contracts/fuzlang.contract.yaml`.


## Current issues:
The extension reads the setting with the VS Code configuration API:

activationScript: await e.get("python.activationScript")
interpreterPath:  await e.get("python.interpreterPath")

Found the root cause. Here is exactly what's happening:

The extension reads the setting with the VS Code configuration API:

activationScript: await e.get("python.activationScript")
interpreterPath:  await e.get("python.interpreterPath")
Both are read the same way — raw get() calls. The VS Code configuration API does not resolve ${workspaceFolder} automatically.

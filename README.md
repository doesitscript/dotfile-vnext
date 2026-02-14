# FUZLANG Infrastructure

Multi-node AI infrastructure automation using Ansible.

## Hands-free flow

The only manual steps are: **(1)** put your vault secret in `.vault_pass` at repo root (see `config/README_vault_pass.md`), and **(2)** run the first kick-off command for the node (e.g. `.\bin\bootstrap-local.cmd` on Windows, or `./bin/fz bootstrap --limit mac-dev` on the Mac). Everything else (venv, collections, SSH key generation, host_vars, WSL bootstrap) is automated.

## Structure

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

`fz bootstrap --limit mac-dev` does everything: creates `.venv`, installs Python deps and Ansible Galaxy collections (`requirements.yml`), then runs the Mac bootstrap playbook. If `vault/ansible_ssh.vault.yml` does not exist, the key pair is **generated on the Mac** and stored in the vault and `.mgmt/ansible_ssh.pub` (no server run required first). The playbook installs the private key to `~/.ssh/id_ed25519_ansible` and runs baseline, python, git, hub, homebrew, ansible_runner. After that, from this repo run `./bin/fz deploy main --limit server-225-wsl` and similar. See `docs/ansible_ssh_vault.md` for details.

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.

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




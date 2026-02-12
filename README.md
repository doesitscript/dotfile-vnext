# FUZLANG Infrastructure

Multi-node AI infrastructure automation using Ansible.

## Structure

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

## Command reference (copy-paste)

| Command | What it does |
|---------|----------------|
| `./bin/fz bootstrap --limit server-225-win` | **Local bootstrap from WSL:** run the local bootstrap playbook (host_vars, SSH, controller key, vault). Use when you are already in WSL on the target machine. |
| `.\bin\bootstrap-local.ps1` | **Full bootstrap from Windows (Admin):** detect node, collect facts, write host_vars, then chain into Ansible local bootstrap. Run in elevated PowerShell on the Windows host. |
| `.\bin\bootstrap-local.ps1 -FactsOnly` | **Facts only:** refresh `facts\<node>.json` (hostname, IP, WSL distros) and exit. No host_vars or Ansible run. |
| `./bin/fz collect-facts` | **Refresh facts from WSL:** invokes the Windows fact collector; for full WinRM+WSL collection you need elevated PowerShell and `.\bin\bootstrap-local.ps1 -FactsOnly`. |
| `./bin/fz deploy main --limit server-225-wsl` | Deploy main stacks (Ollama, LiteLLM, etc.) to the WSL host. |
| `./bin/fz verify` | Run the verify playbook across the fabric (no `--limit` required). |

**Vault:** Create `.vault_pass` in repo root with one line (your vault password). Ansible uses `vault_pass.sh`, which reads that file. See `config/README_vault_pass.md`. If `vault_pass.sh` is not executable: `chmod +x vault_pass.sh` (from WSL).

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.

## Contract

All configuration is driven by `contracts/fuzlang.contract.yaml`.




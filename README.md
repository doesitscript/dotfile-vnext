# FUZLANG Infrastructure

**Project version:** `0.7.0` ([VERSION](VERSION)) — homelab edge milestone (Traefik ingress, hom.lab hosts-file, `hom-lab-ctl-dkr-02` identity).

Multi-node **AI product engineering** homelab automation using Ansible — agents,
evaluation, observability, and controlled model lanes (not ML-training-first).
Layer model: [docs/reference/ai-homelab-layer-model.md](docs/reference/ai-homelab-layer-model.md).
Estate map: [docs/diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md](docs/diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md).

## Current Transition: NetBox Source Of Truth

This repo is now moving into a NetBox integration phase. NetBox should become
the preferred source of truth for durable infrastructure facts, while Ansible
remains the execution layer.

Project-safe NetBox changes follow this order: repo seed/config first, repo
consistency gate second, NetBox apply third. Do not leave live NetBox state ahead
of inventory, role defaults, seed tasks, docs, or aliases in this repo.

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml \
  --tags ipam_netbox_repo_consistency
```

See [docs/plans/2026-05-08--netbox-transition.md](docs/plans/2026-05-08--netbox-transition.md).

## Execution Preference

Prefer native `ansible-playbook` commands and focused playbooks over custom CLI
wrappers. `./bin/fz` is being de-emphasized for normal execution and should be
treated as transitional convenience/orchestration glue, not the preferred
long-term interface.

See [docs/ansible/native-ansible-first.md](docs/ansible/native-ansible-first.md).

## Hands-free flow

The only manual steps are: **(1)** put your vault secret in `.vault_pass` at repo root (see `config/README_vault_pass.md`), and **(2)** run the first kick-off command for the node (e.g. `.\bin\bootstrap-local.cmd` on Windows, or bootstrap the Mac execution node). Everything else (venv, collections, SSH key generation, host_vars) is automated. Connection surfaces per host: [docs/reference/connection-surfaces.md](docs/reference/connection-surfaces.md).

## Most up-to-date capabilities (two sides of the same coin)

Two playbooks represent the current, stable automation: the **execution node** (Mac) and **Windows OpenSSH via WinRM**. Run them in order from the Mac.

**1. Execution node (Mac)** – Ensures the Mac has the Ansible SSH key and is ready as the control plane. Creates `~/.ssh` and `~/.ssh/id_ed25519_ansible` (and `.pub`) if missing.

```bash
cd /path/to/dotfile-vnext
ansible-playbook playbooks/bootstrap_execution_node.yaml -i inventory/inventory.yaml --limit execution_nodes
```

**2. Windows OpenSSH (via WinRM)** – Sets up OpenSSH Server on Windows: capability, sshd service, firewall rule, `administrators_authorized_keys` file and ACL, installs the execution node’s public key, restarts sshd when needed. Assumes WinRM is already reachable. Target any Windows host(s) with `--limit` (e.g. `hom-lab-ctl-hvh-02`).

```bash
ansible-playbook playbooks/boostrap_windows_ssh_via_winrm.yaml -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02
```

Run the execution-node playbook first so the SSH key exists; then run the Windows OpenSSH playbook against the desired Windows host(s).

## Structure

- `playbooks/bootstrap_execution_node.yaml` - Execution node (Mac): SSH key and control-plane readiness
- `playbooks/boostrap_windows_ssh_via_winrm.yaml` - Windows OpenSSH via WinRM (key from execution node)
- `playbooks/bootstrap_server_225.yaml` - Server-225 full bootstrap (WinRM, roles; separate from the SSH pair above)
- `playbooks/bootstrap_local.yml` - Legacy local bootstrap (desktop/WSL historical; see [desktop-wsl-optional.md](docs/reference/desktop-wsl-optional.md))
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
- **hom-lab-ctl-hvh-02** (GPU lane): Windows Server 2025, RTX 5090 — legacy alias `DESKTOP-VLLM` / retired “Server-225”
- **hom-lab-ctl-hvh-01** (storage lane): Windows Server 2025 — retired “network-server” label
- **hom-lab-ctl-dkr-02** / **hom-lab-ctl-k3s-02**: Docker and K3s guests on the GPU lane (LiteLLM, Langfuse, Jupyter)
- **dev-3090**: Development GPU node (Windows 11, RTX 3090)

## Prerequisites for Windows Servers

Before running bootstrap on a new Windows server, ensure:

1. **Repository Cloned**: The dotfile-vnext repository is present on the target server (for example `D:\develop\dotfile-vnext`)
2. **Administrator Privileges**: Run the terminal as Administrator (required for full Windows feature/bootstrap steps)
3. **Network Access**: The server can reach required package/endpoints (Windows features, OpenSSH, Hyper-V guests per [connection-surfaces.md](docs/reference/connection-surfaces.md))

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
3. `bootstrap-local.cmd` starts `bootstrap-local.ps1` as the first-stage bootstrap. The PowerShell script detects node identity, configures WinRM/OpenSSH prerequisites, and writes generated facts and host vars.
4. After that local bootstrap completes, use `bin/fz` from your control environment to run Ansible bootstrap/deploy/verify phases.

`bootstrap-local.ps1` will also set `CurrentUser` execution policy to `Bypass` non-interactively so future local PowerShell bootstrap runs are not blocked by prompts.

**Chosen values (Windows control hosts):** Ports and connection details are in `inventory/host_vars/<inventory_hostname>.yaml` (see `inventory/hosts_mapping.yaml`). Bootstrap may still emit legacy `*-win.yaml` files; steady-state automation uses inventory hostnames such as `hom-lab-ctl-hvh-02` with OpenSSH on port 22.

### 2. Run Ansible **against** Server-225

From your **Mac** (mac-dev), with the repo cloned and inventory/host_vars in place (or synced from Server-225):

```bash
cd /path/to/dotfile-vnext

# Bootstrap Windows (WinRM/OpenSSH): features, dirs, GPU check
ansible-playbook playbooks/boostrap_windows_ssh_via_winrm.yaml -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02

# Deploy capabilities via native playbooks (prefer over fz)
ansible-playbook playbooks/site.yaml -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02
```

Use SSH aliases from [connection-surfaces.md](docs/reference/connection-surfaces.md) (`hom-lab-ctl-hvh-02` → `192.168.50.158`). Optional desktop WSL: [desktop-wsl-optional.md](docs/reference/desktop-wsl-optional.md) only.

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

`ansible-playbook playbooks/bootstrap_execution_node.yaml -i inventory/inventory.yaml --limit mac-dev` ensures the Ansible SSH key at **`~/.ssh/id_ed25519_ansible`**. Windows bootstrap playbooks read the public key from the execution node at run time. Deploy with focused playbooks under `playbooks/` (see [docs/ansible/native-ansible-first.md](docs/ansible/native-ansible-first.md)).

For focused local Ansible toolchain convergence on the Mac, prefer:

```bash
.venv/bin/ansible-playbook playbooks/mac/ansible_dev_tools.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

instead of `./bin/fz role-local ansible_dev_tools`.

For focused local MCP server convergence on the Mac, prefer:

```bash
.venv/bin/ansible-playbook playbooks/mac/mcp_servers.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

## Quick Start

See `docs/architecture_rules.md` for governance and checkpoint rules.
See `AGENTS.md` for durable repo-specific Codex guidance.
See `docs/codex_framework/README.md` for the Codex framework capability used inside this repo.
See `docs/codex_framework/partner_process.md` for the human + AI working process used to keep research, idempotency, verification, and rollback explicit.
See `docs/tool_access/README.md` for the tool-access map across shell, IDE, MCP servers, and agents.
See `docs/ansible/quality-gate.md` for the repo-native Ansible lint + syntax gate and hook setup notes.

## Deploy Shell Configuration

Deploy direnv, cursor editor, and shell aliases independently of bootstrap:

```bash
# Deploy to Mac
./bin/run-playbook.sh playbooks/deploy_shell_config.yaml --limit mac-dev

# Deploy shell config to a commissioned host (example: mac-dev)
ansible-playbook playbooks/deploy_shell_config.yaml -i inventory/inventory.yaml --limit mac-dev
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

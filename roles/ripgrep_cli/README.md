# ripgrep_cli

Installs [ripgrep](https://github.com/BurntSushi/ripgrep) so the `rg` binary is
on PATH. Morph WarpGrep (`codebase_search`) needs this for local searches.

The CLI is **`rg`**. There is no `ripgrep` executable.

## Install family

| Platform | Method | Why |
|---|---|---|
| macOS | BurntSushi GitHub release → `~/.local/bin/rg` | Homebrew on macOS 12 tries to source-build Rust/LLVM for current ripgrep |
| Ubuntu | apt package `ripgrep` | Distro package provides `rg` |

## Usage

Morph dependency (preferred when wiring WarpGrep):

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml -i inventory/inventory.yaml \
  --tags morph --limit mac-dev
```

Standalone:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags ripgrep_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `ripgrep_cli_state` | `present` | `present` or `absent` |
| `ripgrep_cli_release_version` | `15.2.0` | GitHub release tag on macOS |
| `ripgrep_cli_install_dir` | `~/.local/bin` | Install directory on macOS |
| `ripgrep_cli_binary` | `rg` | Binary used for verify |
| `ripgrep_cli_apt_package` | `ripgrep` | apt package on Ubuntu |
| `ripgrep_cli_verify` | `true` | Verify after convergence |

## Apply / Verify / Undo / Change class

- **Apply:** `playbooks/mac/mcp_servers.yaml --tags morph` (includes this role) or `deploy_development_nodes.yaml --tags ripgrep_cli --limit mac-dev`
- **Verify:** `~/.local/bin/rg --version` (macOS) or `rg --version` (Ubuntu)
- **Undo:** same playbook with `-e ripgrep_cli_state=absent`
- **Change class:** idempotent controller-local package/binary install

# common/vscode

Installs Visual Studio Code and extensions on macOS and Windows.

## Platforms

- **macOS**: Homebrew cask (`visual-studio-code`)
- **Windows**: Chocolatey (`vscode`)

## What it does

1. Installs VS Code via the platform package manager.
2. Installs extensions via `code --install-extension`.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `vscode_extensions` | `[GitHub.vscode-pull-request-github]` | List of extension IDs to install |

Override in `group_vars` or `host_vars` as needed.

## Usage

Included in `deploy_development_nodes.yaml`. Run with:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev
ansible-playbook playbooks/deploy_development_nodes.yaml --limit server-225-win
```

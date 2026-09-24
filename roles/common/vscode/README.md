# common/vscode

Installs Visual Studio Code and extensions on macOS and Windows.

## Platforms

- **macOS**: Homebrew cask (`visual-studio-code`)
- **Windows**: Chocolatey (`vscode`)

## What it does

1. Installs VS Code via the platform package manager.
2. Installs extensions via `code --install-extension`.
3. On macOS, manages a user LaunchAgent that exports a GUI PATH for VS Code
	extensions, including the Homebrew bin directory.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `vscode_extensions` | `[GitHub.vscode-pull-request-github, Continue.continue, saoudrizwan.claude-dev]` | List of extension IDs to install |
| `vscode_gui_path_entries` | Homebrew, user, and system bin directories | macOS launchd PATH used by VS Code extensions |

Override in `group_vars` or `host_vars` as needed.

Restart VS Code after a GUI PATH update so its existing extension-host process
inherits the new environment.

## Usage

Included in `deploy_development_nodes.yaml`. Run with:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev
ansible-playbook playbooks/deploy_development_nodes.yaml --limit HOM-LAB-HVH-02
```

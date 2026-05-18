# Langfuse CLI

This role installs and manages the Langfuse CLI for tracing, prompting, and evaluation tooling.

## Requirements

- **macOS only** (currently)
- Requires `common/node` role (declared as dependency in `meta/main.yml`)

## Role Variables

### Version Contract

Set in `inventory/group_vars/all.yaml`:

```yaml
langfuse_tooling_version_contract:
  cli: "0.0.10"
```

### Role Defaults

Defined in `defaults/main.yml`:

- `langfuse_cli_version`: Pinned version from version contract
- `langfuse_cli_package_name`: Constructed as `langfuse-cli@<version>`
- `langfuse_cli_state`: `present` or `absent`

## Dependencies

- `common/node` - Provides `node_npm_executable` for global npm installation

## Example Playbook

```yaml
- hosts: development_nodes
  roles:
    - role: langfuse_cli
      tags: [langfuse, langfuse_cli]
```

## Tags

- `langfuse` - Shared tag for both skill and CLI
- `langfuse_cli` - CLI-specific tag

## Usage

```bash
# Install Langfuse CLI
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags langfuse_cli

# Verify installation
langfuse --version

# Uninstall
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags langfuse_cli -e langfuse_cli_state=absent
```

## Notes

- Follows project version pinning pattern (see `.cursor/rules/ansible-coding-standards.mdc`)
- Uses `state: present` with explicit version instead of `state: latest`
- Global npm installation via nvm-managed node

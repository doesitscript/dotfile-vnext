# LiteLLM CLI

Installs and manages the LiteLLM CLI on macOS using `pipx`, matching the repo's
established Python CLI tool pattern (`poetry`, `virtualenv`, etc.).

## Requirements

- macOS only
- `pipx` (installed by the `python` role on mac-dev)

## Role Variables

### Version Contract

Set in `inventory/group_vars/all/litellm_tooling.yml`:

```yaml
litellm_tooling_version_contract:
  cli: "1.83.7"
```

### Role Defaults

Defined in `defaults/main.yml`:

- `litellm_cli_version`: Pinned version from version contract
- `litellm_cli_package_spec`: Package spec passed to `pipx install`
- `litellm_cli_state`: `present` or `absent`
- `litellm_cli_pipx_executable`: pipx command name or path
- `litellm_cli_global_bin_dir`: pipx-published CLI path (`~/.local/bin`)

## Example Playbook

```yaml
- hosts: node_purpose_development
  roles:
    - role: litellm_cli
      when: ansible_system == "Darwin"
      tags: [litellm, litellm_cli]
```

## Tags

- `litellm` - Shared LiteLLM operator tooling tag
- `litellm_cli` - CLI-specific tag

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags litellm_cli

litellm --version

ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags litellm_cli -e litellm_cli_state=absent
```

## Notes

- Uses `pipx install litellm==<version>` instead of `uv add litellm` to avoid a
  slow Homebrew `uv`/LLVM build on mac-dev.
- `pipx` already publishes `litellm` into `~/.local/bin`.
- On Python 3.14 hosts, keep the contract at `1.83.7` unless LiteLLM publishes
  compatible wheels for newer releases.
- Set `litellm_cli_force_reinstall: true` when you need `pipx install --force`.

# common/ansible_dev_tools

Installs Ansible development tooling via pip: `ansible-dev-tools`,
`ansible-navigator`, and `ansible-builder`.

## Dependencies

- `python` role (declared in `meta/main.yml`)

## Variables

| Variable | Default | Description |
|---|---|---|
| `ansible_dev_tools_install` | `true` | Install the `ansible-dev-tools` meta-package |
| `ansible_navigator_install` | `true` | Install `ansible-navigator` |
| `ansible_builder_install` | `true` | Install `ansible-builder` |
| `ansible_dev_tools_pip` | `pip3` | pip executable to use |

## Tags

Each tool has its own tag for selective runs or skips:

- `ansible-dev-tools`
- `ansible-navigator`
- `ansible-builder`

### Examples

```bash
# Install everything
ansible-playbook playbook.yaml --tags ansible-dev-tools,ansible-navigator,ansible-builder

# Skip ansible-builder
ansible-playbook playbook.yaml --skip-tags ansible-builder

# Disable navigator via variable
ansible-playbook playbook.yaml -e ansible_navigator_install=false
```

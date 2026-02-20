# pwsh

Installs PowerShell 7+ (pwsh).

## What it does

| Platform | Method |
|----------|--------|
| macOS | `brew install --cask powershell` via `community.general.homebrew_cask` |
| Ubuntu | Not yet automated (placeholder) |
| Windows | Not yet automated; Windows PowerShell 5.1 is built-in |

## Variables

None currently. Defaults file is scaffolded for future use.

## Example

```bash
ansible-playbook playbooks/dev_tools.yaml -i inventory/inventory.yaml --limit mac-dev --tags pwsh
```

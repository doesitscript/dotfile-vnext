# terraform_cli

Installs and manages the Terraform CLI on macOS through Homebrew.

Homebrew core no longer publishes the `terraform` formula. This role adds the
official `hashicorp/tap` tap and manages `hashicorp/tap/terraform`. Removing
Terraform leaves the shared HashiCorp tap available for other tools.

## State interface

```yaml
terraform_cli_state: present | absent
```

## Variables

```yaml
terraform_cli_state: present
terraform_cli_homebrew_tap: hashicorp/tap
terraform_cli_homebrew_formula: hashicorp/tap/terraform
terraform_cli_verify: true
```

## Operations

- Apply: `ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags terraform_cli`
- Verify: the role runs `terraform version` after installation.
- Undo: set `terraform_cli_state: absent` and rerun the same playbook command.
- Change class: idempotent configuration.

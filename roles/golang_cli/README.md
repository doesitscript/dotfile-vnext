# golang_cli

Installs and manages the Go toolchain on macOS through Homebrew.

Terratest (Gruntwork) requires Go **>= 1.26** per current docs. This role
enforces `golang_cli_min_version` after install.

## State interface

```yaml
golang_cli_state: present | absent
```

## Variables

```yaml
golang_cli_state: present
golang_cli_homebrew_formula: go
golang_cli_verify: true
golang_cli_min_version: "1.26"
```

## Operations

- Apply: include in a playbook with `--tags golang` / `golang_cli`
- Verify: `go version`
- Undo: `golang_cli_state: absent`
- Change class: idempotent configuration

## Related

- `terraform_cli` — Terraform binary Terratest drives
- `terratest_quickstart` — Hello-World scaffold + `go mod` deps

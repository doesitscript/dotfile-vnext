# netcat_cli

Installs GNU netcat on macOS through the Homebrew `netcat` formula so the
`nc` binary is available from Homebrew-managed tooling on `mac-dev`.

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags netcat_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `netcat_cli_state` | `present` | `present` or `absent` |
| `netcat_cli_homebrew_formula` | `netcat` | Homebrew formula to manage |
| `netcat_cli_verify` | `true` | Verify requested formula state after convergence |

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags netcat_cli --limit mac-dev`
- **Verify:** `brew list --formula netcat`
- **Undo:** same playbook with `-e netcat_cli_state=absent`
- **Change class:** idempotent controller-local package install

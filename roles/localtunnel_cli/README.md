# localtunnel_cli

Installs localtunnel on macOS through the Homebrew `localtunnel` formula so the
`lt` binary is available on `mac-dev`.

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags localtunnel_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `localtunnel_cli_state` | `present` | `present` or `absent` |
| `localtunnel_cli_homebrew_formula` | `localtunnel` | Homebrew formula to manage |
| `localtunnel_cli_verify` | `true` | Verify requested formula state after convergence |

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags localtunnel_cli --limit mac-dev`
- **Verify:** `brew list --formula localtunnel` and `lt --help`
- **Undo:** same playbook with `-e localtunnel_cli_state=absent`
- **Change class:** idempotent controller-local package install

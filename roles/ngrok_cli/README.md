# ngrok_cli

Installs ngrok on macOS through the Homebrew `ngrok` cask so the `ngrok`
binary is available on `mac-dev`.

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags ngrok_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `ngrok_cli_state` | `present` | `present` or `absent` |
| `ngrok_cli_homebrew_cask` | `ngrok` | Homebrew cask to manage |
| `ngrok_cli_verify` | `true` | Verify requested cask state after convergence |

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags ngrok_cli --limit mac-dev`
- **Verify:** `brew list --cask ngrok` and `ngrok version`
- **Undo:** same playbook with `-e ngrok_cli_state=absent`
- **Change class:** idempotent controller-local package install

# aws_cli

Installs AWS CLI v2 on macOS using the official `.pkg` installer from AWS.

Install locations (AWS default):

- install root: `/usr/local/aws-cli`
- binary: `/usr/local/bin/aws`

`/usr/local/bin` is already on the normal macOS and Cursor agent PATH.

Homebrew `awscli` was avoided because it currently fails on this macOS 12 host during dependency builds (`sqlite` / `formula_opt_lib` errors).

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml --tags aws_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_cli_state` | `present` | `present` or `absent` |
| `aws_cli_installer_url` | official AWS pkg | Installer download URL |
| `aws_cli_binary_path` | `/usr/local/bin/aws` | Expected binary path |
| `aws_cli_install_root` | `/usr/local/aws-cli` | Install root removed on absent |
| `aws_cli_verify` | `true` | Run post-convergence checks |

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml` with tag `aws_cli` (uses `become` for pkg install on mac-dev)
- **Verify:** `aws --version`
- **Undo:** same playbook with `-e aws_cli_state=absent`
- **Change class:** idempotent system pkg install

`~/.aws/config` and SSO profiles remain operator-managed.

Legacy note: the old `dotfiles` repo had `roles/awscli` with config templating. vnext only installs the CLI binary.

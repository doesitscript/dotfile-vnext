# Related Artifacts

Repo-owned shell surfaces:

- `inventory/host_vars/mac-dev.yaml`
- `roles/common/shell_config`
- `roles/common/bash_completion`
- `playbooks/deploy_development_nodes.yaml`
- `playbooks/deploy_k8s_cli_tools.yaml`

Common live checks:

- `echo "$SHELL"`
- `command -v bash`
- `bash --version | head -n 1`
- `grep -n '/usr/local/bin/bash' /etc/shells`
- `test -f ~/.bashrc.d/bash_completion.bash`

Managed helper:

- `bin/codex-env python skills/validation/macos-shell-truth-and-alignment/scripts/collect_shell_truth.py`

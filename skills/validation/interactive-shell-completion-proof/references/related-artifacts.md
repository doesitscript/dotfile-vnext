# Related Artifacts

Common shell-truth checks:

- `echo "$SHELL"`
- `echo "$0"`
- `command -v bash`
- `bash --version | head -n 1`
- `shopt -q progcomp && echo progcomp:on || echo progcomp:off`

Managed completion surfaces:

- `roles/common/bash_completion`
- `roles/common/shell_config`
- `/usr/local/etc/bash_completion`
- `/usr/local/etc/bash_completion.d`

Managed probe command:

- `bin/codex-env python skills/validation/interactive-shell-completion-proof/scripts/probe_completion_pty.py --probe-text 'stern ' --expect pod/ --expect deployment/`
- `bin/codex-env python skills/validation/interactive-shell-completion-proof/scripts/probe_completion_pty.py --probe-text 'gonzo ' --forbid '_get_comp_words_by_ref: command not found'`

Notes:

- Double-Tab completion listings outrank synthetic function invocations.
- `compopt: not currently executing completion function` during a direct function call is a debugging artifact, not interactive-shell proof.

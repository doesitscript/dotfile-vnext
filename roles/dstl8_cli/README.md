# dstl8_cli

Installs Dstl8 on macOS through the upstream Homebrew tap and renders a managed
usage note on `mac-dev` so operators and AI agents have a durable,
repo-owned Dstl8 reference on the machine.

Upstream sources:

- GitHub: <https://github.com/control-theory/dstl8>
- Docs: <https://docs.controltheory.com/controltheory-documentation/dstl8-docs>
- Homebrew tap: <https://github.com/control-theory/homebrew-dstl8>

Dstl8 is a terminal-native runtime feedback CLI and TUI that can distill,
detect, correlate, and explain incidents across Kubernetes, AWS, Vercel,
Supabase, OpenTelemetry, and other sources. It also installs an MCP server into
AI coding tools such as Codex, Claude Code, and Cursor, which makes it a strong
fit for the repo's macOS development-controller surface.

This role intentionally uses Homebrew because the upstream README on July 23,
2026 lists `brew install control-theory/dstl8/dstl8` as the primary install
path, and the dedicated tap publishes pinned macOS arm64 and amd64 formula
assets.

The role manages the required Homebrew tap first:

- Tap: `control-theory/dstl8`
- Formula: `dstl8`

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags dstl8_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `dstl8_cli_state` | `present` | `present` or `absent` |
| `dstl8_cli_homebrew_tap` | `control-theory/dstl8` | Homebrew tap required before formula management |
| `dstl8_cli_homebrew_formula` | `dstl8` | Homebrew formula to manage after the tap exists |
| `dstl8_cli_verify_formula_name` | `dstl8` | Bare formula name used for verification commands |
| `dstl8_cli_verify` | `true` | Verify requested formula state after convergence |
| `dstl8_cli_install_bash_completion` | `true` | Install the managed Dstl8 bash completion file |
| `dstl8_cli_bash_completion_path` | `$(brew --prefix)/etc/bash_completion.d/dstl8` | Managed Dstl8 bash completion path |
| `dstl8_cli_install_usage_note` | `true` | Install the managed Dstl8 AI/operator usage note |
| `dstl8_cli_usage_note_path` | `~/.config/dotfile-vnext/ai/tool-guides/dstl8.md` | Managed Dstl8 usage note path |

## Discoverability Metadata

The role includes explicit metadata in `meta/main.yml` to make its purpose easy
to find and classify:

- `description` calls out runtime feedback, terminal UI, and MCP integration
- `platforms` narrows the current supported target to macOS
- `galaxy_tags` index the role under `dstl8`, `observability`, `terminal`,
  `ai`, `mcp`, `homebrew`, and `kubernetes`

This complements `meta/argument_specs.yml`, which documents the role's
lifecycle interface and usage-note options.

## Installed Guidance

When `dstl8_cli_install_usage_note: true`, the role writes a managed Dstl8
usage note to:

```text
~/.config/dotfile-vnext/ai/tool-guides/dstl8.md
```

That note includes:

- quick-start install, setup, and verification commands
- MCP install paths for Codex and Cursor
- data-source onboarding examples for Kubernetes and CloudWatch
- TUI and log-query examples
- repo-managed bash completion path and reload guidance
- repo-local context for how Dstl8 complements Gonzo and Stern on `mac-dev`

## Shell Completion

When `dstl8_cli_install_bash_completion: true`, the role generates:

```text
$(brew --prefix)/etc/bash_completion.d/dstl8
```

The shared `common/bash_completion` role loads Homebrew's
`bash-completion` profile script from `~/.bashrc.d/bash_completion.bash`, so
new Bash sessions pick up the Dstl8 completion automatically after:

```bash
source ~/.bashrc
```

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags dstl8_cli --limit mac-dev`
- **Verify:** `brew list --formula dstl8`, `dstl8 version`, `test -f "$(brew --prefix)/etc/bash_completion.d/dstl8"`, and `test -f ~/.config/dotfile-vnext/ai/tool-guides/dstl8.md`
- **Undo:** same playbook with `-e dstl8_cli_state=absent` (removes the formula and usage note; leaves the tap in place)
- **Change class:** idempotent controller-local package install

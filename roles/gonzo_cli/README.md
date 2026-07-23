# gonzo_cli

Installs Gonzo on macOS from the pinned upstream release binary and renders a
managed usage note on `mac-dev` so operators and AI agents have a durable,
repo-owned Gonzo reference on the machine.

Upstream sources:

- GitHub: <https://github.com/control-theory/gonzo>
- Docs: <https://docs.controltheory.com/controltheory-documentation/gonzo-docs>
- Stern guide: <https://github.com/control-theory/gonzo/blob/main/guides/STERN_USAGE_GUIDE.md>

Gonzo is an interactive, terminal-native AI log companion with native AI
integration across OpenAI, Claude Code, Ollama, LM Studio, and compatible
OpenAI-style endpoints. It fits the repo's development-controller surface well
because it can analyze files, stdin pipelines, and Kubernetes log streams from
the same CLI while keeping the AI workflow local to the terminal session.

The role intentionally avoids Homebrew on this macOS 12 controller because the
formula path can trigger long source builds through Go and CMake dependencies.
Instead, it installs the pinned upstream release archive directly into
`~/.local/bin/gonzo`.

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags gonzo_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `gonzo_cli_state` | `present` | `present` or `absent` |
| `gonzo_cli_release_version` | `0.4.3` | Pinned upstream Gonzo release version |
| `gonzo_cli_archive_url` | release asset URL | Pinned macOS release archive URL |
| `gonzo_cli_archive_checksum` | release SHA-256 | Pinned macOS release archive checksum |
| `gonzo_cli_binary_path` | `~/.local/bin/gonzo` | Installed Gonzo binary path |
| `gonzo_cli_verify` | `true` | Verify requested binary state after convergence |
| `gonzo_cli_install_bash_completion` | `true` | Install the managed Gonzo bash completion file |
| `gonzo_cli_bash_completion_path` | `$(brew --prefix)/etc/bash_completion.d/gonzo` | Managed Gonzo bash completion path |
| `gonzo_cli_install_usage_note` | `true` | Install the managed Gonzo AI/operator usage note |
| `gonzo_cli_usage_note_path` | `~/.config/dotfile-vnext/ai/tool-guides/gonzo.md` | Managed Gonzo usage note path |

## Discoverability Metadata

The role includes explicit metadata in `meta/main.yml` to make its purpose easy
to find and classify:

- `description` calls out controller-local, AI-native log analysis
- `platforms` narrows the current supported target to macOS
- `galaxy_tags` index the role under `gonzo`, `logging`, `observability`,
  `terminal`, `kubernetes`, `ai`, and `binary`

This follows current Ansible role metadata guidance and complements
`meta/argument_specs.yml`, which documents the role's lifecycle interface and
usage-note options.

## Installed Guidance

When `gonzo_cli_install_usage_note: true`, the role writes a managed Gonzo
usage note to:

```text
~/.config/dotfile-vnext/ai/tool-guides/gonzo.md
```

That note includes:

- quick-start file, stdin, and Kubernetes examples
- AI provider context for OpenAI, Ollama, and Claude Code
- repo-managed bash completion path and reload guidance
- repo-local context for using Stern with Gonzo
- upstream URLs for GitHub, docs, and the Stern guide

## Shell Completion

When `gonzo_cli_install_bash_completion: true`, the role generates:

```text
$(brew --prefix)/etc/bash_completion.d/gonzo
```

The shared `common/bash_completion` role loads Homebrew's
`bash-completion` profile script from `~/.bashrc.d/bash_completion.bash`, so
new Bash sessions pick up the Gonzo completion automatically after:

```bash
source ~/.bashrc
```

## Stern Context

Gonzo's upstream Stern guide recommends streaming Stern output as JSON so Gonzo
can preserve richer attributes during analysis:

```bash
stern . --all-namespaces --output json | gonzo
stern . -n kube-system --output json | gonzo
stern "api-*" -n production --output json | gonzo
```

The managed usage note includes that context so the repo's existing `stern_cli`
surface and the new `gonzo_cli` surface work together cleanly.

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags gonzo_cli --limit mac-dev`
- **Verify:** `~/.local/bin/gonzo version`, `test -f "$(brew --prefix)/etc/bash_completion.d/gonzo"`, and `test -f ~/.config/dotfile-vnext/ai/tool-guides/gonzo.md`
- **Undo:** same playbook with `-e gonzo_cli_state=absent`
- **Change class:** idempotent controller-local binary install

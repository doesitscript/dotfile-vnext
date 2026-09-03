# multiagents

Installs the [zetbrush/multiagents](https://github.com/zetbrush/multiagents)
CLI scaffold on macOS:

1. Pinned **Bun** runtime from the [oven-sh/bun](https://github.com/oven-sh/bun)
   GitHub release (not Homebrew — brew source-builds on older macOS)
2. Pinned global `multiagents` package via `bun install -g`
3. Managed layout under `~/.config/dotfile-vnext/multiagents/` for later
   multi-client / multi-scenario config

This role does **not** run `multiagents setup`, start the broker, or write MCP
configs for Codex/Cursor/Claude/Gemini. Those are deferred.

Related plan intake:
`docs/plans/2026-09-03--multi-agent-orchestration-plan/`.

## Settings ownership (do not scatter)

| Concern | Authority | Path |
| --- | --- | --- |
| Lifecycle on/off | host_vars (commission) | `inventory/host_vars/<host>.yaml` → `multiagents_state` |
| Package + Bun versions | group_vars version contract | `inventory/group_vars/all/multiagents_tooling.yml` |
| Role defaults / layout knobs | role defaults | `roles/multiagents/defaults/main.yml` |
| Argument contract | role meta | `roles/multiagents/meta/argument_specs.yml` |
| Playbook entry / tag | compose playbook | `playbooks/deploy_development_nodes.yaml` `--tags multiagents` |
| Host usage note (rendered) | role template → host | `~/.config/dotfile-vnext/ai/tool-guides/multiagents.md` |
| Layout README (rendered) | role template → host | `~/.config/dotfile-vnext/multiagents/README.md` |
| PATH | role file → bashrc.d | `~/.bashrc.d/multiagents-path.bash` |

**Scale-out rule:** enable another Mac with `multiagents_state: present` in that
host's `host_vars`. Bump shared pins only in the version contract. Put future
Codex/Cursor/scenario packs under `multiagents_scenarios_dir` (or a redesigned
layout via role defaults) — do not invent one-off install scripts.

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags multiagents --limit mac-dev` |
| **Verify** | Role asserts Bun binary, `multiagents help`, and managed layout paths |
| **Undo** | `-e multiagents_state=absent` (Bun kept by default) |
| **Change class** | Idempotent config (release binary + package + directories) |

## PATH note

Bun and `multiagents` install under `~/.bun/bin`. The role drops
`~/.bashrc.d/multiagents-path.bash` so interactive bash picks that up after
`source ~/.bashrc` (or a new shell).

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `multiagents_state` | `absent` | `present` or `absent` (commission in host_vars) |
| `multiagents_version` | from version contract | Pinned multiagents package version |
| `multiagents_bun_release_version` | from version contract | Pinned Bun release (without `bun-v` prefix) |
| `multiagents_bun_use_baseline` | true on Intel | Use `bun-darwin-x64-baseline.zip` on x86_64 |
| `multiagents_bun_install_dir` | `~/.bun/bin` | Managed Bun / multiagents bin dir |
| `multiagents_root_dir` | `~/.config/dotfile-vnext/multiagents` | Managed scaffold root (layout may change) |
| `multiagents_scenarios_dir` | `…/scenarios` | Placeholder for future scenario packs |
| `multiagents_install_usage_note` | `true` | Render AI/operator usage note |
| `multiagents_install_path_snippet` | `true` | Install `~/.bashrc.d/multiagents-path.bash` |
| `multiagents_verify` | `true` | Post-apply verification |

Version contract (`inventory/group_vars/all/multiagents_tooling.yml`):

```yaml
multiagents_tooling_version_contract:
  cli: "0.5.0"
  bun: "1.4.0"
```

> Prefer `inventory/group_vars/all/*.yml` for new contracts. The `all/` directory
> shadows `inventory/group_vars/all.yaml`.

## Layout note

The managed tree under `multiagents_root_dir` is a scaffold, not a frozen
contract. If Codex/Cursor/multi-scenario configuration needs a different
layout, update role defaults and re-apply.

## Example

```yaml
# inventory/host_vars/mac-dev.yaml
multiagents_state: present
```

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags multiagents --limit mac-dev
```

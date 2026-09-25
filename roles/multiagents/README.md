# multiagents

Installs the [zetbrush/multiagents](https://github.com/zetbrush/multiagents)
CLI scaffold on macOS:

1. Pinned **Bun** runtime from the [oven-sh/bun](https://github.com/oven-sh/bun)
   GitHub release (not Homebrew — brew source-builds on older macOS)
2. Pinned global `multiagents` package via `bun install -g`
3. Managed layout under `~/.config/dotfile-vnext/multiagents/` for later
   multi-client / multi-scenario config
4. Supported child-agent CLIs (`codex`, `claude`, and `gemini`) when
   `multiagents_agent_cli_enabled: true`, including their binary directory in
   the orchestrator MCP `PATH`

The role also converges the pinned package's Codex child prompt so peer MCP
communication is mandatory before child work. This prevents a child from
writing artifacts while remaining invisible in the dashboard.

This role does **not** run `multiagents setup` or start the broker. Those
remain separate lifecycle actions. When `multiagents_state: present`, the role
registers the parent `multiagents-orch` MCP entry in project and user Codex
config with `enabled = false`. Cursor and Continue receive the same disabled
orchestrator catalog entry from their owning roles. The `multiagents-peer` MCP
remains the separate spawned-agent communication surface.

## Plan-scoped transcripts

The parent orchestrator accepts the paired plan folder as `create_team`'s
`transcript_dir`. When the parent ends a session, the broker SQLite database at
`~/.multiagents/peers.db` remains the runtime source of truth while the session
message history is exported automatically to:

```text
<plan-folder>/.multiagents/transcripts/<session-id>/session-transcript.md
<plan-folder>/.multiagents/transcripts/<session-id>/implementer.md
<plan-folder>/.multiagents/transcripts/<session-id>/evaluator.md
<plan-folder>/MULTIAGENT-TRANSCRIPT-INDEX.md
```

The per-run directory is safe for future agent roles: each slot receives a
sanitized role-based Markdown filename, and the plan index links every run.
This export is the broker message/session transcript, not a raw model-token or
tool-call capture. The evaluator's `MULTIAGENT-FINAL-REPORT.md` should link the
index and summarize the completed work.

### Follow-up note

Future work can investigate raw child app-server/tool transcripts, restart-safe
transcript target persistence, and retention/redaction policy. Those are
separate from the current broker-backed plan export and should not replace it.

Related plan intake:
`docs/plans/2026-09-03--multi-agent-orchestration-plan/`.

## Settings ownership (do not scatter)

| Concern | Authority | Path |
| --- | --- | --- |
| Lifecycle on/off | host_vars (commission) | `inventory/host_vars/<host>.yaml` → `multiagents_state` |
| Codex parent activation | host_vars | `multiagents_orchestrator_enabled` (default `false`) |
| Spawned-agent peer activation | parent runtime | Injected per child; no persistent client flag |
| Package + Bun versions | group_vars version contract | `inventory/group_vars/all/multiagents_tooling.yml` |
| Role defaults / layout knobs | role defaults | `roles/multiagents/defaults/main.yml` |
| Argument contract | role meta | `roles/multiagents/meta/argument_specs.yml` |
| Playbook entry / tag | compose playbook | `playbooks/deploy_development_nodes.yaml` `--tags multiagents_stack` for the complete macOS bundle; `--tags multiagents` for the package role only |
| Child-agent CLI group | host_vars + role | `multiagents_agent_cli_enabled`, package/command map, and `multiagents_agent_cli_bin_dir` |
| MCP child-process PATH | role/client MCP entries | `multiagents_agent_cli_path` propagated to Codex/Cursor; Continue host entry includes the same directory |
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
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags multiagents_stack --limit mac-dev` |
| **Verify** | Role asserts Bun binary, `multiagents help`, child CLI executables, managed layout paths, and the disabled parent orchestrator MCP block; verify MCP-process PATH separately |
| **Undo** | `-e multiagents_state=absent` (Bun kept by default) |
| **Change class** | Idempotent config (release binary + package + directories) |

## PATH note

Bun and `multiagents` install under `~/.bun/bin`. The role drops
`~/.bashrc.d/multiagents-path.bash` so interactive bash picks that up after
`source ~/.bashrc` (or a new shell).

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `multiagents_state` | `absent` | `present` or `absent` (commission package in host_vars) |
| `multiagents_agent_cli_enabled` | `false` | Install and verify the supported child-agent CLI group |
| `multiagents_agent_cli_packages` | Codex, Claude, Gemini package/command map | Child-agent packages and executable names required by `create_team` |
| `multiagents_agent_cli_bin_dir` | empty; falls back to `/usr/local/bin` | Global npm binary directory exposed to the MCP process |
| `multiagents_agent_cli_path` | Bun + child CLI bin + system paths | PATH passed to the parent orchestrator MCP process |
| `multiagents_orchestrator_enabled` | `false` | Keep the deployed `multiagents-orch` MCP entry disabled by default |
| `multiagents_stack` | playbook tag | Converges the package, child CLI group, Codex/Cursor/Continue MCP catalog entries, and PATH contract together |
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

The broker and dashboard are runtime-owned by the installed orchestrator:
`create_team` ensures the broker on demand and the package launches dashboard
surfaces for a created session. They are not separate persistent MCP servers or
host services that this deployment role should start by default.

## Follow-up: Cursor Agent usage

The multiagents CLI-backed Implementer/Evaluator path is deployed. Use the
client’s **one** parent `multiagents-orch` MCP for many sessions. Skills proceed
when that live MCP namespace is callable, even if a client config file still
shows disabled. Ansible reconcile owns the file `disabled` / `*_active` flags
(`cursor_multiagents_orchestrator_mcp_active` on macOS Cursor) and is a
separate operator action from interactive chats.

Do not reintroduce `multiagents-peer` as a persistent parent-client MCP entry.
Peer injection remains child-session scoped. Close out **this** session with
`release_all` → `end_session` so its agent/peer children stop. Keep the shared
orch, broker, and dashboard available for other multiagent tenants unless the
operator stops the dashboard or Ansible reconciles MCP desired state. See
global skills `multiagents-runtime-operator` and
`paired-plan-multiagents-orchestrator`.

## Example

```yaml
# inventory/host_vars/mac-dev.yaml
multiagents_state: present
```

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags multiagents --limit mac-dev
```

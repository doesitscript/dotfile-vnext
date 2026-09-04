# Porting checklist (condensed from HRL)

Authority when HRL is available:
`homelab-reference-library/implementation-guides/mcp/porting-mcp-servers-between-projects.md`

| Step | Action |
| --- | --- |
| 1 | Add role to `export-manifest.yml` |
| 2 | Add playbook role + tags |
| 3 | `*_state: absent` in host_vars |
| 4 | Override **codex** path to **user home** `~/.codex/config.toml` | Packet root ≠ client config home; covers CLI + Codex extension |
| 5 | Override env dir to `~/.config/work-laptop-ai-tools/mcp/env.d/` |
| 6 | Override wrapper + vault paths to packet `bin/` + `vault/shared.vault.yml` |
| 7 | Prefer `*_targets: [codex]` on this slice — **not** `vscode` | Continue/Cline are separate lists; VS Code native MCP is out of scope |
| 8 | Do not auto-edit Continue/Cline/Zed lists | Commission + ide-clients skills when asked |
| 9 | Gate non-stateful roles with playbook `when:` | e.g. sysoperator/redhat |
| 9a | Still export every `meta/dependencies` role | Ansible resolves deps at parse time — `when:` does not skip missing `common/supergateway` |
| 10 | Export wrappers (`mcp-server-env-wrapper`, drawio stdio if needed) |
| 11 | Vault example only in git |
| 12 | Morph → also note `ripgrep_cli` |
| 13 | Continue GUI: `bin/work-laptop-nvm-exec` | VS Code PATH lacks nvm |
| 14 | Morph Continue: env wrapper + WORKSPACE_MODE; rule under `~/.continue/rules/` | Duplicate rules if also in continue_ide_rules |
| 15 | Codex extension = user `~/.codex/config.toml` | Same file as CLI `mcp list` |
| 16 | Cline MCP: mirror Continue via `cline_ide_mcp_servers` | Cline ignores `*_targets` |
| 17 | LiteLLM key for Continue/Cline present | `vault_k3s_litellm_gateway_master_key`; empty UI if missing |
| 18 | Continue apiBase omits `/v1`; Cline/Zed include `/v1` | See `work-laptop-ide-clients` |
| 19 | Work-laptop `cx-*` roots under `~/Documents/develop/` | Not `~/develop/dotfile-vnext` |

Packet helper vars (already in host_vars):

- `work_laptop_mcp_env_dir`
- `work_laptop_mcp_vault_file`
- `work_laptop_mcp_codex_config_path`
- `codex_homelab_profiles_repo_primary` / `_skills` / `_research`

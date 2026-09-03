# Porting checklist (condensed from HRL)

Authority when HRL is available:
`homelab-reference-library/implementation-guides/mcp/porting-mcp-servers-between-projects.md`

| Step | Action |
| --- | --- |
| 1 | Add role to `export-manifest.yml` |
| 2 | Add playbook role + tags |
| 3 | `*_state: absent` in host_vars |
| 4 | Override vscode/codex paths to **user home** |
| 5 | Override env dir to `~/.config/work-laptop-ai-tools/mcp/env.d/` |
| 6 | Override wrapper + vault paths to packet `bin/` + `vault/shared.vault.yml` |
| 7 | Honor `*_supported_targets` (codex-only when vscode unsupported) |
| 8 | Do not auto-edit Continue/Zed lists | Commission skill does this when asked |
| 13 | Continue GUI: `bin/work-laptop-nvm-exec` | VS Code PATH lacks nvm |
| 14 | Morph Continue: env wrapper + WORKSPACE_MODE; rule under `~/.continue/rules/` | Duplicate rules if also in continue_ide_rules |
| 15 | Codex extension = user `~/.codex/config.toml` | Same file as CLI `mcp list` |
| 9 | Gate non-stateful roles with playbook `when:` |
| 10 | Export wrappers (`mcp-server-env-wrapper`, drawio stdio if needed) |
| 11 | Vault example only in git |
| 12 | Morph → also note `ripgrep_cli` |

Packet helper vars (already in host_vars):

- `work_laptop_mcp_env_dir`
- `work_laptop_mcp_vault_file`
- `work_laptop_mcp_vscode_config_path`
- `work_laptop_mcp_codex_config_path`

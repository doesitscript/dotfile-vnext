---
name: work-laptop-ide-clients
description: "Use when commissioning or fixing Continue, Cline, Zed, or cx-* multi-terminal wrappers on the work-laptop-ai-tools packet: LiteLLM key gates, /v1 base URL differences, MCP list mirrors, Documents/develop repo roots. Do not use for Codex MCP targets alone (work-laptop-mcp-commission) or laptop playbook apply (work-laptop-day2-apply)."
---

# Skill: Work-laptop IDE clients

Manage **editor/agent client configs** for this slice (not VS Code native MCP).

| Client | Config surface | Role / vars |
| --- | --- | --- |
| Continue | `~/.continue/config.yaml` | `continue_ide_*` |
| Cline | `~/.cline/data/settings/providers.json` (+ MCP) | `cline_ide_*` |
| Zed | `~/.config/zed/settings.json` | `zed_ide_*` |
| `cx-*` wrappers | `~/.bashrc.d/codex-multi-terminal.bash` | `codex_homelab_profiles_repo_*` |
| Extensions | VS Code marketplace IDs | `vscode_extensions` |

## When to use / not use

Use when:

- Continue or Cline UI looks empty / unconfigured
- adding Cline (or changing Continue models/MCP lists)
- fixing `cx-desktop` wrong `cd` path on the work laptop
- documenting LiteLLM key / base URL differences

Do not use when:

- only flipping MCP `*_state` for Codex (`work-laptop-mcp-commission`)
- running the laptop playbook (`work-laptop-day2-apply`)
- VS Code native `~/.vscode/mcp.json` (out of scope unless user insists)

## Hard rules (this slice)

1. **Edit the parent packet**, then `work-laptop-packet-ops` sync — not sibling-only.
2. Continue `apiBase` = `http://litellm.hom.lab` (**no** `/v1`).
3. Cline / Zed OpenAI-compatible URL = `http://litellm.hom.lab/v1` (**with** `/v1`).
4. `continue_ide_require_api_key` / `cline_ide_require_api_key` default **true**.
   Present runs fail on `REPLACE_WITH_LITELLM_KEY` — hydrate
   `vault_k3s_litellm_gateway_master_key` via `work-laptop-vault`.
5. Cline MCP should mirror Continue: `cline_ide_mcp_servers: "{{ continue_ide_mcp_servers }}"`
   unless the user wants a deliberate split.
6. Extensions: keep `Continue.continue` and `saoudrizwan.claude-dev` in
   `vscode_extensions` when those clients are commissioned.
7. Work-laptop `cx-*` roots default to `~/Documents/develop/...`, not
   `~/develop/dotfile-vnext`.
8. Before inventing path/URL/npm workarounds, read `deviations/register.yaml`
   (behavior groups `repo-layout-paths`, `npm-global-install`, `litellm-client-keys`).
   New laptop-driven fixes → `work-laptop-improvement-review` intake.

## Workflow — Continue empty UI

1. Confirm vault key present (names only): `work-laptop-vault-status`.
2. Ensure packet has `continue_ide_state: present`, models list, vault path.
3. Sync + push; on laptop run `work-laptop-day2-apply`.
4. Verify `~/.continue/config.yaml` has `models:` and non-placeholder `apiKey`.
5. Reload VS Code / Continue panel.

## Workflow — Commission or refresh Cline

1. Packet `host_vars/work-laptop.yaml`:
   - `cline_ide_state: present`
   - `cline_ide_gateway_api_base: "http://litellm.hom.lab/v1"`
   - `cline_ide_model` (LiteLLM `model@host`)
   - `cline_ide_mcp_servers: "{{ continue_ide_mcp_servers }}"`
   - `saoudrizwan.claude-dev` in `vscode_extensions`
2. Ensure `roles/cline_ide` is on `export-manifest.yml` and `playbook.yaml`.
3. `work-laptop-packet-ops` → push → `work-laptop-day2-apply`.
4. Verify `~/.cline/data/settings/providers.json` `lastUsedProvider` /
   `openai-compatible` + `baseUrl`.

## Workflow — Fix `cx-*` paths

Set in packet host_vars (work laptop):

```yaml
codex_homelab_profiles_develop_root: "{{ ansible_env.HOME }}/Documents/develop"
codex_homelab_profiles_repo_primary: "{{ codex_homelab_profiles_develop_root }}/work-laptop-ai-tools"
codex_homelab_profiles_repo_skills: "{{ codex_homelab_profiles_develop_root }}/global-skills"
codex_homelab_profiles_repo_research: "{{ codex_homelab_profiles_develop_root }}/homelab-reference-library"
```

Template: `roles/codex_homelab_profiles/templates/codex-multi-terminal.bash.j2`.
After apply, new shell; `grep _CODEX_MT_REPO_ ~/.bashrc.d/codex-multi-terminal.bash`.

## Validation

- Continue file: models present; key not `REPLACE_WITH_LITELLM_KEY`
- Cline providers.json: `openai-compatible` + `/v1` baseUrl
- `cx-desktop` cds under `Documents/develop` on the work laptop
- Sibling synced after packet edits

## Prohibited behavior

- Shipping placeholder LiteLLM keys as “configured”
- Pointing Continue at `/v1` or Cline at bare host without `/v1` without evidence
- Enabling VS Code native MCP by default
- Hardcoding `~/develop/dotfile-vnext` for work-laptop `cx-*`

## Progressive disclosure

- Day-2 apply: `work-laptop-day2-apply`
- MCP enable: `work-laptop-mcp-commission`
- Vault: `work-laptop-vault`
- Roles: `roles/continue_ide/README.md`, `roles/cline_ide/README.md`

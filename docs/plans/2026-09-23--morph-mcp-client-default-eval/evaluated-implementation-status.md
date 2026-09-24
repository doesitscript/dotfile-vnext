---
title: Morph proper IDE implementation — evaluated items status
plan: 2026-09-23--morph-mcp-client-default-eval
related_plan: 2026-09-02--morph-warpgrep-evaluation
updated_at: "2026-09-23"
source_thread: Morph Layer 2 Cursor/Codex parity (vendor MCP + ai-client-instruction-surface-matrix)
---

# Evaluated implementation items — status table

Items identified when researching Morph’s proper IDE implementation (vendor
MCP Layer 1 access + Layer 2 agent steering) and aligning Cursor + Codex.
Statuses are brief; detail lives in the sibling Morph install plan and this
plan’s README.

Status codes: `done` · `settled-no-change` · `partial` · `pending-operator` · `out-of-scope`

| ID | Item identified | Status | Brief state |
| --- | --- | --- | --- |
| L1-1 | Morph MCP access on Cursor (`cursor_user` → `~/.cursor/mcp.json`, `disabled: false`) | done | Already commissioned; re-verified after Ansible morph apply |
| L1-2 | Morph MCP access on Codex (project + `~/.codex/config.toml`, `enabled = true`) | done | Re-converged; `codex mcp list` shows morph-mcp enabled |
| L1-3 | `WORKSPACE_MODE=true` (vendor workspace-aware global config) | done | Present in Morph MCP env for Cursor and Codex |
| L1-4 | Vault → `morph.env` + env wrapper (no inline API key in tracked config) | done | Unchanged; still the access path |
| L1-5 | Re-apply `mcp_tool_enabled` after Morph mcp.json writes | done | Ran `--tags mcp_enablement` so Morph stays enabled and other servers stay disabled |
| L2-1 | Cursor Morph rule must load every session (`alwaysApply`) | done | Was `false` (habit defect); set `true` on lean `.cursor/rules/morph-warpgrep-evaluation.mdc` via role template |
| L2-2 | Lean vendor-aligned Morph steering prose (WarpGrep / Fast Apply when available / Reflex) | done | Templates `routing_morph-mcp.mdc.j2` + `.md.j2` slimmed and redeployed |
| L2-3 | Shared prose in `AGENTS.md` (Codex primary; Cursor also reads) | done | Ansible managed block refreshed to match Cursor body |
| L2-4 | Codex agent TOMLs (`default` / `explorer` / `worker`) Morph routing block | done | Same lean prose redeployed |
| L2-5 | List Morph rule on context-budget always-on allowlist | done | `framework-context-budget.mdc` + `.cursorrules` updated |
| L2-6 | Cursor/Codex parity via `ai-client-instruction-surface-matrix` (AGENTS shared + `.mdc` adapter) | done | Used as the design rule for this fix; no separate per-IDE snowflake playbook |
| POL-1 | Do **not** conflate Morph `DISABLED_TOOLS` with project `mcp_tool_enabled` | settled-no-change | Clarified; `DISABLED_TOOLS` not required to finish MCP server enable/disable |
| POL-2 | Leave Morph `edit_file` at package default (often off); do not empty `DISABLED_TOOLS` for “all tools on” | settled-no-change | Steering says prefer Fast Apply **when available**; matches cautious eval |
| POL-3 | Continue / Copilot Morph routing blocks | done | Redeployed as part of morph role routing (same prose) |
| OPS-1 | New Cursor Agent chat / reload so always-on Morph rule injects | pending-operator | File on disk is correct; existing long chats may still lack the new rule |
| EVAL-1 | Blind `warpgrep-default` Cursor step-2 receipt | pending-operator | Belonging to this plan’s probe matrix; not a Layer 2 config blocker |
| EVAL-2 | Codex Fast Apply: real apply after dryRun (not dryRun-only) | partial | Still open habit/eval gap from prior probes; Layer 2 prose updated but not re-proven |
| EVAL-3 | Harden Fast Apply scenario clean-slate / workspace pin | partial | Plan checklist still open; skill SSOT writeback pending |
| OUT-1 | Enable every Morph tool via `DISABLED_TOOLS=""` | out-of-scope | Explicitly rejected for this eval; WarpGrep-first is enough |
| OUT-2 | Complex per-client Morph playbooks beyond `roles/mcp_servers/morph` | out-of-scope | Single role + inventory targets remain the path |

## Summary counts

| Status | Count |
| --- | --- |
| done | 12 |
| settled-no-change | 2 |
| partial | 2 |
| pending-operator | 2 |
| out-of-scope | 2 |

## Related apply evidence

- `ansible-playbook playbooks/mac/mcp_servers.yaml --limit mac-dev --tags morph` (2026-09-23)
- Follow-up `--tags mcp_enablement`
- Sibling note: `docs/plans/2026-09-02--morph-warpgrep-evaluation/README.md` § Steering surfaces (2026-09-23 Layer 2 fix)

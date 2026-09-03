---
name: work-laptop-packet-ops
description: "Use when validating, syncing, or smoke-checking the work-laptop-ai-tools export packet and its sibling build-target repo. Delegates to parent skill work-laptop-export-pack scripts when running from dotfile-vnext. Do not use for MCP role design (use mcp-collect/adopt) or vault key authoring (use work-laptop-vault)."
---

# Skill: Work-laptop packet ops

Operational loop for this slice: **validate → sync sibling → optional smoke**.
Heavy scripts live in the parent project skill `work-laptop-export-pack`; this
slice skill scopes when to run them and what “done” means for the packet.

## When to use / not use

Use when:

- after MCP adopt / vault example / packet README changes
- refreshing the sibling `work-laptop-ai-tools` checkout
- verifying export contract before zip (zip only if user asks)

Do not use when:

- designing MCP remaps (use `work-laptop-mcp-adopt`)
- parent-wide skill bridging (`project-skill-runtime-bridge`)

## Why this stays thin (move evaluation)

Parent skill `work-laptop-export-pack` owns Python helpers under
`skills/implementation/work-laptop-export-pack/scripts/` and must run with
`bin/codex-env` from **dotfile-vnext**. Moving those scripts into the sibling
would break the “generate from parent” model. Keep scripts in parent; keep this
slice skill for discovery when working in the packet/sibling.

## Workflow (from parent checkout)

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py
# optional smoke (no --apply unless user asks for live apply on the real laptop):
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --packet-dir /Users/joshc/develop/work-laptop-ai-tools \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

Archive/zip only when the user explicitly requests the archive branch.

## Workflow (from sibling-only session)

1. Treat sibling as **generated**. Prefer editing parent packet then re-sync.
2. If parent is available, run the commands above from parent.
3. If parent is unavailable, you may inspect sibling files but must not invent a
   second authority; note “sync pending from parent.”

## Outputs

- Validate OK
- Sibling sync file counts / state file updated
- Smoke result if requested

## Validation

- Contract script exits 0
- Sibling contains `.agents/skills/` and `AGENTS.md` after sync when those are on the manifest

## Prohibited behavior

- `--apply` without explicit user request for live work-laptop apply
- Claiming sibling is design authority

## Progressive disclosure

- Parent skill: `skills/implementation/work-laptop-export-pack/SKILL.md`
- Packet `export-manifest.yml`, `AGENTS.md`

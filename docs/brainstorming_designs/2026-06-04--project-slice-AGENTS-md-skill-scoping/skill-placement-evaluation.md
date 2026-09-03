---
title: Skill placement evaluation — work-laptop slice
status: draft
retrieved_at: "2026-09-03"
related:
  - research-receipt.md
  - my_guidance.md
---

# Evaluation — move existing skills into the packet?

Question: skills used for this slice that live in global-skills or parent
`skills/` — should they move under `exports/work-laptop-ai-tools/.agents/skills/`?

## Decision summary

| Skill | Current home | Verdict | Why |
| --- | --- | --- | --- |
| `work-laptop-export-pack` | Parent `skills/implementation/` (+ `.cursor/skills` bridge) | **Keep in parent** | Owns generate/sync scripts; must run with parent `bin/codex-env`; authority is “edit packet in parent → push to sibling”. Moving scripts into sibling inverts the model. |
| `work-laptop-packet-ops` | **New** slice `.agents/skills/` | **Slice-local thin skill** | Discoverable in packet/sibling; delegates to parent export-pack scripts. |
| `project-skill-runtime-bridge` | Parent | **Keep in parent** | Bridges *all* project skills to `.cursor/skills`; not slice-scoped. |
| `work-laptop-mcp-collect` | **New** slice | **Slice-local** | MCP collect from parent for this packet only. |
| `work-laptop-mcp-adopt` | **New** slice | **Slice-local** | Adopt + HRL remaps for this packet only. |
| `work-laptop-vault` | **New** slice | **Slice-local** | Packet vault + transfer prep. |
| Global skills (debrief, etc.) | `global-skills` / `~/.cursor/skills` | **Do not move** | Not work-laptop-packet scoped. |
| Paired-agent plan skills | Global / parent | **Do not move** | Optional plan loop against `docs/plans/…`; not packet runtime. |

## Rule of thumb used

- **Move (or create) in slice** when the *primary* operating surface is the
  packet + sibling build target and discovery should stay off the global catalog.
- **Keep in parent** when the skill’s scripts/authority generate the sibling
  from the monorepo, or when the skill serves the whole repo.

## What we did not do

- Did not relocate `work-laptop-export-pack` source or its Python scripts.
- Did not duplicate those scripts into the packet.
- Did not add slice skills to parent `skills/catalog.yaml` / runtime bridge
  (slice discovery is via nested `.agents/skills/` + sibling sync).

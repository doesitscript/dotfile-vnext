---
title: Research — AGENTS.md + slice-local skills for work-laptop-ai-tools
status: draft
retrieved_at: "2026-09-03"
authority: mixed
source_type: research
related:
  - my_guidance.md
  - chatgpt-thoughts.md
---

# Research receipt — project-slice AGENTS.md + skill scoping

## What Josh asked (from `my_guidance.md`)

1. Make `exports/work-laptop-ai-tools` more efficient via nested `AGENTS.md` + skills.
2. Put slice-specific skills next to the slice (not global-skills) — MCP porting, vault/secrets handling, intake processing.
3. **First action:** Context7 + Firecrawl research to verify what actually works before implementing.

## ChatGPT scope (accepted framing)

Separate three concerns:

| Concern | Mechanism |
| --- | --- |
| Instruction scope | Nested `AGENTS.md` |
| Discovery scope | Where Cursor/Codex scan for skills |
| Implementation scope | Where skill files live on disk |

Those directories do not have to match. Bare `skills/` under the export will **not** auto-discover unless it sits on a runtime-known path (or is bridged/registered).

Prefer a small cohesive set (≈3–7 skills), not dozens of micro-skills.

---

## Verified: nested AGENTS.md — YES

### Cursor ([cursor.com/docs/rules](https://cursor.com/docs/rules))

- Supports `AGENTS.md` in project root **and any subdirectory**.
- Nested files combine with parents; more specific instructions take precedence.

### Codex ([developers.openai.com/codex/agent-configuration/agents-md](https://developers.openai.com/codex/agent-configuration/agents-md))

- Walks from project root (git root) **down to cwd**.
- Per directory: `AGENTS.override.md` then `AGENTS.md` (one file per dir).
- Concatenates root→cwd; closer files appear later (override effect).
- Budget: `project_doc_max_bytes` (default 32 KiB) — nest rather than monolith.

**Implication for our slice:**  
`exports/work-laptop-ai-tools/AGENTS.md` is a valid instruction scope when the agent’s cwd / open files are under that tree. Sibling checkout `work-laptop-ai-tools/` should get the same file via export sync.

---

## Verified: skill discovery — NOT bare `skills/`

### Cursor ([cursor.com/docs/skills](https://cursor.com/docs/skills))

Auto-loads from:

| Location | Scope |
| --- | --- |
| `.agents/skills/` | Project |
| `.cursor/skills/` | Project |
| `~/.agents/skills/`, `~/.cursor/skills/` | User/global |
| Also compatibility: `.claude/skills/`, `.codex/skills/` | Project/user |

**Nested monorepo discovery (critical):**

```text
exports/work-laptop-ai-tools/
  .cursor/skills/<skill>/SKILL.md   # or .agents/skills/
```

Cursor docs: a `.cursor/skills/` (or `.agents/skills/`) **anywhere in the repo** is picked up; skills in nested package dirs are **automatically scoped** to that subdirectory (same idea as `paths` frontmatter).

### Codex ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills) / Context7 `/openai/codex`)

Repo skills: scans **`.agents/skills`** on every directory from **cwd up to repo root** (ancestry). Also USER `~/.agents/skills`, ADMIN, SYSTEM.

Context budget warning: initial skill list ≤ ~2% of context (or 8k chars); large catalogs get truncated descriptions — locality matters.

**Implication:** Prefer:

```text
exports/work-laptop-ai-tools/
  AGENTS.md
  .agents/skills/          # Codex-native + Cursor-compatible
    ├── work-laptop-mcp-port/
    ├── work-laptop-vault/
    └── work-laptop-export-ops/   # or keep using repo work-laptop-export-pack
```

Optional dual-path: also `.cursor/skills/` (symlink to same folders) if you want Cursor-first naming; Cursor already reads `.agents/skills/`, so **one tree is enough**.

Bare `exports/work-laptop-ai-tools/skills/` without `.agents` / `.cursor` prefix = **not discovered** by either runtime.

---

## Fit to this repo today

- Authority for packet: `dotfile-vnext/exports/work-laptop-ai-tools/` → sync to sibling via `work-laptop-export-pack`.
- Existing sync skill lives in **repo** `skills/implementation/work-laptop-export-pack` and is bridged into `.cursor/skills/` via `project-skill-runtime-bridge` — repo-wide, not slice-scoped.
- Slice-local skills should be **authored under the export packet**, included in `export-manifest.yml`, and land in the sibling so work-laptop Codex/Cursor sessions discover them without global catalog clutter.
- Durable process knowledge stays in HRL (`implementation-guides/mcp/…`); skills **invoke** that knowledge rather than duplicating it.

---

## Recommended skill set (cohesive, not microscopic)

Aligned with guidance + recent MCP port work:

1. **work-laptop-mcp-port** — bring MCP role into packet: manifest, playbook, host_vars absent defaults, path/vault remaps; point at HRL porting guide.
2. **work-laptop-vault** — create/encrypt `vault/shared.vault.yml`, key names per role, env.d layout, never commit secrets.
3. **work-laptop-packet-ops** (optional merge with export-pack) — validate contract, sync sibling, smoke; or keep calling existing `work-laptop-export-pack` from AGENTS.md.

AGENTS.md in the slice should say: prefer these `.agents/skills/*` when working under this tree; do not use them outside the slice unless asked.

---

## Open decisions (resolved 2026-09-03)

1. **Single discovery root:** `.agents/skills/` only (Cursor loads it too).
2. **`work-laptop-export-pack`:** stays in parent; thin `work-laptop-packet-ops` in slice.
3. **Sibling:** skills + `AGENTS.md` on export-manifest so laptop git root discovers them.
4. **HRL:** living docs remain authority; skills point + carry condensed checklist.

See `skill-placement-evaluation.md` for move/keep table.

---

## Sources checked

| Source | Use |
| --- | --- |
| Context7 `/websites/cursor` | Nested AGENTS.md + nested `.cursor/skills` scoping |
| Context7 `/openai/codex` | AGENTS.md hierarchy + `.agents/skills` ancestry discovery |
| Firecrawl search + scrape | Official Cursor skills, Codex AGENTS.md, Codex build-skills |
| Repo: `project-skill-runtime-bridge`, `work-laptop-export-pack` | Current bridge model is repo-wide, not slice-local |
| HRL MCP porting guides | Content skills should reference |

## # Source Decisions

- Instruction locality via nested `AGENTS.md` is officially supported (Cursor + Codex).
- Skill locality requires **runtime-known dirs** (`.agents/skills` / `.cursor/skills`), not a casual `skills/` folder name.
- ChatGPT’s “discovery ≠ implementation path” caution is correct; recommended fix is colocate under `.agents/skills` inside the export packet and sync to sibling.

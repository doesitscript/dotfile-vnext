---
name: work-laptop-inbox-evaluate-fix
description: "Use when processing work-laptop-ai-tools inbox feedback in implement mode: git pull sibling, classify inbox notes, fix durable items in the source packet (not ad-hoc on the laptop), register deviations, sync/push sibling. Do not use for audit-only reviews (work-laptop-improvement-review) or day-2 playbook apply alone (work-laptop-day2-apply)."
---

# Skill: Work-laptop inbox evaluate-and-fix

**Pull → evaluate `inbox/` → fix in source packet → sync → push.**

This is the implement-mode cycle for inbound laptop notes. Audit-only reviews
stay on `work-laptop-improvement-review`. This skill **does the fixes**.

## Authority (do not invert)

| Layer | Role |
| --- | --- |
| **Source packet** `dotfile-vnext/exports/work-laptop-ai-tools/` | Design authority — edit here |
| Parent roles (e.g. `roles/continue_ide`) | Shared logic when the manifest copies them |
| Sibling `work-laptop-ai-tools` | Generated build target + inbox drop zone |
| `deviations/register.yaml` | Only place unregistered laptop drift may become accepted |

`AGENTS.md` may say prefer **source** when laptop conflicts. That means prefer
the **export packet** (us), not:

- unregistered `~/.continue` / local-only edits, or
- treating the sibling as a second design authority

Inbound laptop commits are **signal**. Promote validated fixes into the packet
(and parent roles when needed), then sync. Do not leave the laptop as the only
copy of a fix.

## When to use / not use

Use when:

- user asks to process inbox / evaluate-and-fix / pull and fix laptop feedback
- active notes under sibling `inbox/` (not only `processed/` / `deferred/`)
- a laptop push fixed something and it must land in the packet before the next sync

Do not use when:

- audit-only debt / skill-gap review (`work-laptop-improvement-review`)
- only syncing with no inbox work (`work-laptop-packet-ops`)
- only applying on the Mac (`work-laptop-day2-apply`)

## Inputs

- sibling root (default `../work-laptop-ai-tools` next to `dotfile-vnext`)
- packet root `exports/work-laptop-ai-tools/`
- optional: push sibling after sync (default **on** when user asked to deliver fixes)

## Workflow

### 1. Pull sibling

```bash
cd <sibling-root>
git status -sb
git fetch --all --prune
git pull --ff-only
```

Stop on diverge/dirty conflict; do not force.

### 2. Inventory inbox

```bash
ls -la inbox/ inbox/processed/ inbox/deferred/ 2>/dev/null
git log -15 --pretty=format:'%h %ad %an %s' --date=short
```

Classify each active `inbox/*.md` (not README):

| Class | Action |
| --- | --- |
| Already fixed in packet | Move to `processed/` + short receipt |
| Validated fix missing from packet | Promote into packet/parent role, then process |
| Operator-interactive / out of scope | `deferred/` or deviation `accepted` without code |
| Conflicts with source intent | Keep source; register or reject; do not silently adopt |

### 3. Fix in source (not laptop-only)

For each implement item:

1. Edit **packet** and/or **parent** paths the manifest copies.
2. Update `deviations/register.yaml` + `deviations/entries/` when the
   accommodation must survive reinstall or generalize.
3. Do **not** “fix” by only editing the sibling outside a later sync.

### 4. Process inbox artifacts

- Move finished notes to `inbox/processed/` (overwrite older copy if the note
  gained a correction section).
- Write a dated receipt under `inbox/processed/` listing: note, class, packet
  paths touched, deviation ids.
- Update sibling `inbox/README.md` flow pointer if this skill is missing there.

Inbox is often **sibling-local** (may not be on the export manifest). Keep
receipts in the sibling; durable design stays in the packet.

### 5. Sync + deliver

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py
```

Then in the sibling: commit synced packet files (no vault secrets), push when
the user wants laptop delivery. Laptop next: `work-laptop-day2-apply`.

## Outputs

- Inbox notes classified and moved
- Packet/parent fixes + optional deviation entries
- Validate + sync OK
- Optional sibling commit/push
- Clear note if AGENTS “prefer source” was applied (kept packet, not laptop drift)

## Validation

- No active implementable notes left unexplained in `inbox/`
- FIM / Jinja / Continue template changes exist in **parent**
  `roles/continue_ide` and packet `host_vars` when that was the issue
- Sibling after sync matches packet for manifest paths
- `deviations/register.yaml` lists new accepted accommodations

## Prohibited behavior

- Treating sibling or `~/.continue` as design authority because AGENTS said
  “prefer source”
- Discarding a validated laptop fix without promoting it into the packet
- Claiming complete without `git pull` + inbox inventory in this turn
- Blind overwrite of registered deviations

## Progressive disclosure

- Audit sibling / debt: `work-laptop-improvement-review`
- Sync only: `work-laptop-packet-ops`
- Laptop apply: `work-laptop-day2-apply`
- Deviation manifest: `deviations/register.yaml`
- Packet authority: `AGENTS.md`

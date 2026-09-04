---
name: work-laptop-improvement-review
description: "Use when reviewing the work-laptop-ai-tools sibling for technical debt and skill gaps: git pull latest, read recent commits/PR comments, evaluate debt and how packet skills should improve processing this project. Audit-only unless the user asks to implement. Do not use for day-2 playbook apply (work-laptop-day2-apply) or MCP enable (work-laptop-mcp-commission)."
---

# Skill: Work-laptop improvement review

Periodic **pull → read history/comments → evaluate** loop for the sibling
project. Goal: surface technical debt and skill improvements so agents process
this slice more reliably next time.

Default mode: **audit + recommend only**. Implement only when the user asks.

## When to use / not use

Use when:

- user asks to review / audit / improve the work-laptop sibling or its skills
- after a burst of laptop ops (Continue/Cline/`cx-*`/vault) and wants a debt pass
- “pull latest and tell me what we should fix next”

Do not use when:

- only converging the laptop (`work-laptop-day2-apply`)
- only syncing parent→sibling design (`work-laptop-packet-ops`)
- enabling MCP or IDE clients (commission / ide-clients skills)

## Authority

| Layer | Path |
| --- | --- |
| Runtime / review target | sibling checkout (laptop: `~/Documents/develop/work-laptop-ai-tools`; home: `../work-laptop-ai-tools`) |
| Design authority | parent `dotfile-vnext/exports/work-laptop-ai-tools/` — recommendations that change design land there, then sync |
| Skills under review | sibling `.agents/skills/` (mirrors packet) |

## Inputs

- sibling repo root (required)
- optional: commit window (default last **20** commits or **14** days, whichever is clearer from log)
- optional: implement mode (default **off**)

## Workflow

### 1. Pull latest (sibling)

```bash
cd <sibling-root>
git status -sb
git fetch --all --prune
git pull --ff-only
```

If pull fails (diverged / dirty), stop: report status; do not force. Ask before
stash/reset.

If parent packet is available next door, note whether sibling lags parent
(compare packet revision / recent parent commits touching
`exports/work-laptop-ai-tools/`) — do not invent a second authority.

### 2. Read commits and comments

Collect evidence (this turn):

```bash
# Recent history
git log -20 --pretty=format:'%h %ad %s' --date=short

# Bodies (rationale / debt hints in commit messages)
git log -10 --pretty=format:'%h%n%s%n%b%n---'

# Optional PR / review comments when gh works
gh pr list --state merged --limit 10
# For a specific PR: gh pr view <n> --comments
```

Also read durable prose that encodes lessons:

- `AGENTS.md`, `README.md`
- `.agents/skills/*/SKILL.md` (especially day2-apply, ide-clients, vault, packet-ops)
- `vault/README.md`, host_vars comments around MCP / Continue / Cline / `cx-*`

Scan for debt markers (names only; no vault decrypt):

```bash
rg -n 'TODO|FIXME|XXX|HACK|REPLACE_WITH|pending|tech.?debt|workaround' \
  --glob '!vault/shared.vault.yml' -S . || true
```

### 3. Evaluate (required rubric)

Load `references/evaluation-rubric.md`. Score each finding:

| Bucket | Examples |
| --- | --- |
| **Technical debt** | brittle paths, missing asserts, parse-time role deps, vault/UI empty, hosts_file sudo tax, npm prefix shim |
| **Skill gaps** | repeated ad-hoc loops not in a skill; skills missing Cline/`cx-*`/day2; wrong handoff |
| **Process friction** | sibling treated as authority; sync without push; apply without verify |
| **Keep / defer** | intentional `absent` catalog, disabled remote autocomplete |

For each actionable item produce:

1. **Finding** (one line)
2. **Evidence** (commit hash, file path, or comment excerpt — no secrets)
3. **Impact** on laptop agents / day-2 reliability
4. **Recommendation** — skill edit, new skill, packet host_vars/role fix, or defer
5. **Owner surface** — parent packet vs sibling-only (almost always parent packet)

### 4. Receipt (conversation output)

Emit a short receipt:

```markdown
## Work-laptop improvement review

Pulled: <sibling-root> @ <short-sha> (<date>)
Window: <N commits / dates>

### Technical debt (priority order)
1. ...

### Skill improvements
1. Improve `skill-name`: ...
2. New skill (only if no existing match): ...

### Process / handoff fixes
1. ...

### Explicit non-actions
- ...

### Suggested next prompts
- Use skill work-laptop-ide-clients on ...
- Use skill work-laptop-packet-ops then ...
```

### 5. Implement (only if asked)

If user says implement / fix / apply recommendations:

1. Edit **parent packet** (or parent roles), not sibling-only.
2. Update skills under packet `.agents/skills/`.
3. Run `work-laptop-packet-ops` (validate + sync).
4. Remind: push sibling → laptop `work-laptop-day2-apply` when runtime matter.

## Validation

- `git pull` evidence from this turn (or blocked with status)
- Receipt cites commits/files, not memory
- No `ansible-vault view` / secret paste
- Design changes pointed at parent packet

## Failure boundaries

- Dirty or diverged sibling → stop after reporting
- No network / fetch fail → review local HEAD; label stale
- Empty commit window → widen to 30 commits or ask

## Prohibited behavior

- Force-pull / hard reset without explicit user ask
- Treating sibling as design authority for packet YAML
- Implementing “nice to have” without user ask in audit mode
- Printing vault values or API keys found in history

## Progressive disclosure

- `references/evaluation-rubric.md` — scoring dimensions and known debt themes
- Day-2: `work-laptop-day2-apply`
- IDE: `work-laptop-ide-clients`
- Sync: `work-laptop-packet-ops`
- Vault: `work-laptop-vault`
- Global follow-ons (optional): `project-skill-surface-opportunity-auditor`,
  `operational-pattern-to-skill-extractor`

---
name: work-laptop-improvement-review
description: "Use when reviewing work-laptop-ai-tools for debt, skill gaps, or inbound laptop feedback: git pull, read commits/PR comments from the external sibling, register accepted deviations, evaluate long-term fixes and generalize workarounds to similar tools. Audit-only unless the user asks to implement. Do not use for day-2 playbook apply alone (work-laptop-day2-apply)."
---

# Skill: Work-laptop improvement review

**Pull → read inbound feedback → register deviations → evaluate → (optional) implement.**

This slice repeatedly receives **corrections from the work laptop** (external
sibling). Those pushes are valuable signal: something in the packet assumed a
home-Mac layout that the corporate Mac does not share. Deviations are an
**accepted** part of the workflow — but they must be **accounted for** so the
same class of problem does not resurface, can be **re-applied** after reinstall,
and **trickles** to similar tools in the same behavior group.

Default mode: **audit + recommend only**. Implement / register writes when asked
(or when the user says the inbound push is feedback to capture).

## When to use / not use

Use when:

- user asks to review / audit / improve the work-laptop sibling or its skills
- **inbound laptop feedback**: commits/PRs/pushes from the work Mac merged or
  waiting to merge into the sibling / parent packet
- after a burst of laptop ops and wants a debt + deviation pass
- “the laptop had to fix X again — capture that”

Do not use when:

- only converging the laptop with no review (`work-laptop-day2-apply`)
- only syncing parent→sibling design with no feedback intake (`work-laptop-packet-ops`)
- enabling MCP/IDE without a review ask

## Authority

| Layer | Path |
| --- | --- |
| Runtime / review target | sibling checkout |
| Design authority | parent `exports/work-laptop-ai-tools/` |
| Deviation manifest | packet `deviations/register.yaml` + `deviations/entries/` (synced to sibling) |
| Skills | packet `.agents/skills/` |

## Inputs

- sibling repo root (required)
- optional: commit window (default **20** commits / **14** days)
- optional: explicit inbound SHAs / PR numbers from the laptop
- optional: implement / register-write mode (default **off**)

## Workflow

### 1. Pull latest (sibling)

```bash
cd <sibling-root>
git status -sb
git fetch --all --prune
git pull --ff-only
```

If pull fails (diverged / dirty), stop: report status; do not force.

If parent packet is available, note lag vs parent edits under
`exports/work-laptop-ai-tools/` — design still lands in the packet first.

### 2. Separate inbound laptop feedback from home→laptop sync

Inbound feedback is the high-value path. Detect it:

```bash
# Recent history with authors / subjects
git log -20 --pretty=format:'%h %ad %an <%ae> %s' --date=short

# Bodies (rationale)
git log -10 --pretty=format:'%h%n%s%n%b%n---'

# Optional PR comments
gh pr list --state all --limit 15
# gh pr view <n> --comments
```

Treat as **inbound laptop feedback** when any of:

- Author/email/hostname signals work laptop (`a805120`, corporate identity)
- Commit/PR message describes a live laptop failure + fix
- Branch/merge notes one-offs, “work laptop”, “laptop correction”
- Diff fixes paths, npm prefix, sudo, vault UX, IDE empty config, etc.
- User pastes laptop error output and asks to absorb it

Also read:

- `deviations/register.yaml` + matching `deviations/entries/*.md`
- `AGENTS.md`, `README.md` (Local Runtime Notes)
- `.agents/skills/*/SKILL.md`
- host_vars comments for Continue/Cline/`cx-*`/MCP

```bash
rg -n 'TODO|FIXME|XXX|HACK|REPLACE_WITH|workaround|Documents/develop|npm prefix' \
  --glob '!vault/shared.vault.yml' -S . || true
```

### 3. Deviation intake (required when inbound feedback exists)

For each inbound fix that accommodated a laptop↔project difference:

1. Map to an existing `deviations/register.yaml` **id** or draft a new one.
2. Fill or update `deviations/entries/<id>.md` from `_entry-template.md`.
3. Set `behavior_group` and list **generalize_to** peers (same class of tool).
4. Status:
   - `accepted` — accommodation stays; must re-apply
   - `promoted` — encoded in role/host_vars/skill; keep entry for history + peers
   - `obsolete` — only when proven gone

**Accepted deviations are not technical debt to delete.** They are first-class
manifest rows. Debt is *failing to register* them or *failing to generalize*.

Load `references/evaluation-rubric.md` § Inbound deviations.

### 4. Evaluate (debt + skills + generalization)

| Bucket | Examples |
| --- | --- |
| **Unregistered inbound** | Laptop fix landed in git but no `deviations/` entry |
| **Resurface risk** | Same symptom as a prior entry; accommodation not re-applied or not in role |
| **Generalization gap** | Fix for Codex npm prefix not applied to other npm globals in group |
| **Technical debt** | brittle paths, missing asserts, parse-time deps, empty IDE UI |
| **Skill gaps** | loops not handed off; skills ignore `deviations/` |
| **Process friction** | sibling-only authority; sync without push; apply without verify |

For each item:

1. **Finding**
2. **Evidence** (SHA, PR, entry id — no secrets)
3. **Impact** (resurface / reinstall / peer tools)
4. **Recommendation** (register, promote to role, skill edit, generalize peer)
5. **Owner surface** (almost always parent packet)

### 5. Receipt

```markdown
## Work-laptop improvement review

Pulled: <sibling-root> @ <short-sha> (<date>)
Window: <N commits>
Inbound laptop feedback: <yes/no — list SHAs/PRs>

### Deviation intake
| id | status | behavior_group | action |
| --- | --- | --- | --- |
| npm-global-prefix | promoted | npm-global-install | update generalize_to morph |

### Technical debt
1. ...

### Skill improvements
1. ...

### Generalize to peers (same behavior_group)
1. ...

### Explicit non-actions
- ...

### Suggested next prompts
- Use skill work-laptop-packet-ops after registering deviations
- Use skill work-laptop-day2-apply on the laptop to re-apply
```

### 6. Implement (only if asked)

1. Edit **parent packet** `deviations/`, skills, roles, host_vars — not sibling-only.
2. Promote accommodations into roles when mature (`status: promoted`).
3. `work-laptop-packet-ops` validate + sync.
4. Push sibling → laptop `work-laptop-day2-apply` when runtime matters.

## Validation

- Pull evidence this turn (or blocked with status)
- Inbound feedback either mapped to `deviations/` or listed as unregistered gap
- Receipt cites SHAs/files; no vault secrets
- Design/register changes pointed at parent packet

## Failure boundaries

- Dirty/diverged sibling → stop after reporting
- Fetch fail → review local HEAD; label stale
- User declines to accept a deviation → document as rejected, do not force home-Mac defaults onto laptop

## Prohibited behavior

- Force-pull / hard reset without explicit ask
- Treating sibling as design authority
- “Fixing” an accepted deviation by deleting the accommodation without register update
- Implementing peers without user ask in audit mode
- Printing vault values / API keys

## Progressive disclosure

- `deviations/README.md`, `deviations/register.yaml`
- `references/evaluation-rubric.md`
- `references/inbound-feedback.md` — how to classify laptop pushes
- `work-laptop-day2-apply`, `work-laptop-ide-clients`, `work-laptop-packet-ops`, `work-laptop-vault`

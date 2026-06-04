# Plan verification receipt

**Purpose:** When a plan is executed, reviewed, or marked complete, verification must
cover **every testable obligation in the plan packet** — not only lines under
`## Checklist`.

**Diagram gate receipt** (in `framework-partner-process.mdc`) proves the plan was
authored correctly. **Plan verification receipt** proves the plan was fulfilled.

## Anti-pattern (prohibited)

- Building a receipt only from `## Checklist` checkboxes while ignoring Apply/Verify/Undo,
  reference tables, prose gates, frontmatter dependencies, and diagram-embedded requirements
- Marking `lifecycle: implemented` when checklist items are `[x]` but change-contract
  **Verify** was never demonstrated with evidence
- Treating narrative sections as "discussion" when they state completion criteria
  (e.g. "≠ done until …", "must pass before …", "blocking")
- Ignoring `## On Deck — user decisions to integrate` rows when deciding whether
  a plan is buildable or implemented
- Reporting "missing role/playbook/resource" as a final blocker before checking
  official docs/MCPs, scaffolding the missing repo-owned surface when clear, and
  running the first safe dependency gate
- Leaving dependency order only in prose after implementation begins instead of
  adding or updating an executable playbook chain
- Treating `blocked` or `fail` rows as completion. Blocked is honest status,
  not done status, unless the work is removed from current scope and moved to a
  named future plan accepted by the user.
- Treating exact model IDs, providers, hardware placement, or downloads from
  brainstormed intake as selected resources before a current research matrix and
  live probe receipt exist.

## What counts as an obligation

Scan the full plan `README.md` (and linked packet files in the same folder when
they are part of the active slice). Include:

| Source | Examples |
|--------|----------|
| **Checklist** | Explicit `- [ ]` / `- [x]` rows |
| **Change contract** | Apply, Verify, Undo, Class table or prose |
| **Frontmatter** | `scope`, `depends_on_plans`, `unblocks`, `netbox_scope` |
| **Prose gates** | "not done until", "blocking", "must pass", "required before" |
| **Reference tables** | SSOT rows, ingress registry, host lists — each row that defines required runtime or operator state **for this slice** |
| **Diagrams** | Nodes/edges that name files, hosts, tags, or flows the slice must realize (spot-check against repo + live evidence) |
| **Reinforcement tasks** | Documentation or schema tasks added during planning |
| **On Deck rows** | Explicit user decisions that must be integrated, routed, or rejected before build |
| **Capability introduction** | Items from [capability_introduction_checklist.md](capability_introduction_checklist.md) when the plan introduces a capability |
| **Coordinator dependency order** | Ordered playbooks or orchestrator entrypoint that enforces cross-plan prerequisites |
| **Missing-resource resolution** | Research/source checks, scaffolded role/playbook/schema surfaces, and probe output before accepting a blocker |

**Out of scope for this slice** (still list, do not require pass):

- Sections labeled follow-on, deferred, v2+, or "not v1"
- Explicit `scope: doc-only` plans — verify doc/schema deliverables only, not live apply

## NetBox-scoped packets

When `netbox_scope: true` is present, or the packet materially changes
NetBox-managed naming, services, registry, DNS intent, or ingress metadata,
the obligation inventory must explicitly cover:

| Surface | Requirement |
|--------|-------------|
| **Declared** | Packet text, repo files, schema rows, and gate entrypoints agree on the NetBox-managed objects in scope |
| **Applied** | Existing seed/apply path used, or explicit read-only reconciliation-only status stated; repo-only defaults are not sufficient |
| **Verified** | Repo consistency, live object lookup, and artifact-backed comparison evidence |
| **Bootstrap / recovery exception** | Allowed only when the work is truly bootstrapping or recovering NetBox itself; do not count it as normal steady-state completion evidence |

## Workflow

### 1. Build obligation inventory (before claiming progress)

Assign stable IDs (`O-01`, `O-02`, …). One row per testable obligation.

```markdown
| ID | Source | Obligation | In slice scope? | Status | Evidence |
|----|--------|------------|-----------------|--------|----------|
| O-01 | Checklist LA-3 | Apply Traefik routes; kubectl ingress evidence | yes | blocked | SSH kex error on k3s-02 |
| O-02 | Verify (contract) | curl langfuse.hom.lab from mac-dev | yes | pending | depends O-01, OP-1 |
| O-03 | Reference / GT6 | langfuse → .158 pending_add | yes | pending | OP-1 |
| O-04 | Follow-on NB-5 | Ingress reconciliation in discover task | no | deferred | not v1 |
```

Statuses: `pass` | `fail` | `blocked` | `pending` | `deferred` | `n/a`

### 2. Collect evidence per in-scope row

Evidence rules match `framework-troubleshooting-mode.mdc`:

- Raw command output, log excerpt, saved artifact path, or pasted gate script output
- No paraphrase-only "receipt" cells
- Checklist ID may match obligation ID but is not sufficient alone

### 3. Complete the receipt section in the plan packet

Add or update `## Plan verification receipt` in the plan `README.md` (before
`lifecycle: implemented` or when reporting execute status).

```markdown
## Plan verification receipt

**Slice:** v1
**Verified at:** YYYY-MM-DD
**Verifier:** agent run | manual review

### Obligation inventory

| ID | Source | Obligation | In slice scope? | Status | Evidence |
|----|--------|------------|-----------------|--------|----------|
| … | … | … | yes/no | … | … |

### Summary

- In-scope obligations: N — pass: X, fail: Y, blocked: Z, pending: P
- Deferred (explicit out-of-slice): W

### Completion gate (all required for `lifecycle: implemented`)

- [ ] Every **in-scope** obligation is `pass` or `n/a` with reason; `blocked`,
      `fail`, or `pending` keeps the plan incomplete unless the obligation is
      moved out of current scope to a named future plan
- [ ] Change-contract **Verify** demonstrated for this slice (pasted output or artifact path)
- [ ] `depends_on_plans` satisfied or failure documented with evidence
- [ ] No in-scope obligation skipped because it was not duplicated in `## Checklist`
- [ ] No unresolved `On Deck` row remains outside the plan body, checklist,
      dependency graph, sibling plan routing, or rejection note
- [ ] Missing roles/playbooks/resources were researched and scaffolded where
      clear before being treated as blockers
- [ ] Dependency order is represented in executable Ansible entrypoints, not
      only prose
- [ ] Exact candidate resources from brainstormed intake are either supported by
      current research/probe evidence or labeled `pending_research` /
      `provisional_example`
```

### 4. Checklist sync rule

`- [x]` on a checklist row is allowed only when the matching obligation inventory
row is `pass` (or `n/a` with reason). If inventory says `blocked`, checklist must
stay `[ ]` or show blocked note — never `[x]` without evidence.

## Relation to execute receipt tables

Plans may keep a short **Execute receipt** table keyed by checklist IDs for
operator scanability. That table must be a **view** of the obligation inventory,
not a substitute. If an execute receipt row exists without a matching inventory
row, the verification is incomplete.

## Agents and skills

| Surface | Requirement |
|---------|-------------|
| `framework-partner-process.mdc` | Multi-plan execution + completion gates |
| `framework-plan-governance.mdc` | Reminder on save and on complete |
| `complete-plan-lifecycle` skill | Full receipt before `-implemented` rename |
| `AGENTS.md` Working Contract | Execute-complete requires comprehensive verification |

## Optional future enforcement

- CI: fail if `lifecycle: implemented` in frontmatter but `## Plan verification receipt` missing
- Script: lint checklist `[x]` vs inventory `pass` mismatch

Tracked in [docs/plans/2026-05-27--plan-diagram-governance-incomplete/README.md](../plans/2026-05-27--plan-diagram-governance-incomplete/README.md).

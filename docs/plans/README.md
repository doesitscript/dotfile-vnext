# Durable Plans

**Authority index:** [docs/codex_framework/plan-governance-dependencies.md](../codex_framework/plan-governance-dependencies.md)

Approved plans belong here.

## Default Rules

- Store the full approved plan in this directory.
- Treat the repo plan as the canonical durable artifact.
- Mirror the work into a GitHub issue as a higher-level roadmap when GitHub is available.
- Keep the GitHub issue shorter than the repo plan and link the two when that improves pickup.
- **Include Mermaid diagrams** visualizing architecture, implementation flow, and naming standards (see `.cursor/rules/framework-partner-process.mdc` for full requirements). The same baseline applies to official conversational `<proposed_plan>` plans.
- When the user explicitly decides or directs a scope item during plan work,
  capture it immediately in `## On Deck — user decisions to integrate` at the
  bottom of the active plan. This section is temporary. Plans cannot proceed to
  build/execute until every on-deck item is integrated into the plan body,
  routed to a named sibling plan with dependency linkage, or explicitly rejected
  by a later user correction.

## Promoting intake to a plan packet

When moving `docs/intake/*.md` into `docs/plans/YYYY-MM-DD--short-slug/README.md`:

| Frontmatter | Meaning |
|-------------|---------|
| `scope: implementation` (default) | Include roles, playbooks, inventory, and naming-schema updates from the intake doc |
| `scope: doc-only` | Documentation and plan packet only — must be explicit |
| `depends_on_plans` | Optional list of plan slugs that must land first |
| `unblocks` | Optional list of plans this work enables |

**Default:** inherit the intake blueprint's implementation scope. Do not shrink to
"docs + commit" unless the user explicitly wants doc-only.

**Naming:** complete `docs/codex_framework/capability_introduction_checklist.md` before
writing new inventory SSOT. Patterns live in `docs/reference/naming-standards/`; instances
in `live-object-registry.yml`.

**Body:** reference schema pattern IDs and file paths — do not paste duplicate registry YAML.

**Diagrams on promotion:** inherit intake blueprint diagrams and expand them to
meet the checklist below. Do not replace a full intake Architecture diagram with
a thinner status summary. Status tables are additive; they do not substitute for
missing diagrams or a Diagram gate receipt (see `framework-partner-process.mdc`).

**Verification on execute/complete:** use a **Plan verification receipt** that
covers every testable obligation in the plan packet — checklist, change contract,
reference tables, prose gates, and frontmatter dependencies — not checklist
rows alone. Canonical spec:
[docs/codex_framework/plan-verification-receipt.md](../codex_framework/plan-verification-receipt.md).

**Implementation order:** code may land before the plan packet; if so, backfill
the plan packet and pass the diagram gate before marking the plan slice complete.
Build the plan verification receipt before calling the slice implemented.

**Scope vs sequencing:** A plan may say which slice runs first, but sequencing
must not shrink approved scope. If the user decides that multiple model lanes,
agent roles, hosts, or resources belong in the effort, the plan must carry the
full set and mark individual rows `candidate`, `blocked`, or `pending research`
as needed instead of omitting them.

## Required On Deck Section

Every active `*-incomplete*` implementation plan should include this section
near the bottom, before the final diagram support sections, when any user
decision has not yet been fully wired:

```markdown
## On Deck — user decisions to integrate

| ID | User decision / direction | Target integration | Status |
|----|---------------------------|--------------------|--------|
```

The section is empty or omitted only when all user decisions in the current
planning thread are already represented in the plan's scope, checklist,
dependencies, and receipt.

## Required Diagram Checklist

Every stored plan must include these sections before it is considered complete:

- `Architecture/Structure Diagram`: required for every stored plan. Show the repo files, roles, inventories, playbooks, external systems, and managed targets that the plan changes or depends on.
- `Capability Routing Diagram`: required when the plan has runtime branching, multiple systems, preview/apply/verify paths, lifecycle state, conditional execution, or target selection.
- `Naming/Modeling Diagram`: required when the plan changes names, aliases, object hierarchy, source-of-truth metadata, or naming standards.
- `Other Available Diagram Types` or `Diagram Inventory`: required at the end
  of every plan so reviewers can see which optional diagrams were considered.

If a diagram is truly not applicable, include the section anyway with an explicit
`N/A` reason. Do not omit the section silently.

## Required NetBox Slice (when `netbox_scope: true` or plan touches services/naming/registry)

Every affected implementation plan must include:

- Section `## Mandatory NetBox slice` (or NetBox rows in `## Checklist` with **NB-** IDs)
- Declared / Applied / Verified contract:
  - **Declared** — repo packet, schema rows, and implementation files agree on in-scope NetBox-managed objects
  - **Applied** — existing live NetBox seed/apply path used, or explicit read-only reconciliation-only status
  - **Verified** — `validate_netbox_repo_consistency.sh`, live object check, and artifact-backed comparison evidence
- Execute receipt evidence for NB steps

Bootstrap or recovery of NetBox itself is an allowed exception area, but it must
be labeled as bootstrap/recovery work and must not be reported as normal
steady-state NetBox completion.

Repo-only `roles/ipam_netbox/defaults` changes do **not** satisfy NetBox completion until API apply passes.

## Required verification receipt (execute and complete)

When implementing, re-running, or closing a plan slice:

1. Read the full plan `README.md` (and same-folder packet files for the active slice).
2. Build an **obligation inventory** per
   [plan-verification-receipt.md](../codex_framework/plan-verification-receipt.md).
3. Add or update `## Plan verification receipt` in the plan packet with evidence per
   in-scope row.
4. Sync `## Checklist` checkboxes: `[x]` only when the matching inventory row is `pass`.

**Prohibited:** receipts or "done" claims derived only from `## Checklist` while
ignoring Apply/Verify/Undo, reference tables, or prose completion gates.

Short **Execute receipt** tables (checklist ID → evidence) are allowed as a summary
view but must mirror the full obligation inventory.

## Naming

Use date-prefixed folder packets for all new approved plans:

- `YYYY-MM-DD--short-slug/`
- canonical entrypoint: `YYYY-MM-DD--short-slug/README.md`

Example:

- `2026-03-27--subagents-v1/`
- `2026-05-27--name-alignment-netbox-metadata-incomplete/` (partial; Track H5 open)
- `2026-05-27--netbox-wip-finish-roadmap-incomplete/` (active finish path; excludes edge dev hosts)
- `2026-05-27--netbox-ipam-completion-incomplete/` (prefixes, storage services, config contexts)
- `2026-05-27--edge-dev-host-naming-netbox-incomplete/` (deferred: mac-dev, dev-3090, dev-workstation)
- `2026-05-27--netbox-application-plugins-evaluation/` (Proxbox, Custom Objects, Attachments — evaluation only)
- `2026-05-27--k3s-hyperv-traefik-implemented/` (umbrella — Traefik + mac interim DNS + :80 portproxy — **done**)
- `2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/` (mac catalog + NB-4 — **done**)
- `2026-05-27--k3s-hyperv-traefik-lan-http-portproxy-implemented/` (LA-2b, LA-5b — **done**)
- `2026-05-28--wsl-scope-reform-incomplete/` (connection-surface policy — **done**; optional MANIFEST delete pass)
- `2026-05-28--homelab-hosts-file-linux-windows-incomplete/` (DNS-3 linux guests — **done**; windows scaffold when desktop commissioned)
- `2026-05-28--homelab-dns-adguard-authority-incomplete/` (authoritative DNS — moved from Traefik umbrella)
- `2026-05-28--k3s-vllm-service-publication-incomplete/` (vLLM service publication entry when runtime exists; reserve model catalog for future multi-model planning)
- `2026-05-29--ai-homelab-intake-execution-incomplete-wip/` (**umbrella** — NetBox-first program for intake `netbox_ai_infra_impl_planning_wip`; child slices below)
- `2026-05-29--ai-ansible-modularity-and-gaps-incomplete-wip/` (glossary gaps: `ai_*`, `node_classes`, D-1, privacy router)
- `2026-05-29--ai-model-catalog-hf-storage-incomplete-wip/` (HF weights on hvh-01 SMB; D-4)
- `2026-05-29--ai-vllm-primary-stack-incomplete-wip/` (vLLM on k3s-02; extends 2026-05-19 + 2026-05-28 vLLM plans)
- `2026-05-29--ai-litellm-model-lanes-incomplete-wip/` (`model_list` + `router_settings`; D-1, D-2)
- `2026-05-29--ai-langfuse-observability-incomplete-wip/` (trace metadata + 1.4.0 cookbook patterns; D-3)
- `docs/archive/wsl-deprecating/` — archived WSL-centric markdown + MANIFEST (coordinator review)
- `2026-05-27--plan-diagram-governance-incomplete/` (evaluate CI/skill enforcement for diagram gate)

Plans migrated from `.cursor/plans/` on 2026-05-27. Folders suffixed with
`-incomplete` are not fully implemented. See `.cursor/plans/README.md` for the
redirect note.

### Historical WSL automation plans (archived 2026-05-28)

Server/hyperv/k3s/docker WSL automation narratives live in
[`docs/archive/wsl-deprecating/plans/`](../archive/wsl-deprecating/plans/). Active
`docs/plans/2026-05-20--hyper-v-bridge-networking-role/` and
`k3s-cluster-deployment-incomplete/` are **redirect stubs** only. Current policy:
[`docs/reference/connection-surfaces.md`](../reference/connection-surfaces.md).
Coordinator: [`2026-05-28--wsl-scope-reform-incomplete/`](2026-05-28--wsl-scope-reform-incomplete/README.md).

Legacy single-file plans may remain until touched. When a single-file plan is
updated for new work, migrate it into a folder packet or mark it as archive
material. Do not create new `YYYY-MM-DD--short-slug.md` plans.

## Completed Plan Lifecycle

When a plan is fully implemented and verified:

1. **Add YAML frontmatter** to mark lifecycle status and GitHub tracking:
   ```yaml
   ---
   lifecycle: implemented
   github_issue: <number>
   implemented_date: YYYY-MM-DD
   archive_candidate: true
   ---
   ```

2. **Rename the file** with `-implemented` suffix:
   ```
   YYYY-MM-DD--short-slug.md  →  YYYY-MM-DD--short-slug-implemented.md
   ```

3. **Create a GitHub issue** (via `github-issue-workflow` skill or `gh` CLI) with:
   - `type:capability` (or appropriate type)
   - `state:done`
   - `scope:*` (relevant scope)
   - Reference to the plan file in the issue body
   - Close the issue immediately as completed

4. **Commit** the renamed plan file with the issue reference.

### Archive Candidate Frontmatter

**`archive_candidate: true`** marks a completed plan as eligible for cleanup:
- The plan is fully implemented
- The work is committed and verified
- The GitHub issue provides searchable tracking
- The file can be safely archived or removed without losing critical information

This is a **searchable metadata standard** for housekeeping. Plans marked as archive candidates can be:
- Moved to `docs/plans/archive/` for long-term reference
- Removed entirely if the commit history and GitHub issue are sufficient
- Left in place if they provide valuable pattern reference

The frontmatter metadata allows scripts or agents to identify archive-ready plans without manual review:

```bash
# Find all archive candidates
grep -R -l "archive_candidate: true" docs/plans
```

### Three-Layer Model

- **Repo plan** (`docs/plans/`) = canonical detailed plan and implementation record
- **GitHub issue** = higher-level roadmap and tracking (closed as done for completed work)
- **Role docs/READMEs** = implementation context and recovery layer

## Relationship To Other Docs

- `docs/plans/` is the durable planning layer for approved work across the repo.
- `docs/codex_framework/implemented_plans/` remains the framework-specific implemented-history layer.
- Role READMEs, intake notes, and diagnostics docs should link to a plan only when that link materially helps future pickup.

## Proactive Reinforcement During Planning

**Core Principle:** When the user has to explain, correct, or clarify something during planning, that represents a gap in project documentation or standards. The AI should proactively add tasks to the current plan to strengthen those areas.

### Pattern Recognition During Planning

Watch for these signals that indicate missing project guidance:

1. **User questions about tool choice**
   - Example: "Why should I use uv? Is this redundant to poetry?"
   - Signal: Python tooling authority unclear
   - Response: Add task to update `python` role README with pattern guidance

2. **User corrections about existing patterns**
   - Example: "We use pip/venv for git-cloned projects, not uv"
   - Signal: Pattern not documented or discoverable
   - Response: Add task to strengthen template or role documentation

3. **User requests for version pinning or stability**
   - Example: "What about version pinning?"
   - Signal: Template doesn't enforce or guide toward stability
   - Response: Add task to update template with version pinning variables and guidance

4. **User asks to document decisions**
   - Example: "Capture this discussion so we don't lose the knowledge"
   - Signal: Decision rationale not preserved for future reference
   - Response: Evaluate if role README or central doc is warranted; add appropriate task

### The Reinforcement Loop

```
User explains/corrects during planning
    ↓
AI identifies root cause (missing guidance, unclear authority, weak template)
    ↓
AI adds task to current plan to strengthen that area
    ↓
Future plans benefit from strengthened guidance
    ↓
Fewer explanations/corrections needed
```

### Required Step During Planning

Before finalizing any plan, explicitly ask:

> "What user explanations or corrections during this planning session reveal gaps in project documentation or standards? What tasks should I add to this plan to prevent needing those same explanations next time?"

Then add those reinforcement tasks to the current plan, not as future follow-up work.

### Real Example: NetBox MCP Server Plan (May 2026)

**User corrections during planning:**
- "Why should I use uv?" → Pattern authority unclear
- "What about version pinning?" → Template enforcement weak
- "Document this decision" → No preservation path

**Tasks added to plan:**
- Update `python` role README with pattern guidance and tool evaluation rationale
- Update MCP template with version pinning variables and enforcement
- Create central doc for cross-cutting Python tooling decisions
- Update planning process itself with this reinforcement pattern

**Result:** Next MCP server or Python tooling decision has stronger guidance available from the start.

### Documentation Decision Tree (During Planning)

When a decision needs documentation:

1. **Single role affected?**
   - YES → Add task to update that role's README
   - NO → Continue to #2

2. **Cross-cutting (affects multiple roles)?**
   - Evaluate: Does it provide decision framework? Connect scattered decisions? Prevent repeated investigations?
   - YES → Add task to create/update central doc + update affected role READMEs with pointers
   - NO → Add task to update most relevant role README only

3. **Template/standard gap revealed?**
   - Add task to update template with stronger guidance or fail-fast validation

**Goal:** Every plan should leave the project stronger than it found it, not just implement the immediate feature.

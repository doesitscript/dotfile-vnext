# Execution plan — homelab model-lane ATDD coordination

**Plan packet:** [README.md](README.md) (frontmatter, capability boundary, diagrams)  
**Lifecycle:** `implemented` — Phase 1–2 complete; see [execution-receipt.md](execution-receipt.md)  
**Last updated:** 2026-09-02

Use this file if the conversation thread is lost. Do not re-brainstorm; execute
these steps against existing artifacts.

---

## Current state (prep complete)

| Artifact | Status | Path |
| --- | --- | --- |
| Acceptance specs (project) | **Done** | `model-lane-acceptance/` (repo root) |
| Pytest harness | **Done** (global-skills) | `homelab-litellm-model-lane-pytest` |
| ATDD flow diagram | **Done** | [diagrams/atdd-developer-flow.md](diagrams/atdd-developer-flow.md) |
| Stack implementer intake example | **Done** | [examples/stack-implementer-intake-client-model-map.example.md](examples/stack-implementer-intake-client-model-map.example.md) |
| Stack implementer intake prompt | **Done** | [references/stack-implementer-intake-request.md](references/stack-implementer-intake-request.md) |
| Stack implementer role contract | **Done** | [references/stack-implementer-instructions.md](references/stack-implementer-instructions.md) |
| Stack implementer handoff templates | **Done** | [references/stack-implementer-handoff-template.md](references/stack-implementer-handoff-template.md) |
| Coordinator skill | **Done** | global-skills `homelab-model-lane-atdd-coordinator` |
| Live multi-agent coordination | **Out of scope** for first execute slice |

Draft folder `draft-multi-agent-vnext-plan-work/` under the Codex plan was **consolidated and removed**.

---

## Roles (stable vocabulary)

| Role | Agent varies? | Responsibility |
| --- | --- | --- |
| **Operator (Josh)** | — | Journey intent, sign-off from receipts |
| **Acceptance author** | Cursor / future agent | EXPECTED YAML, probes, promote, handoffs on FAIL |
| **Stack implementer** | **Yes** — Codex is current example only | Deploy/runtime/gateway/client config from FAIL evidence |

Models, clients (CLI, IDE extensions), and campaigns **change**. Skill text must stay agent-neutral.

---

## Target deliverable

Global skill: **`homelab-model-lane-atdd-coordinator`**

Location: `/Users/joshc/develop/global-skills/skills/validation/homelab-model-lane-atdd-coordinator/`

It bootstraps the **acceptance author** role in a cold conversation and defines
handoff templates for any **stack implementer** agent.

---

## Phase 1 — Build coordinator skill (global-skills)

### 1.1 Skill skeleton

Create:

```text
skills/validation/homelab-model-lane-atdd-coordinator/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── coordinator-checklist.md           # 8-step ATDD loop
│   ├── stack-implementer-handoff-template.md
│   ├── stack-implementer-instructions.md
│   └── stack-implementer-intake-request.md  # copy/adapt from dotfile-vnext plan references
└── scripts/                               # optional: print_handoff_paths.py if useful
```

### 1.2 SKILL.md must include

1. **When to use** — after stack implementer produces client-model map; evaluating new lanes; mid-plan ATDD alignment.
2. **When not to use** — gateway down; no map and no journey from operator; deploy-only work with no acceptance criteria.
3. **Default evidence contract** — human mode; every PASS/FAIL receipt; never test-count-only summaries (mirror `homelab-litellm-model-lane-pytest`).
4. **depends_on_skills** — `homelab-litellm-model-lane-pytest`, `homelab-codex-cli-model-pytest`, `homelab-local-ai-client-validation-pack`.
5. **Inputs** — `PROJECT_ROOT`, path to client-model map, optional campaign label.
6. **Eight-step workflow** (from [diagrams/atdd-developer-flow.md](diagrams/atdd-developer-flow.md)):
   - Read client-model map
   - Diff vs `model-lane-acceptance/client-map.yml`
   - Write/update `pending/` acceptance YAML (`title`, `user_story`, EXPECTED)
   - Run `./model-lane-acceptance/scripts/run-gateway-acceptance.sh` and/or `run-codex-acceptance.sh`
   - Return all receipt blocks to operator
   - On FAIL: write stack-implementer handoff (template in references)
   - On all PASS: promote pending → approved manifests; update `client-map.yml` status
   - Report ready for operator sign-off
7. **Stack implementer intake** — point at dotfile-vnext [stack-implementer-intake-request.md](references/stack-implementer-intake-request.md) and [example map](examples/stack-implementer-intake-client-model-map.example.md).
8. **Mid-plan interrupt** — operator pauses stack implementer; stack implementer reads `stack-implementer-instructions.md` + latest handoff file (paths defined in skill references).
9. **Prohibited** — weaken EXPECTED; promote pending on FAIL; fork pytest harness.
10. **Deferred gate** — multi-day/multi-group layout: stop and discuss with operator (see [acceptance-artifacts-layout.md](references/acceptance-artifacts-layout.md)).

### 1.3 Reference file contents

**coordinator-checklist.md** — numbered 8 steps with artifact paths per step.

**stack-implementer-handoff-template.md** — copy from this plan's [references/stack-implementer-handoff-template.md](references/stack-implementer-handoff-template.md):

- `to-stack-implementer/NNN-<slug>.md` — FAIL receipts, manifest path, scope, ask
- `from-stack-implementer/NNN-<slug>-response.md` — files changed, re-probe command

Handoffs live under a **campaign workspace path** (skill defines default:
`docs/plans/<active-plan>/coordination/handoffs/` or operator-provided). v1: skill
documents paths; operator or acceptance author creates dirs per campaign.

**stack-implementer-instructions.md** — copy from this plan's [references/stack-implementer-instructions.md](references/stack-implementer-instructions.md).

**stack-implementer-intake-request.md** — copy from this plan's [references/stack-implementer-intake-request.md](references/stack-implementer-intake-request.md).

### 1.4 agents/openai.yaml

```yaml
interface:
  display_name: "Homelab Model Lane ATDD Coordinator"
  short_description: "Acceptance author for homelab model-lane ATDD"
  default_prompt: >-
    Use $homelab-model-lane-atdd-coordinator. Acceptance author mode: human receipts
    for every PASS and FAIL before any summary. On FAIL write stack-implementer handoff
    from references/stack-implementer-handoff-template.md. Stack implementer agent varies by campaign.
policy:
  allow_implicit_invocation: false
```

### 1.5 Catalog and pack link

- Add entry to `global-skills/skills/catalog.yaml` (`status: draft` until verified).
- In `homelab-local-ai-client-validation-pack/SKILL.md`, add row: full ATDD campaign → `homelab-model-lane-atdd-coordinator`.

---

## Phase 2 — Verify (no live multi-agent run required)

| # | Check | Evidence |
| --- | --- | --- |
| V-1 | Skill metadata validates | `validate-skill-library-metadata` or catalog gate |
| V-2 | SKILL.md links resolve to dotfile-vnext plan examples | manual read |
| V-3 | Dry-run: read example map, list diff actions vs `model-lane-acceptance/client-map.yml` | paste in plan folder or conversation |
| V-4 | Child skills referenced, not duplicated | no copied pytest code in coordinator |
| V-5 | Optional: run gateway smoke with existing scripts (already green) | receipt blocks if run |

**Not required for plan sign-off:** live stack implementer agent in same session.

---

## Phase 3 — Plan completion (after Phase 1–2)

1. Update [README.md](README.md) checklist rows to `[x]`.
2. Set README frontmatter `lifecycle: implemented` only if V-1–V-4 pass with evidence.
3. Add brief `execution-receipt.md` in this folder (what was created, verify outputs).

---

## Obligation inventory (verification receipt seed)

| ID | Source | Obligation | Status |
| --- | --- | --- | --- |
| O-01 | Phase 1.1 | Coordinator skill directory exists in global-skills | done |
| O-02 | Phase 1.2 | SKILL.md complete per section list | done |
| O-03 | Phase 1.3 | Four reference files present | done |
| O-04 | Phase 1.4 | agents/openai.yaml | done |
| O-05 | Phase 1.5 | catalog.yaml + validation-pack link | done |
| O-06 | Phase 2 | V-1–V-4 evidence recorded | done |
| O-07 | Deferred | Multi-day/multi-group result layout | deferred |

---

## Copy-paste — start next conversation

```text
Execute docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/execution-plan.md Phase 1–2.

Create global-skills skill homelab-model-lane-atdd-coordinator per execution-plan.md.
Use dotfile-vnext plan examples for stack implementer intake. Do not run live multi-agent coordination.
Update plan checklist and execution-receipt when done.
```

---

## Related paths (quick reference)

| What | Path |
| --- | --- |
| This execution plan | `docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/execution-plan.md` |
| Acceptance specs | `model-lane-acceptance/` |
| Example stack implementer map | `docs/plans/.../examples/stack-implementer-intake-client-model-map.example.md` |
| Example stack implementer plan | `docs/plans/2026-09-01--homelab-local-ai-clients-codex/README.md` |
| Harness skill | `global-skills/skills/validation/homelab-litellm-model-lane-pytest/` |
| HRL ATDD guide | `homelab-reference-library/implementation-guides/pytest/user-journey-receipt-tests.md` |

---

## On Deck — user decisions to integrate

(none — prep slice only; add rows here when operator decides during execute)

Your next step is sound: a **primer skill** (or thin **pack**) whose job is not to run tests, but to **bootstrap the acceptance-author agent** in a cold conversation — same posture we reached here: ATDD, receipts, coordinate with implementer, don’t collapse evidence.

## Skill vs pack — recommendation

Use a **small pack (router + primer)**, not one monolith:

| Piece | Role |
|--------|------|
| **`homelab-model-lane-atdd-coordinator`** (new primer) | “You are acceptance author; here’s how to start from a client-model map and coordinate.” |
| **Existing children** (unchanged) | `homelab-litellm-model-lane-pytest`, `homelab-codex-cli-model-pytest`, optionally `homelab-local-ai-client-validation-pack` for routing |
| **Project artifacts** (dotfile-vnext, not global) | `model-lane-acceptance/`, `draft-multi-agent-vnext-plan-work/` inbox/outbox, handoff templates |

The primer **orchestrates and enforces behavior**; it does not duplicate pytest or YAML schemas.

## What “clone your ready state” means in practice

A fresh agent needs four things we built implicitly:

1. **Role contract** — acceptance author writes EXPECTED first; implementer fixes stack; you sign off from receipts.
2. **Evidence contract** — human mode default; every PASS/FAIL block; no “17 passed” summaries.
3. **Artifact map** — where specs, pending vs approved, scripts, and diagrams live.
4. **Handoff protocol** — what to put in inbox/outbox for the other agent (your noted next item).

The primer skill should **load these as mandatory reads + a fixed workflow**, not as background trivia.

## Entry artifact: `role_implementor__client-model-map.md`

Good first step. Treat it as **intake, not approval**:

- It says *what was configured* and *experimental vs approved* boundaries.
- It does **not** replace acceptance YAML or live probes.
- The coordinator’s job: **translate map rows → journeys + capabilities → `model-lane-acceptance/` pending YAML → run probes → hand off FAILs**.

Suggested primer flow (8 beats, committable as SKILL steps):

1. Read client-model map (path passed by user or default under plan `implementor_output/`).
2. Diff against `model-lane-acceptance/client-map.yml` — what’s new/changed/experimental?
3. For each **non-approved** or **new** row: write user journey (`title`, `user_story`, EXPECTED) in `pending/`.
4. Run project scripts (`run-gateway-acceptance.sh` / `run-codex-acceptance.sh`).
5. Paste **all** receipt blocks to user.
6. If FAIL: write **inbox → implementer** handoff (manifest path + receipts + scope; no “tests failed”).
7. On re-probe green: promote pending → approved; update `client-map.yml` status.
8. Only then report “ready for your sign-off.”

That sequence is what “clone readiness” looks like — procedural, not vibes.

## What the primer should reference (load order)

Minimal **read list** inside the skill:

- `draft-multi-agent-vnext-plan-work/diagrams/atdd-developer-flow.md`
- `model-lane-acceptance/README.md` + `gateway/lane-decisions.md`
- HRL `user-journey-receipt-tests.md` (general ATDD/receipt rules)
- Child skill: `homelab-litellm-model-lane-pytest` (evidence contract only — don’t re-run full SKILL unless probing)
- Optional: `implementor_instructions.md` once you add the handoff template

**Input the user provides in the new conversation:**

```text
Use homelab-model-lane-atdd-coordinator on:
  client-model-map: docs/plans/.../implementor_output/role_implementor__client-model-map.md
  project: dotfile-vnext
```

## Relationship to Codex / implementer

The map file is **implementer output step 0**. The primer assumes:

- Model **groups and client wiring** may already exist (inventory, templates, roles).
- **Acceptance criteria** may lag or be wrong — that’s your lane.
- Implementer name is TBD; primer says “other agent / implementer” and points at inbox.

Don’t put dotfile-vnext paths only in global-skills long term — primer should accept **`PROJECT_ROOT` + relative paths** so the same skill works on the next evaluation campaign.

## What not to put in the primer (keep v1 immature on purpose)

- No workflow engine, no auto-inbox watchers.
- No duplicate of `homelab-default-lanes.yml` — project manifest is SSOT when `LITELLM_MODEL_LANE_MANIFEST` points at dotfile-vnext.
- No “weaken EXPECTED to green” escape hatches.
- Scale/deferred layout (multi-day, multi-group) stays a **“stop and discuss with Josh”** gate in the skill — matches your parked note.

## Suggested skill metadata (for when you implement)

- **Name:** `homelab-model-lane-atdd-coordinator` (or `homelab-local-ai-atdd-acceptance-author`)
- **Triggers:** “evaluate new models”, “ATDD acceptance for model lanes”, “coordinate implementer after client-model map”, “write pending acceptance from implementor output”
- **depends_on_skills:** `homelab-litellm-model-lane-pytest`, `homelab-codex-cli-model-pytest`
- **integration_targets:** `dotfile-vnext`
- **agents/openai.yaml default_prompt:** one line — run coordinator from client-model-map path; return all receipts before summary; write implementer inbox on FAIL.

## Partner read

You’re designing **pseudo-agent infra** correctly: implementer produces **map** → acceptance author produces **criteria + proof** → implementer closes **FAIL loop** → you promote. The primer skill is the **boot ROM** for the second agent in that loop. The client-model map is the right **first pin** because it bounds scope before anyone writes YAML.

When you switch to Agent mode, a sensible build order is:

1. Handoff template in `implementor_instructions.md` (+ empty `inbox/` / `outbox/`).
2. Primer `SKILL.md` + short `references/coordinator-checklist.md` + `agents/openai.yaml`.
3. Catalog entry + optional one-line link from `homelab-local-ai-client-validation-pack` (“full campaign → use coordinator”).

I can draft the full SKILL outline section-by-section in Agent mode if you want it committable in one pass.

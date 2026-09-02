## Wording (architect correction)

Avoid **“clone yourself”** or **“another version of Cursor.”** That implies copying a persona; what you actually want is bootstrapping a **role**:

| Say this | Not this |
|----------|----------|
| **Acceptance author** (or **ATDD coordinator**) | “Clone Cursor” |
| **Implementer** (name TBD — often Codex today) | “The other you” |
| **Primer skill** bootstraps the acceptance-author **workflow** | Skill that “recreates” me |

The primer does not duplicate my memory — it loads **contract + artifacts + steps** so any capable agent can play acceptance author on your homelab ATDD loop.

---

## Are two TODO files enough?

**Almost.** Right now:

| File | What it is |
|------|------------|
| `00_human_and_evaluator__brainstorm_plan.md` | One-line reminder (handoff template) — too thin to execute alone |
| `01_prime_agent_and_workspace.md` | Good **spec** for global skill + workspace (mostly my prior answer pasted in) |

For Agent mode I'd treat **01 as the single build ticket** for the acceptance-author side (global skill + project scaffolding).

You don't need a third **big** doc. You **do** need one small **operator** piece — either:

- **`README.md`** in `draft-multi-agent-vnext-plan-work/` (recommended), or  
- **`02_mid_plan_takeover.md`** (~½ page): what *you* do when interrupting an in-progress implementer.

**00** can merge into that README as “remaining whiteboard items” so you're not maintaining three parallel TODOs.

---

## Your mid-plan idea — yes, that's the right v1

Dropping structure into an **active plan folder**, pausing the implementer, and forcing a read is exactly how you **inject process mid-flight** without a workflow engine.

Two entry paths (both valid):

```text
Cold conversation     →  global skill: homelab-model-lane-atdd-coordinator
Mid-plan interrupt    →  project folder: instructions + handoffs + “read before continuing”
```

The global skill handles **“conjure acceptance author from zero.”**  
The project folder handles **“this Codex plan is already moving — align to coordinated ATDD now.”**

That matches your scenario: Codex produced `implementor_output/role_implementor__client-model-map.md`; acceptance author comes in **after** map exists, not instead of it.

---

## Minimum folders to “force structure” (v1)

Enough to coordinate without overbuilding:

```text
draft-multi-agent-vnext-plan-work/
├── README.md                      # roles, where things go, mid-plan interrupt steps
├── implementor_instructions.md    # implementer contract (read first; inbox/outbox rules)
├── handoffs/
│   ├── to-implementer/            # acceptance author → implementer (tasks + FAIL receipts)
│   └── from-implementer/          # implementer → acceptance author (what changed; ready to re-probe)
├── implementor_output/            # already exists — durable artifacts (client-model map)
└── diagrams/atdd-developer-flow.md
```

`implementor_inbox` alone is half a channel — you want **bidirectional** handoffs so the implementer knows they're **answering to acceptance criteria**, not only to the original plan README.

Acceptance author doesn't need a duplicate instruction file in-repo if the **global primer skill** is SSOT — but a one-line pointer in README (“acceptance author: use skill X”) helps when you stop/start agents.

---

## What you (Josh) do on mid-plan interrupt

Short operator script (could live in README):

1. Acceptance author (new thread or this one) writes first **`handoffs/to-implementer/NNN-<slug>.md`** (manifest path + receipt blocks + scope).
2. You stop the implementer: *“Read `implementor_instructions.md` and latest file in `handoffs/to-implementer/`. Do not weaken acceptance YAML or mark stable until acceptance author re-probes.”*
3. Implementer works, writes **`handoffs/from-implementer/NNN-response.md`** (files changed + re-probe command).
4. Acceptance author re-runs probes, promotes or sends back.

No third agent required — **files are the authority**, not chat tone.

---

## Do you need one more TODO doc?

| Need | Recommendation |
|------|----------------|
| Global skill build spec | **Keep `01_`** — rewrite as actionable checklist when in Agent mode |
| Whiteboard stub | **Fold `00_` into README** |
| Mid-plan human steps | **Add README** (or tiny `02_`) — this is the gap for *your* interrupt playbook |

So: **two files become one execution doc + one folder README** — not a third essay.

---

## Partner read

Your instinct is right: **don't wait for a perfect framework** — drop instructions + handoff dirs into the live plan, pause the implementer, make it read. That *is* pseudo-agent infrastructure and it scales later.

When you put me in Agent mode, sensible order:

1. README + `implementor_instructions.md` + `handoffs/{to,from}-implementer/`  
2. Global skill `homelab-model-lane-atdd-coordinator` (cold-start acceptance author)  
3. Trim `01_` into a checklist; merge `00_`

I won't create those in Ask mode — switch to Agent when you're ready.

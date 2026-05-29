# AI infra intake — work in progress

**Folder:** `docs/intake/netbox/netbox_ai_infra_impl_planning_wip/`  
**Index:** [README.md](./README.md) (archive numbering, merge groups, read order)  
**Last updated:** 2026-05-29

---

## Phase status

| Phase | Name | Status | Artifact(s) |
|-------|------|--------|-------------|
| **0** | Close the repo gap (assess + align) | `complete` | [ASSESSMENT.md](./ASSESSMENT.md), [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) |
| **0R** | **Reconcile** generic capabilities → tangible resources | `in_progress` | **[capability-requirements-to-resources-evaluation.md](./capability-requirements-to-resources-evaluation.md)** (primary) + `*-discussion` / `*-evaluation` |
| **1** | Merge, triage, and route outcomes | `complete` | [GROUP-A](./phase-1-GROUP-A-product-lab-intent-synthesis.md), [GROUP-B](./phase-1-GROUP-B-infra-deployment-synthesis.md), [TRIAGE](./phase-1-TRIAGE.md) |
| **2** | Create buildable plans | `blocked` | Until **0R** host + vLLM placement decisions; then infra-only incomplete packet |
| **3** | Execute (Ansible / NetBox / live apply) | `pending` | Plan verification receipt + playbook runs |

---

## Phase 0 — Close the repo gap (assess + align)

**Goal:** Turn early conversation value into **repo-grounded** definitions — or mark what is still only aspirational.

| TODO | What to do | Status |
|------|------------|--------|
| **0.1** | Inventory terminology and architecture labels vs `docs/reference/naming-standards/`, active plans, `roles/` / `playbooks/` | `done` → ASSESSMENT §0.1 |
| **0.2** | List doc updates for consistent project description (no duplicate SSOT YAML in prose) | `done` — P0 applied; P2 listed in ASSESSMENT |
| **0.3** | List Ansible structure gaps (roles in chat vs roles on disk; placement vs existing playbooks) | `done` → ASSESSMENT §0.3 |
| **0.4** | List NetBox / inventory gaps vs `live-object-registry.yml` and `roles/ipam_netbox/` | `done` → ASSESSMENT §0.4 |
| **0.5** | Buildability assessment per topic: `repo-ready now` \| `needs gap closure` \| `blocked` | `done` → ASSESSMENT §0.5 + triage |
| **0.6** | Apply safe non-plan repo updates where assessment is clear | `done` — layer-model, README, source-reconciliation |

**Exit criteria:** Written assessment (`ASSESSMENT.md` in this folder or `docs/intake/` note) — per topic: accurate vs repo, SSOT changes required, ready for plan or not.

**Pre-plans:** Content in `1.2.0` and Group A may be *close* to a plan packet; Phase 0.5 must confirm before Phase 2.

---

## Phase 1 — Merge, triage, and route outcomes

**Goal:** Combine mergeable intake; assign each topic a single routing outcome (implement now, incomplete, future-state, extract, defer).

| TODO | What to do | Status |
|------|------------|--------|
| **1.1** | Merge Group A (`2.0.0`–`2.3.0`) → product lab intent synthesis | `done` → [phase-1-GROUP-A-product-lab-intent-synthesis.md](./phase-1-GROUP-A-product-lab-intent-synthesis.md) |
| **1.2** | Merge Group B plan input (`1.2.0` + `1.3.0`) → infra deployment synthesis | `done` → [phase-1-GROUP-B-infra-deployment-synthesis.md](./phase-1-GROUP-B-infra-deployment-synthesis.md) |
| **1.3** | Triage each capability / work item | `done` → [phase-1-TRIAGE.md](./phase-1-TRIAGE.md) |
| **1.4** | Route outcomes to repo home (plan / incomplete / future-state / intake) | `done` → same file |

**Exit criteria:** Every merged topic has exactly one routing label; no unassigned “chat export only” items.

**Reference-only (not merged in Phase 1 bodies):** `1.0.0`, `1.1.0`, `1.4.0` — cited from syntheses and triage.

---

## Phase 2 — Create buildable plans

**Goal:** Promote **implement now** and **buildable soon** items to governed plan packets.

| TODO | What to do | Status |
|------|------------|--------|
| **2.1** | Promote routed items to `docs/plans/YYYY-MM-DD--slug/README.md` (diagram gate + change contract) | `pending` |
| **2.2** | GitHub issues for durable tracking (optional) | `pending` |
| **2.3** | No execution from raw chat exports | `pending` |

**Blocked until:** Phase 0 exit criteria met (or explicit waiver per topic in `ASSESSMENT.md`) **and** Phase 1 exit criteria met.

---

## Phase 3 — Execute

**Goal:** Apply approved plans on the homelab with verification evidence.

| TODO | What to do | Status |
|------|------------|--------|
| **3.1** | Run playbooks / NetBox seed per plan packet | `pending` |
| **3.2** | Plan verification receipt — all in-scope obligations `pass` or documented `blocked` | `pending` |
| **3.3** | Do not mark intake archive “done” until live apply evidence exists where plan scope requires it | `pending` |

**Blocked until:** Phase 2 plan(s) approved and `lifecycle` ready for execute.

---

## Phase 1 session log

| When | Note |
|------|------|
| 2026-05-29 | Phase 1 started: GROUP-A and GROUP-B synthesis files created. |
| 2026-05-29 | `phase-1-TRIAGE.md` added: B-01–B-14 + A-01–A-08 routed (provisional). |
| 2026-05-29 | **Phase 0 complete:** three parallel agents + [ASSESSMENT.md](./ASSESSMENT.md); safe 0.6 docs; Phase 1 marked `complete`. |
| 2026-05-29 | **Phase 0R started:** operator host mapping; vLLM/Ollama/OpenClaw docs. |
| 2026-05-29 | **Capability evaluation:** full 1.1.0 generic→resource matrix (models, Langfuse, agents, catalog, trace links). |
| 2026-05-29 | **Retracted:** `gpu_lane_id`, `homelab_gpu_lanes.yml`, NetBox `gpu-lane-*` tags — intake lane phrases stay evaluation-only; map to `hom-lab-ctl-hvh-*` + existing groups. |

---

## Quick links

| Artifact | Purpose |
|----------|---------|
| [README.md](./README.md) | Archive index and merge rules |
| [phase-1-GROUP-A-product-lab-intent-synthesis.md](./phase-1-GROUP-A-product-lab-intent-synthesis.md) | Merged `2.0.x` |
| [phase-1-GROUP-B-infra-deployment-synthesis.md](./phase-1-GROUP-B-infra-deployment-synthesis.md) | Merged `1.2.0` / `1.3.0` |
| [phase-1-TRIAGE.md](./phase-1-TRIAGE.md) | Routing table (1.3 / 1.4) |
| [ASSESSMENT.md](./ASSESSMENT.md) | Phase 0 exit — repo gap vs intake |
| [capability-requirements-to-resources-evaluation.md](./capability-requirements-to-resources-evaluation.md) | **Primary** — generic needs → models, hosts, plans |
| [agent-workflow-phase2-planning-discussion.md](./agent-workflow-phase2-planning-discussion.md) | Phase 2 planner/coder/tester (first 5) |
| [reconciliation-workflow-discussion.md](./reconciliation-workflow-discussion.md) | Why reconciliation continues; workstream order |
| [vllm-architecture-discussion.md](./vllm-architecture-discussion.md) | What vLLM is; one-server vs many |
| [host-role-reconciliation-discussion.md](./host-role-reconciliation-discussion.md) | 1st/2nd/3rd host operator truth |
| [gpu-lane-and-model-lane-mapping-evaluation.md](./gpu-lane-and-model-lane-mapping-evaluation.md) | Model lanes → schema + LiteLLM; 5090 job list → hvh-02 deployments; no intake lane SSOT |
| [gpu-host-inventory-evaluation.md](./gpu-host-inventory-evaluation.md) | GPU models per machine |
| [placeholder-to-implementation-reconciliation-evaluation.md](./placeholder-to-implementation-reconciliation-evaluation.md) | Ollama→vLLM, models, OpenClaw |
| [ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md) | Canonical layer vocabulary |

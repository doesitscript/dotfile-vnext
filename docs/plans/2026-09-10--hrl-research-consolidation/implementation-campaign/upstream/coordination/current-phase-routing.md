---
contract_version: 1
pipeline_id: "hrl-research-consolidation"
stage_id: "preparation"
task_id: "hrl-research-consolidation"
run_id: "hrl-preparation-20260911-r2"
mode: "orchestrated"
session_id: "hrl-research-consolidation-preparation-ppid42220"
owner_manifest_path: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/runtime/processes-42220.json"
source_plan_root: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation"
preparation_output_root: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2"
project_root: "/Users/joshc/develop/dotfile-vnext"
status: "research_requested"
next_actor: "Researcher"
---

# Current-phase routing

## Identity and runtime envelope

- Pipeline/task/run: `hrl-research-consolidation` / `hrl-research-consolidation` / `hrl-preparation-20260911-r2`.
- Source plan (read-only): `/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation`.
- Generated-artifact root: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2`.
- Project (read-only): `/Users/joshc/develop/dotfile-vnext`; HRL (read-only): `/Users/joshc/develop/homelab-reference-library`.
- No upstream handoff was supplied.
- Parent observation recorded `2026-09-11T03:59:47.715216+00:00`: dashboard `http://127.0.0.1:7900` reachable and healthy; the named session was active. This is parent-recorded runtime evidence, not a role-local probe.

## Desired outcome

Produce a reviewed, decision-ready handoff for the established Implementer/Evaluator: consolidate the existing HRL storage and infrastructure research into a bounded future implementation plan. This preparation pass must identify supported approaches, unknowns, likely owning Ansible surfaces or discovery steps, live preflights, verification evidence, and undo boundaries. It does not implement, apply, commit, or approve infrastructure work.

## In-scope obligations

1. Consolidate current Context7/HRL evidence across containerd, Hugging Face cache, Kubernetes/K3s storage, vLLM, and Ansible into actionable storage/cache/cleanup/monitoring work slices.
2. Establish whether incomplete Ansible research and uninspected K3s, systemd, Prometheus, and Windows Server material block particular slices or can be bounded as discovery.
3. Map future ownership to existing Ansible roles/playbooks/inventory only where current evidence supports it; otherwise name a precise read-only discovery task.
4. Preserve separation between research facts, planned changes, live state, and completed execution; define later Apply, Verify, Undo, preflight, and Evaluator evidence requirements.
5. Account for the source plan's requested unified plan and baseline diagrams, including architecture, capability routing, and naming/modeling treatment.
6. Preserve the source plan's staged order: research review/consolidation before future implementation; no host mutation, role edits, runtime activation, or version-control action in this preparation stage.

## Constraints and non-goals

- All source-plan, project, and HRL paths are read-only for this run. Only this output root may receive role artifacts.
- The current source material is planning/reported evidence, not live host proof. Do not select a host, mount point, VHDX, schedule, retention threshold, or destructive cleanup target without later verified discovery and authorization.
- Do not broaden this into a whole-project audit, recreate past cleanup, start downstream roles, or represent a handoff as execution authority.
- Commit status and any count of uncommitted HRL files require fresh repository evidence before a later actor treats them as current.

## Sourced facts and evidence posture

| Fact | Label | Source |
| --- | --- | --- |
| The source plan targets HRL research consolidation for storage optimization and infrastructure automation, with a future `plan.md` and later Ansible implementation. | verified (source-plan statement) | `README.md` (SHA-256 `624724e81f1cf7086c58adf3b5d7f570989ae16206dfed948724ba772ed3a7c6`) |
| The source identifies containerd cleanup, HF cache management, storage/cache offload, artifact retention, disk monitoring, and Ansible integration as consolidation themes. | verified (source-plan statement) | `README.md`, `research-index.md` (SHA-256 `905d82d818562929deec4b42de18f3cb8c8455af57a3499d11d35a9cc4cc83e5`) |
| Five Ansible topics and inspection of K3s/systemd/Prometheus/Windows Server material were still described as incomplete or pending. | reported | `README.md`; `findings-report.md` (SHA-256 `5de5da345c4d6c7423e1af50e3348940531cb49e01d84697c070cacf7679d822`) |
| Existing role candidates named by the source are `roles/hyperv_ubuntu_vm/`, `roles/k3s_vllm_runtime/`, and `roles/k3s_comfyui_runtime/`. | reported; ownership not yet verified | `README.md`, `research-index.md` |
| Source-reported historical storage observations include k3s-02 disk pressure, a 19GB vLLM HF cache, PVC overcommit, a minimal image-prune recovery, and earlier reclaimed space. | reported; requires later live verification | `findings-report.md`, `research-index.md` |
| A parent-provided observation recorded a healthy reachable dashboard and active named session. | verified (parent observation receipt) | `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/runtime/dashboard-observation.json` |
| Actual current HRL entry contents, Ansible interfaces/inventory, host topology, cache placement, schedules, and safe cleanup candidates. | unknown | requires bounded read-only discovery |

## Required Researcher brief

Use the preparation source map before broad retrieval:

- project workflow: `docs/codex_framework/multi-agent/agent-workflow-registry/patterns/evaluator-implementer-loop.md`;
- Ansible gate: `.cursor/skills/ansible-knowledge-gate/SKILL.md`;
- HRL advisory and Ansible domain map: `agents/domain-librarian-advisory/AGENT.md` and `agents/domain-librarian-advisory/domains/ansible.md`;
- HRL multiagents material: `implementation-guides/multiagents/README.md` and `vendor/multiagents/README.md`.

The brief must include: source-backed current-state facts with labels; actual HRL evidence paths/decision files; recommended and rejected patterns with reasons; whether missing research blocks each work slice; current role/playbook/inventory ownership or exact discovery commands/paths; live preflights; Apply/Verify/Undo and change class proposals; measurable Implementer acceptance/Evaluator evidence; and decision-relevant open gaps. It must distinguish source-reported history from a present host claim.

## Questions for research

1. Which cited HRL decision files and implementation guides currently exist, and what selected/rejected approaches and confidence do they actually record for each proposed storage/cache/cleanup slice?
2. Do the five named Ansible topics and uninspected technologies leave a concrete safety, ownership, or quality-gate blocker for any slice, and what is the smallest research/discovery action for each blocker?
3. Which existing Ansible roles, playbooks, inventories, variables, and validation conventions own the likely changes, or where is ownership genuinely unknown?
4. What read-only live preflights are required before any containerd, HF-cache, PVC, VHDX/mount, retention, or monitoring change, including target identity and rollback evidence?
5. Which diagrams and modeling/naming decisions are required by the source-plan scope, and what baseline can be drawn now without inventing live architecture?

## Handoff event

Event: `research_requested`.

Artifact: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/coordination/current-phase-routing.md`.

Next actor: `Researcher`.

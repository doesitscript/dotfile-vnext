---
title: Materialized Expert Best recommendations — storage layout
campaign_id: hrl-storage-implementation-beta-01
decision_authority_profile: lab_recreatable_autonomy
status: adopted-for-light
authority: internal
source_type: internal
replaces: implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
---

# Expert Best recommendations (materialized)

This file is the durable `expert_recommendation_path` for Light parent runs.
It does **not** reopen research. It restates evidence-backed Expert **Best** /
**Preference** already adopted under `lab_recreatable_autonomy`.

Primary decision package for Implementer/Evaluator remains:
`multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md`.

Provenance ledger:
`multi-agent-design/orchestration/examples/storage-layout-research-transforms/decisions-and-authorization.md`
and
`.../performance-layout-adoption.md`.

## Profile rule

Under `lab_recreatable_autonomy`, auto-adopt these Best/Preference rows as the
technical default. Do **not** ask the operator which option to pick. Keep exact
target identity, fail-closed gates, receipts, and Evaluator review.

## Adopted defaults (do not re-debate)

| Area | Class | Selected default |
| --- | --- | --- |
| S2 / image GC | Best | No-change: keep kubelet GC; do not invent `config.toml.tmpl` / prune timers for this incident |
| S3 / HF cache | Best | `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`; token on durable root; retain source until cutover health; no PVC deletion as relocate; no `TRANSFORMERS_CACHE`; no `huggingface-cli` |
| S4 / NVMe | Preference | Second fixed 200 GiB VHDX → guest `/mnt/k3s-cache` for HF + containerd bind + new local-path; fail-closed on by-id/serial; Light encodes source only |
| S5 / monitoring | Preference | Host-native timer + existing journald→Alloy→Loki; journal/swap on SATA only after identity proof; cap pod logs on root |
| C3 / containerd template | Best | If ever authorized: `config-v3.toml.tmpl` + `{{ template "base" . }}` — do not invent a template in Light |

## Operator binding (already recorded)

`coordination/operator-resolution-2026-09-11-offload-everywhere.md`:

- Offload rebuildable/relocatable data per refined handoff / HRL Best
- Advance all ready Light functional areas in the work queue
- Do not ask which of S1–S6 to pick next
- `live-attach-and-apply` stays Full / Apply-gated

## What still is not human-optional

- **Guessing** an unproven disk by-id / serial — Expert must find it via
  inventory/receipts or read-only live probe (Ansible / SSH bash /
  Windows PowerShell helpers)
- Silent Apply / attach / format without an explicit Apply-authorized step
- Destructive delete of retained cache without gates

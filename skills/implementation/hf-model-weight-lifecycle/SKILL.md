---
name: hf-model-weight-lifecycle
description: "Use when downloading, removing, or commissioning Hugging Face model weights on the HVH-01 share in dotfile-vnext, and when those weights must be owned by Ansible present|absent rather than ad-hoc snapshot_download. Use for download this HF model to the share, remove DiffuCoder weights, model_catalog unc_path lifecycle, or commission weights before LiteLLM/Continue. Do not use for Hub client pip install alone (use windows-tool-capability-intake / huggingface_hub role) or for authoring HRL model-doc packs (use model-doc-pack-preflight + HRL)."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "model-doc-pack-preflight, ansible-knowledge-gate, windows-tool-capability-intake, single-host-ansible-rollout"
requires_summary: "AGENTS.md §32; inventory/group_vars/model_catalog/manifest.yml; roles/huggingface_hub; HRL model-doc-pack when available"
title: HF Model Weight Lifecycle
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - huggingface
  - model-catalog
  - litellm
related:
  - inventory/group_vars/model_catalog/manifest.yml
  - roles/huggingface_hub/
  - roles/k3s_litellm_gateway/
  - roles/continue_ide/
tags:
  - skill
  - ansible
  - huggingface
  - model-weights
  - lifecycle
---

# Skill: HF Model Weight Lifecycle

Own Hugging Face **weight trees** on the homelab share with Ansible
`present|absent`. Catalog rows and LiteLLM stubs are not enough.

## When to use / not use

Use when the user asks to download, remove, or commission model weights under
`F:\shares\public\models\huggingface\` (or the catalog `unc_path`).

Do not use for installing `huggingface_hub` / `hf` CLI only — that is
`windows-tool-capability-intake` + `roles/huggingface_hub`.

Do not author durable model cards here — run `model-doc-pack-preflight` / HRL.

## Hard rules

1. **No ad-hoc** `snapshot_download` / scp scripts on HVH hosts.
2. Weights capability must expose `*_state: present|absent` (role or clear owner).
3. **Download ≠ serve ≠ route.** Do not add Continue/LiteLLM live aliases until a
   serving backend exists. Empty `api_base` stubs are not “integrated.”
4. Catalog `status: downloaded` only after Ansible `present` succeeded with evidence.

## Workflow

1. Run `model-doc-pack-preflight` (HRL) for the model family.
2. Run `ansible-knowledge-gate`; confirm `roles/huggingface_hub` is present on the
   storage host (Hub client ≠ weights).
3. Inspect `inventory/group_vars/model_catalog/manifest.yml` for an existing lane /
   `unc_path`. Prefer extending an owner role over a one-off playbook.
4. If no weight lifecycle role exists yet, scaffold one with:
   - `*_state: present|absent`
   - present: ensure destination dir + idempotent HF download via managed tasks
     (Hub client from `huggingface_hub` role; no SSH pip snowflakes)
   - absent: remove only the owned weight tree
   - README Apply/Verify/Undo; playbook wiring that preserves both states
5. Update catalog row after converge (status, unc_path, research notes).
6. Do **not** enable LiteLLM `model_list` / Continue entries until serving is ready;
   keep lanes `blocked` or omit client aliases.
7. Hand off live apply to `single-host-ansible-rollout` on `HOM-LAB-HVH-01`.

## Handoffs

- `model-doc-pack-preflight`
- `windows-tool-capability-intake` (Hub client / Windows tool shape)
- `single-host-ansible-rollout`
- `tool-capability-intake` when the broader tool/role placement is still open

## Outputs

- Owner role/playbook decision with present|absent
- Catalog update plan
- Explicit “not routed to LiteLLM/Continue yet” statement when serve is missing
- Apply/Verify/Undo/Change-class summary

## Validation

- Weight tree exists or is absent per state, with Ansible evidence (not SSH narration)
- Catalog matches disk
- Continue/LiteLLM do not advertise aliases without backends

## Failure boundaries

- Stop if serve path requires an OpenAI wrapper / vLLM image still under research
- Stop if disk/share path is wrong or host is unreachable — collect connection evidence

## Prohibited behavior

- Ad-hoc `pip install huggingface_hub` then `snapshot_download` over SSH
- Marking catalog `downloaded` without Ansible present evidence
- Pointing Continue at aliases that are not in LiteLLM `/v1/models`

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking authority.
- Load `references/related-artifacts.md` for likely repo touch points.

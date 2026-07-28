---
name: tune-litellm-context-safety-net
description: "Use when changing LiteLLM Request Inspector thresholds or context-window fallbacks for Cursor on the local 32k vLLM path — max_window, warn percentages, dump-on-warn, OpenAI vault key fallbacks, or redeploying the callback ConfigMap. The former trim_messages mutate path is archived under roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/. Do not use for tools[] capture-only work or for DNS/service reachability."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "litellm-cursor-traffic-analyzer, single-host-ansible-rollout, capture-litellm-tools-payload"
requires_summary: "roles/k3s_litellm_gateway defaults; vault/shared.vault.yml; playbooks/deploy_litellm_gateway.yaml; bin/codex-env"
title: Tune LiteLLM Context Safety Net
technology: litellm
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - litellm
  - ansible
  - implementation
related:
  - roles/k3s_litellm_gateway/defaults/main.yml
  - roles/k3s_litellm_gateway/README.md
  - vault/shared.vault.yml
  - playbooks/deploy_litellm_gateway.yaml
tags:
  - skill
  - litellm
  - trim
  - fallback
  - implementation
---

# Skill: Tune LiteLLM Context Safety Net

Change and redeploy gateway context observability / fallbacks with an explicit
Apply / Verify / Undo contract.

**Note (2026-07):** Live callback is **Request Inspector** (observe-only). The
former `trim_messages` mutate path lives under
`roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/`. This skill
still owns inspector threshold vars and `context_window_fallbacks`.

## When to use / not use

Use when adjusting trim drivers, completion floors, or enabling cloud
`context_window_fallbacks` via vault OpenAI/Anthropic keys.

Do not use for capture-only analysis → `capture-litellm-tools-payload`.
Do not use when the real need is a larger local context model (research first).

## Inputs

- Target symptom (overflow, mid-stream length cut, amnesia under tools tax)
- Current defaults in `roles/k3s_litellm_gateway/defaults/main.yml`
- Whether `vault_shared_openai_api_key` / Anthropic keys should be set

## Workflow

1. Map symptom → driver using README § Message trim / mid-stream notes:
   - overflow after trim → lower input budget / raise safety / enable cloud fallback
   - mid-stream cut → raise `min_completion_tokens` (adaptive path already caps under tools)
   - amnesia → tools tax; trimming alone cannot invent context — consider Ask mode or cloud fallback
2. State Apply / Verify / Undo / Change class before editing.
3. Edit role defaults or inventory overrides; keep variable `k3s_litellm_gateway_` prefix.
4. Redeploy: `playbooks/deploy_litellm_gateway.yaml` limited to `hom-lab-ctl-k3s-02`
   (ConfigMap `subPath` requires Deployment restart — role handles this).
5. Verify with a probe and/or Agent request; confirm hook log
   `requested_out=`, `budget=`, `tools_est=`.
6. For host-scoped Ansible execution mechanics, hand off to
   `single-host-ansible-rollout` when useful.

## Handoffs

- `single-host-ansible-rollout` for preview/apply evidence discipline
- `capture-litellm-tools-payload` when tools tax must be re-measured after a change
- `litellm-cursor-traffic-analyzer` for symptom reclassification

## Outputs

- Updated role/inventory values
- Redeploy result
- Hook log verification lines
- Explicit note if cloud fallback remains disabled (`Fallbacks=None`)

## Validation

- Callback file on pod matches intended constants (`_MIN_COMPLETION_TOKENS`, etc.)
- Redeploy remounted the ConfigMap (restart task ran when trim enabled)
- Post-change probe or Agent log shows expected `requested_out` / budget behavior

## Failure boundaries

- Escalate before storing a real OpenAI/Anthropic key if the operator has not
  approved cloud fallthrough
- Stop after two failed redeploy/fix cycles without artifacts — enter
  troubleshooting with diagnostics doc

## Prohibited behavior

- Claiming Cursor Task/Shell schemas can be shortened by Ansible trim knobs
- Disabling the trim hook without an alternate overflow path
- Skipping Deployment remount after callback-only ConfigMap edits

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for driver mapping.
- Load `references/related-artifacts.md` for variables and deploy commands.
- Receipt: `skills/_shared/verification-receipt-template.md`

---
title: vLLM idle desktop usability patterns
status: brainstorm
execution_status: not_started
created_at: 2026-09-23
---

# vLLM idle desktop usability patterns

Brainstorm packet only. Not approved implementation scope. Not active repo
truth until promoted through `docs/intake/` or `docs/plans/`.

## Intent

Capture an operator idea: after LiteLLM/vLLM lab use on the shared RTX 5090
(HVH-02 / k3s-02), automatically free GPU memory when the model has been idle,
so the host can feel like a normal desktop again — without day-to-day Ansible
or Mac-side control.

## Packet files

| File | Purpose |
| --- | --- |
| [operator-proposal-idle-watcher.md](operator-proposal-idle-watcher.md) | Operator-stated idea (preserved as proposed) |
| [vllm-idle-unload-wip-ai-human-plan.md](vllm-idle-unload-wip-ai-human-plan.md) | AI assessment + WIP human-readable plan shape |

## Related live surfaces (reference only)

- `roles/k3s_vllm_runtime` / `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`
- `docs/reference/k3s-02-gpu-timeshare-phase-b.md` (manual present/absent timeshare)
- Conversation thread 2026-09-22/23 (VRAM residency vs Ollama keep_alive vs sleep mode)

## Treat as

- Idea archive + assessment
- Do not implement from this packet unless the user promotes and executes a plan

## Convention note

This packet is the reference **dual-file** example for
`docs/brainstorming_designs/README.md` (operator proposal +
`*-wip-ai-human-plan.md`). Scaffold future similar requests with skill
`brainstorm-design-packet-scaffold`.

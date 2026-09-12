---
request_id: demo-c1-hf-hub-cache-vs-transformers-cache
campaign_id: hrl-storage-implementation-beta-01
return_to: implementer
status: open
---

# Consultation request — demo: HF cache env var choice

## Exact technical fork

For `roles/k3s_vllm_runtime` on this recreatable lab, should the vLLM Deployment
set `HF_HUB_CACHE` or `TRANSFORMERS_CACHE` for model cache on
`/mnt/k3s-cache/hf/hub`, and where should the Hugging Face token live relative
to that cache tree?

## Already known (do not re-research from scratch)

- Refined handoff:
  `multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md` (C1)
- Best list:
  `implementation-campaign/coordination/expert-best-recommendations--storage-layout.md`
- Research application / hard corrections:
  `multi-agent-design/multi-agent-onsite-expert/examples/storage-performance-research-application.md`
- Owner: `roles/k3s_vllm_runtime/**`

## Why Implementer cannot auto-adopt

This is a **demo consultation**: Implementer deliberately asks Expert to answer
the fork so we can prove Expert-on-call works, even though C1 is already settled.

## Acceptance test for the Expert answer

Expert must return a **Best recommendation** that names:

1. which env var to use (and which to forbid)
2. default path under the NVMe mount
3. where the token must stay (durable root / Secret vs NVMe cache tree)
4. affected owner (`roles/k3s_vllm_runtime`)

## Out of scope

Apply, inventing disk by-id, whole-campaign replan, asking the human.
(This C1 demo does not require a live disk probe; other Expert requests may.)

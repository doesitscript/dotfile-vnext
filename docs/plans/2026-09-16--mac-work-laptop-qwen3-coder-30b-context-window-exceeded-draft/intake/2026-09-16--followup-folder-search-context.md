---
title: Follow-up operator context — unstructured folder search overflow
captured_at: "2026-09-16"
confirmation_status: unconfirmed
---

# Follow-up operator context

Operator clarified (same Mac work-laptop incident):

- The chat/agent was **searching through a largely unstructured folder**.
- Context overflowed **quickly**.
- Suspects either lab/gateway evidence can explain the blow-up, **and/or**
  client misconfiguration / **drift on that laptop**.

## Lab SSOT note (not live confirmation)

Repo Continue chat defaults for `qwen3-coder-30b-a3b` intentionally set:

- `contextLength: 32768`
- `maxTokens: 4096`

Comment in role defaults: input + maxTokens must stay ≤ 32768. The pasted
error (28673 input + 4096 output ≥ 32769) matches that budget edge exactly
when a large folder-search / tool / history payload fills the input side.

## Evidence surfaces to query next (see parent README / analyze-litellm skill)

1. LiteLLM pod logs: `litellm request_inspector` JSON lines (budget slices) +
   `ContextWindowExceededError` / `Hosted_vllmException`
2. Optional tools dump under pod `/tmp/litellm-tools-capture/` if tools[] was large
3. Langfuse: **success** traces only by default — this failure may be absent
4. Mac client: `~/.continue/config.yaml` vs Ansible `continue_ide` managed block

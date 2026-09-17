---
title: Conversation and operator report — Qwen3-Coder-30B context window exceeded
captured_at: "2026-09-16"
source_host_surface: Mac work laptop
confirmation_status: unconfirmed
possible_drift: true
fix_attempted: false
---

# Conversation and operator report

## Conversation framing (this thread)

Operator asked to create a plan packet per the repo plan process for an error
observed on the **Mac work laptop**. Explicit constraints:

- Do **not** fix the issue in this turn.
- Treat the finding as **not confirmed** because the Mac work-laptop
  implementation may be **deprecated or out of sync**.
- Put this conversation and the reporting into an **`intake/`** folder inside
  the new plan packet.
- Name the plan folder for the symptom being seen.
- Suffix the folder with **`-draft`** because of possible drift.

Agent response: created draft plan packet only; no runtime or client changes.

## What was seen (operator report)

Surface: Mac work laptop chat UI labeled approximately:

> Chat Qwen3-Coder-30B-A3B (5090 vLLM)

Symptom: client showed an error handling the model response and asked the user
to resubmit. Underlying gateway/provider error was LiteLLM
`ContextWindowExceededError` / `BadRequestError` from Hosted vLLM.

### Parsed fields from the error

| Field | Value |
| --- | --- |
| HTTP / LiteLLM class | 400 / `litellm.ContextWindowExceededError` |
| Backend exception shape | `Hosted_vllmException` / `BadRequestError` |
| Model max context | 32768 tokens |
| Requested output tokens | 4096 |
| Reported input tokens | at least 28673 |
| Reported total | at least 32769 |
| Received model group | `qwen3-coder-30b-a3b` |
| Available model group fallbacks | None |
| Fallback error | same `ContextWindowExceededError` |

### Operator-facing message (paraphrase)

There was an error handling the response from Chat Qwen3-Coder-30B-A3B
(5090 vLLM). Please try to submit your message again.

### Verbatim error

See [raw-error.txt](raw-error.txt).

## Why this is intake, not a defect verdict

1. Evidence is a **paste from the Mac work laptop**, not a fresh probe from a
   managed verification playbook.
2. Mac work-laptop client wiring may lag Ansible SSOT (Continue/IDE profiles,
   `max_tokens`, context injection).
3. Arithmetic in the error is internally consistent (28673 + 4096 ≥ 32769) but
   does not identify whether the oversized input came from chat history, rules,
   tools, or a drifted client default.
4. No Apply was authorized; no reproduction was run in this conversation.

## Suggested next evidence (not executed here)

- Capture Mac Continue/Cursor config paths and `max_tokens` / model id for the
  failing chat profile.
- Compare to `inventory/group_vars/continue_ide_hosts/main.yml` and LiteLLM
  model-list / client profile SSOT.
- Issue one controlled chat-completions call to `qwen3-coder-30b-a3b` with a
  known prompt size and known `max_tokens` to see whether the gateway still
  rejects near the 32k boundary the same way.

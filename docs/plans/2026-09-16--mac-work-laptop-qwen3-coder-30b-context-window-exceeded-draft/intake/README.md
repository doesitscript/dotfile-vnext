# Intake — Mac work laptop Qwen3-Coder-30B context window exceeded

This folder holds the original operator report and conversation framing for
draft plan
`2026-09-16--mac-work-laptop-qwen3-coder-30b-context-window-exceeded-draft`.

## Contents

| File | What it is |
| --- | --- |
| [2026-09-16--conversation-and-operator-report.md](2026-09-16--conversation-and-operator-report.md) | Conversation intent + structured report of what was seen |
| [raw-error.txt](raw-error.txt) | Verbatim error string from the Mac work laptop |

## Confirmation gates (before any fix work)

1. **Drift check:** Diff Mac work-laptop Continue/IDE LiteLLM client settings
   against current Ansible-managed SSOT for the intended host/group.
2. **Repro check:** Reproduce (or fail to reproduce) the same
   `ContextWindowExceededError` from a known-current managed client against
   `qwen3-coder-30b-a3b` with comparable prompt size and `max_tokens`.
3. **Attribution:** Separate (a) oversized prompt / always-on context,
   (b) client-requested `max_tokens=4096`, (c) gateway/backend max_model_len,
   (d) Mac-only stale config.

Until those gates run, treat the report as **unconfirmed observational intake**.

# LiteLLM / vLLM context — current guidance

**Updated:** 2026-09-09.

## Do not use this path for “why is 32B broken?”

The historical write-up that blamed **LiteLLM `trim_messages` / overflow
trimming** as the primary operational story is **outdated**. It was moved on
**2026-09-09** to:

`docs/diagnostics/archive/litellm-context-window--k3s--diagnostics--outdated-2026-09-09.md`

That archive is historical only (2026-07-era mutate safety net). **We are not
trimming requests anymore.** Live gateway callback is Request Inspector
(**observe-only**). Do not revive trim as the default diagnosis.

## Actual root cause for weak / “not fully working” 32B coding

The problem that mattered was an **untuned model placement on the 5090**, not
client contextLength headroom or a missing trim hook:

- **Before:** 14B AWQ at 32k with default KV — VRAM looked full (~29 GB) while
  capability stayed at 14B.
- **After:** 32B Instruct AWQ at the **same 32k** with **fp8 KV**,
  `gpu-memory-utilization ~0.92`, `max-num-seqs 4`.

Authority:

- `docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/diagrams/5090-vram-tuning-before-after.md`
- Diagram: same folder `5090-vram-tuning-before-after.svg`

## Live LiteLLM behavior (2026-09)

| Surface | Status |
| --- | --- |
| `trim_messages` mutate | **Archived** — `roles/k3s_litellm_gateway/archive/trim-messages-callback-2026-07/` |
| Request Inspector | **Live, observe-only** — does not rewrite prompts |
| Primary coding backend | `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` on vllm-primary (5090); chat live, tool acceptance pending |

Gateway role README: `roles/k3s_litellm_gateway/README.md` § AI Request Inspector.

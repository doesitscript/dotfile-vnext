# 2026-09-12 — Qwen3-Coder config evaluation packet

Canonical home (dotfile-vnext model-lane acceptance retros):

`model-lane-acceptance/discuss_implementations_retros/retro_all/2026-09-12-qwen3-coder-config-evaluation/`

| File | Purpose |
| --- | --- |
| `2026-09-12-qwen3-coder-config-evaluation.md` | Evaluation report |
| `01-actors-retro-capture.yml` | Filled retro template — all actors + before/after values |
| `02-assessment-and-proposal.md` | Numbered assessment + proposal |
| `diagrams/before.md` + `before_config.svg` | “Cup overflow” picture |
| `diagrams/after.md` + `after_config.svg` | Same cup after budget/embed fix |
| `diagrams/*_config.py` | Mingrammer sources (create-diagrams intermediate) |

**Verdict:** keep `qwen3-coder-30b-a3b`; fix Continue `maxTokens` 8192→4096, sole embed, LiteLLM caps — not a model swap.

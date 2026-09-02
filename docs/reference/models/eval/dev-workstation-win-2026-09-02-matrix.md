# dev-workstation-win model fit matrix

Date: 2026-09-02
Host: `dev-workstation-win`
Hardware target: AMD Radeon RX 9060 XT 16GB
Runtime target: Windows Ollama on `E:\ai\models\ollama`
Primary question: what local model best fits this machine for an improved
desktop coding and reasoning lane?

## Scoring

Scale:

- `5` = strong fit
- `3` = workable with caveats
- `1` = poor fit
- `0` = blocked or not credible

Categories:

- hardware fit
- runtime fit
- workload fit
- operational fit

## Matrix

| Candidate | Hardware fit | Runtime fit | Workload fit | Operational fit | Total | Result | Note |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| `gpt-oss:20b` | 4 | 4 | 4 | 4 | 16 | Selected for host presence | Current best 16GB-class candidate from OpenAI + Ollama packaging evidence; still needs live Codex tool-loop proof. |
| `qwen2.5-coder:14b` | 4 | 4 | 1 | 3 | 12 | Rejected for Codex lane | Fits on paper, but prior observed behavior emitted JSON-shaped tool requests without completing the loop. |
| `ministral-3:8b` | 5 | 4 | 3 | 4 | 16 | Keep as fallback | Smaller and practical; better operational fallback than primary target for richer desktop reasoning. |
| `qwen3-coder:30b` | 1 | 3 | 4 | 1 | 9 | Reject on 16GB | Too large for an honest interactive fit on this hardware class. |
| `qwen3.6:27b` | 1 | 3 | 4 | 1 | 9 | Reject on 16GB | Same problem: packaging size leaves too little headroom. |
| `devstral:24b` | 2 | 2 | 3 | 2 | 9 | Defer | Current vendor guidance is heavier and the older small-model page is already deprecated. |

## Interpretation

- `gpt-oss:20b` and `ministral-3:8b` both survive the first pass, but for
  different reasons.
- `gpt-oss:20b` is the better candidate when the goal is a more capable local
  reasoning/coding model on a 16GB-class desktop.
- `ministral-3:8b` remains valuable as an operational fallback and as the safer
  currently selected `codex-homelab desktop` lane on `mac-dev`.
- `qwen2.5-coder:14b` is not disqualified as a generic chat model, but it is
  not currently trusted for the specific Codex tool-using path that triggered
  this evaluation.

## Missing evidence

- successful live deployment of `gpt-oss:20b` to this host from the controller
- post-deploy `/api/tags` proof
- Codex-style tool-call task through the actual LiteLLM/Codex path
- latency and context-window measurements on the live desktop

## Promotion rule

Do not promote a new desktop implementation lane from this matrix alone. A lane
change requires:

1. host model present
2. live probe success
3. workload acceptance check success
4. explicit lane publication decision

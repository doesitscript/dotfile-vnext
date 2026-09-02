<!-- EXAMPLE ONLY — stack implementer intake artifact for ATDD coordination.
     Author of this snapshot: Codex (OpenAI), Codex CLI campaign Sep 2026.
     Future stack implementer agents and model/client selections will differ.
     This is configuration truth, not acceptance approval. -->

# Local AI Client Model Map (example intake)

**Example campaign:** Codex CLI + referenced Continue/Kilo routes (Sep 2026).  
**Scope:** models explicitly configured by the local-client implementation.  
Routes use the LiteLLM `model@host` contract at `http://litellm.hom.lab/v1`.

## VS Code-Compatible Extension: Continue

Continue is the configured VS Code-compatible extension (also used from
Cursor). Its generated `~/.continue/config.yaml` has these selected lanes:

| Continue role | LiteLLM route | Hosted model | Status |
| --- | --- | --- | --- |
| Chat / quality coding | `qwen2.5-coder-32b@k3s02-vllm` | `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` on RTX 5090 vLLM | Selected and validated |
| Edit / apply | `qwen2.5-coder-7b@desktop` | Qwen2.5-Coder 7B Instruct on desktop Ollama | Selected and validated |
| Inline autocomplete / FIM | `qwen2.5-coder-1.5b@hvh01` | Qwen2.5-Coder 1.5B Instruct on HVH-01 Ollama | Selected and validated |

```text
dotfile-vnext/
├── inventory/host_vars/mac-dev.yaml
├── roles/continue_ide/
└── docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/
```

## Codex CLI: Explicit Terminal Profiles

`~/bin/codex-homelab <profile>` selects one profile at a time.

| Terminal / profile | LiteLLM route | Intended work | Current qualification |
| --- | --- | --- | --- |
| `codex-homelab deep` / `local-deep` | `qwen2.5-coder-32b@k3s02-vllm` | Repository reasoning and implementation | Approved for response/reasoning; shell tool loop not approved |
| `codex-homelab fast` / `local-fast` | `qwen2.5-coder-7b@desktop` | Short coding questions | Experimental |
| `codex-homelab tools` / `local-tools` | `ministral-3-8b@desktop` | Alternate local tool candidate | Experimental |
| `codex --profile hom-lab` / `hom-lab` | `qwen2.5-coder-7b@desktop` | Compatibility profile | Experimental |

```text
dotfile-vnext/docs/plans/2026-09-01--homelab-local-ai-clients-codex/
├── templates/local-deep.config.toml
├── scripts/codex_homelab.sh
└── codex-execution-receipt.md
```

## Current Boundary

The 32B model is shared by Continue quality chat and Codex deep reasoning as one
5090 vLLM service. Passing response contracts prove chat/reasoning; unexecuted exec
JSON is a failed tool-loop contract, not tool execution.

## Acceptance author use

Diff this map against `model-lane-acceptance/client-map.yml`; author pending
acceptance YAML for non-approved rows; run probes via `model-lane-acceptance/scripts/`.

Request template: [../references/stack-implementer-intake-request.md](../references/stack-implementer-intake-request.md)

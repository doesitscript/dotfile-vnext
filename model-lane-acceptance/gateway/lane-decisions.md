# Gateway lane decisions (dotfile-vnext)

**Manifest SSOT:** [`manifest.yml`](manifest.yml)  
**Client map:** [`../client-map.yml`](../client-map.yml)

## First pass — calibrated for this homelab

Acceptance criteria were written with knowledge of the **current fleet** and
client roles (Continue 32B/7B/1.5B, Kilo Ministral, Codex deep on 32B). The
pytest harness in global-skills is agnostic; **this YAML is data to adapt** when
models or clients change.

## Lane placement

| Lane | Client role | Tool surface | Notes |
| --- | --- | --- | --- |
| `qwen2.5-coder-32b@k3s02-vllm` | Continue chat, Codex deep | `tool_calls` + followup | 5090 vLLM |
| `qwen2.5-coder-7b@desktop` | Continue edit, OpenCode | `json_in_content` | Desktop Ollama |
| `qwen2.5-coder-1.5b@hvh01` | Continue FIM | `json_in_content` + **fim** | HVH Ollama |
| `ministral-3-8b@desktop` | Kilo agent | `tool_calls` + followup | Desktop Ollama |

## ATDD: adding or swapping a model

1. Update [`../client-map.yml`](../client-map.yml) with role and `status`.
2. Add a `lanes:` row in `manifest.yml` with `capabilities` and journey anchors.
3. Set `expect_mode` from live probe evidence — do not copy from a different runtime.
4. Keep failing criteria in [`pending/`](pending/) until receipts are green.
5. Run: `../scripts/run-gateway-acceptance.sh -v -s`

Do **not** weaken EXPECTED on an approved lane to make a different model pass.

## Pending acceptance

See [`pending/README.md`](pending/README.md) for journeys written before the
runtime is ready.

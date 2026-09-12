# Placement selection — where each model runs

## Inputs to the placement decision

1. **Client constraint:** mac-dev (Iris Pro, thermal) must not host models —
   Continue config only.
2. **Free / available infra** named in the plan:
   - HOM-LAB-HVH-01 — GTX 1060 6GB, existing Ollama secondary runtime
   - dev-workstation-win — RX 9060 XT 16GB, existing desktop Ollama
   - HOM-LAB-HVH-02 / k3s-02 — 5090 already committed to primary chat/coder vLLM
3. **Role latency & size profiles** from `continue-role-requirements.md`
4. **Existing Ansible pipelines:** `windows_ollama_runtime` pulls +
   `k3s_litellm_gateway` routes + `continue_ide` client config (not ad-hoc SSH
   pulls)

## Decision rules applied

| Rule | Effect |
| --- | --- |
| Protect primary GPU | No aux roles on 5090 / k3s-02 vLLM |
| Match size to VRAM | Tiny FIM + embed → 6GB; mid instruct → 16GB |
| Co-locate compatible loads | 1.5B-base + nomic on HVH-01; 14B edit + 7B apply on desktop |
| Prefer existing runtime | Ollama already healthy on both Windows GPU hosts; Pascal cannot run modern vLLM |
| Client sees one gateway | Continue `apiBase` = LiteLLM; backends selected by `model@host` |
| Keep Mac cold | No Jan/Ollama on mac-dev for these roles in this plan |

## Placement matrix

```text
mac-dev (Continue only)
    │
    ▼
litellm.hom.lab
    ├── chat ──────────► k3s-02 vLLM (5090)     [unchanged]
    ├── autocomplete ──► HVH-01 Ollama 1.5b-base
    ├── embed ─────────► HVH-01 Ollama nomic
    ├── edit ──────────► desktop Ollama 14b
    └── apply ─────────► desktop Ollama 7b
```

## Why not alternatives

| Alternative | Rejected because |
| --- | --- |
| Autocomplete on Mac | Thermals / no discrete GPU; plan goal was offload |
| Autocomplete on 5090 | Contends with primary chat; overkill for 1.5B |
| Embed on desktop only | Wastes 16GB lane; HVH-01 already has idle capacity next to FIM |
| Edit 14B on HVH-01 | Does not fit 6GB comfortably at useful quant |
| Direct Continue→Ollama apiBase per host | Works, but lab SSOT is LiteLLM `model@host`; same routing effect |

## Verification after placement

See `smoke-evidence-decode.md` and intake table in `plan.md`.

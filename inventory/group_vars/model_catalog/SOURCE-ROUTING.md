# Model Catalog Source Routing

Project-side map for where agents should look when filling or consulting an HRL
`model-doc-pack`. Durable documentation lives in
`homelab-reference-library/models/`; this catalog remains the lab selection and
storage authority.

## Defaults

| `serving_runtime` | `primary_doc_source` | URL pattern |
| --- | --- | --- |
| `ollama` | `ollama_library` | `https://ollama.com/library/<name>` |
| `vllm` / HF download | `huggingface_model_card` | `https://huggingface.co/<org>/<repo>` |
| custom / wrapper | `vendor_docs` or HF if present | absolute vendor URL |
| none / private | `lab_only` | inventory + operator notes |

When both Ollama tag and HF base exist: primary = Ollama library for the runtime
tag contract; set `secondary_doc_source: huggingface_model_card`.

## Per-entry fields (`source_routing`)

Add under each `model_catalog_manifest.entries[]` row when known:

```yaml
source_routing:
  primary_doc_source: huggingface_model_card  # or ollama_library | vendor_docs | lab_only
  primary_doc_url: "https://huggingface.co/org/repo"
  secondary_doc_source: null
  secondary_doc_url: null
  ollama_library_url: null
  llms_txt_url: null
  context7_library_id: null
  hrl_pack_slug: null  # models/<slug> in homelab-reference-library
  hrl_pack_status: missing  # missing | draft | reviewed
```

Legacy `research_sources` lists remain valid; prefer `source_routing` for
machine routing and keep `research_sources` as human/history links.

## Preflight

Use skill `model-doc-pack-preflight` (or global `library-first-model-doc-pack`
lookup mode) before implementing model-backed Ansible/LiteLLM changes.

Authority for pack schema:
`/Users/joshc/develop/homelab-reference-library/frameworks/model-doc-pack/SOURCE-ROUTING.md`.

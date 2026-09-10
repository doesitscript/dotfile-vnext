# Saved — Continue local role intent from host_vars

Source: `exports/work-laptop-ai-tools/host_vars/work-laptop.yaml`
key `continue_ide_ollama_local_models` (as of 2026-09-09).

These are the roles a DMR Continue block should cover. Tags are Ollama-shaped
today; remap to DMR OCI / `/models` ids when commissioning.

```yaml
continue_ide_ollama_local_models:
  - name: "Qwen 2.5 Coder 1.5B (Autocomplete Baseline)"
    model: "qwen2.5-coder:1.5b-base"
    roles: [autocomplete]
  - name: "Qwen 2.5 Coder 3B (Autocomplete Comparison)"
    model: "qwen2.5-coder:3b-base"
    roles: [autocomplete]
  - name: "Nomic Embed Text (Local Embeddings)"
    model: "nomic-embed-text"
    roles: [embed]
  - name: "Qwen 2.5 Coder 7B (Local Edit)"
    model: "qwen2.5-coder:7b-instruct"
    roles: [edit, apply]
```

Managed template today: `roles/continue_ide` block `continue-ollama-local`.
Future: either retarget that block at DMR or add `continue-dmr-local` when
automation is enabled.

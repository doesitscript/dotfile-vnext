# Related Artifacts

## Capture script

```bash
# From repo root; default OUT=<repo>/logs/litellm-tools-capture
bin/codex-env bash skills/validation/capture-litellm-tools-payload/scripts/collect_tools_capture.sh

OUT=/tmp/litellm-tools-capture-local \
  bin/codex-env bash skills/validation/capture-litellm-tools-payload/scripts/collect_tools_capture.sh
```

See `logs/README.md` for the project logs convention and gitignore rules.

## Pod paths (after a tools-bearing request)

- `/tmp/litellm-tools-capture/summary.json`
- `/tmp/litellm-tools-capture/tools-array-complete.json`
- `/tmp/litellm-tools-capture/tool-Task.json` (only if a tool named Task was present)
- `/tmp/litellm-tools-capture/tool-Shell.json` (only if a tool named Shell was present)
- `/tmp/litellm-tools-structure-dump.json`

## Hook source

- `roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2`
  (`_analyze_tools`, `_write_tools_dump`, `async_pre_call_hook`)

## Host

- Inventory host: `hom-lab-ctl-k3s-02`
- Namespace: `litellm`

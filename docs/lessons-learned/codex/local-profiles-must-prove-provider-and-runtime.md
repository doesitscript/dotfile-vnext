# Local Codex Profiles Must Prove Provider And Runtime

An exact-looking `codex exec` result is not proof that a local model handled
the request. A launcher that added `--ignore-user-config` suppressed its named
local profile, and Codex silently used the normal cloud default instead.

## Rule

For every local Codex qualification, capture all of the following:

1. The CLI header names the intended `model` and local `provider`.
2. The gateway exposes that model in `/v1/models`.
3. The backend shows the expected live residency or context setting in its own
   runtime API.
4. A tool test counts as a pass only when Codex actually executes the command
   and consumes its result, not when the model merely emits tool-shaped text.

## Desktop Ollama Implication

For `qwen2.5-coder-14b@desktop`, the desktop role owns
`OLLAMA_CONTEXT_LENGTH=12000`. A direct Ollama request does not prove the
Codex path: run `codex-homelab desktop`, inspect its header, and then verify
`/api/ps` reports the same context. Release the test model with `keep_alive: 0`
afterward so the desktop GPU is not left resident.

## Why This Matters

Custom provider configuration, LiteLLM routing, model behavior, and backend
runtime allocation are separate layers. A green result from only one layer can
hide a cloud fallback, a wrong route, insufficient context, or unexecuted tool
request. Keep the negative result when a layer fails; it explains exactly what
the next qualification must prove.

## Related Sources

- [Codex local-client limitations](../../plans/2026-09-01--homelab-local-ai-clients-codex/limitations-and-follow-up.md)
- [Desktop Ollama context investigation](/Users/joshc/develop/homelab-reference-library/notes/investigations/2026-09-02--ollama-desktop-codex-context-length.md)

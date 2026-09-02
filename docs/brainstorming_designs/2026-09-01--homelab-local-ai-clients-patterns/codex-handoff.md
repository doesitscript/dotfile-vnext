# Codex handoff — homelab local AI clients

**Start here:** [local-ai-clients-brainstorm-plan.md](local-ai-clients-brainstorm-plan.md)

## Your scope only (`-codex` promoted plan)

1. Research Codex CLI local/OpenAI-compatible provider config (Context7 — do not guess).
2. Create repo homelab profile template (`hom.lab` gateway, vault/env API key pattern).
3. Document minimal operator switch to local models (profile name + one command).
4. Select models via research matrix; use `model@host` LiteLLM routes only.
5. On execute: promote to `docs/plans/2026-09-01--homelab-local-ai-clients-codex/README.md`.
6. Add HRL guide under `implementation-guides/codex-cli/` when config stabilizes.
7. Test: CLI chat against `litellm.hom.lab` with captured output in plan receipt.

**Not your scope:** Continue extension, OpenCode — sibling plan `…-cursor-kilo`.

**Infra constraints:** `draft_vllm_considerations.md`; vLLM AWQ/FP8; GPU util ~0.90 on 32 GB.

**Bootstrap:** `AGENTS.md`, `.codex/config.toml`, `framework-partner-process.mdc` on execute.

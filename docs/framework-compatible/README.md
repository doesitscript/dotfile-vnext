# Framework-Compatible Surfaces

This folder is the agnostic compatibility layer for the AI working framework
being developed in this repo.

It is not "generic" in the sense of being content-free. It is intentionally
designed so the surfaces here can be consumed by the current Codex/OpenAI
implementation with little or no change, while remaining portable enough to be
adapted to future implementations such as Cursor-native or Claude-agent
variants.

## Relationship To `docs/codex_framework/`

- `docs/codex_framework/`
  documents the Codex/OpenAI-specific implementation of the framework in this
  repo
- `docs/framework-compatible/`
  documents the framework-compatible building blocks that are meant to stay as
  agent-agnostic as practical

These two areas are meant to agree with each other.

- The Codex framework docs should say which compatible surfaces they consume.
- The framework-compatible docs should say that Codex is a supported
  implementation target today.

## What Belongs Here

Use this folder for:

- naming guidance for agent-agnostic framework-owned rule families
- compatibility contracts for reusable rule/skill/process surfaces
- mapping docs that explain how host-specific implementations consume those
  surfaces
- extraction-oriented docs that should move cleanly into a future standalone
  framework repo

Do not use this folder for:

- Codex-only runtime setup details
- `.codex/config.toml` specifics
- OpenAI-specific MCP usage details
- project-specific infrastructure notes

Those belong in implementation-specific docs such as `docs/codex_framework/` or
elsewhere in project docs.

## Current Seed Documents

Current framework-compatible seed docs in this repo are:

- [compatibility-map.md](/Users/joshc/develop/dotfile-vnext/docs/framework-compatible/compatibility-map.md)
- [container-orchestration-integration.md](/Users/joshc/develop/dotfile-vnext/docs/framework-compatible/container-orchestration-integration.md)

These documents explain:

- the `framework-*` rule family under `.cursor/rules/`
- the Codex/OpenAI implementation documented under `docs/codex_framework/`
- future compatible implementations that may be added later
- the modular packet contract for imported container-orchestration guidance

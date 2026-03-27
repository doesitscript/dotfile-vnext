# Compatibility Map

This document records the current compatibility contract between the agnostic
framework surfaces in this repo and the Codex/OpenAI implementation that uses
them today.

## Core Idea

The repo now uses two related but distinct documentation layers:

- `docs/codex_framework/`
  the Codex/OpenAI-specific implementation layer
- `docs/framework-compatible/`
  the agnostic compatibility layer for reusable framework surfaces

The goal is to let the framework mature inside this repo while keeping the most
portable parts ready to move into other projects or a future standalone
framework repository.

## Current Compatible Surface Family

The active rule family under `.cursor/rules/` now uses the `framework-*`
prefix.

Examples:

- `framework-partner-process.mdc`
- `framework-knowledge-and-research.mdc`
- `framework-mcp-and-tool-usage.mdc`
- `framework-troubleshooting-mode.mdc`
- `framework-github-issue-workflow.mdc`

These filenames intentionally avoid a `codex-` prefix so they can remain as
agent-agnostic as practical while still being usable by the Codex framework in
this repo.

Those rule surfaces are also the right place to encode decision-type tool or
resource requirements, such as "for Ansible design questions, fetch the Ansible
best-practices resource and consult the design-philosophy tool before proposing
structure."

That compatibility pattern should stay explicit:

- workflow-role and decision-type tool routing belongs in `framework-*`
- source-managed copies of those rule surfaces live under `roles/cursor/rules/`
- implementation-specific runtime config such as `.codex/config.toml` stays
  outside this compatibility layer

## Current Codex/OpenAI Implementation

The current Codex/OpenAI implementation consumes those compatible surfaces
through:

- `AGENTS.md`
- `.codex/config.toml`
- `.cursorrules`
- active `.cursor/rules/*.mdc`
- `docs/codex_framework/README.md`
- `docs/codex_framework/partner_process.md`

In other words:

- the compatible surfaces are the reusable building blocks
- the Codex framework docs explain how Codex/OpenAI loads and uses them in this
  repo

## Naming Intent

Use the following rule of thumb:

- `framework-*`
  for active framework-owned rule surfaces meant to stay as implementation-
  agnostic as practical
- `ansible-*`
  for domain-specific surfaces tied to Ansible behavior
- `github-*`
  for GitHub workflow capability surfaces
- implementation-specific docs folders
  for host/runtime-specific setup and behavior, such as `docs/codex_framework/`

## Supported Implementation Targets

Implemented today:

- Codex / OpenAI

Planned or expected future targets:

- Cursor-native agent/chat usage
- Claude-agent implementations

Those future targets should prefer consuming the `framework-*` family rather
than forcing a rename of the reusable surfaces each time.

## Immediate Boundaries

Today this compatibility layer does **not** replace:

- `docs/codex_framework/`
- `AGENTS.md`
- `.codex/config.toml`

It complements them.

The Codex docs remain the source of truth for:

- Codex runtime behavior
- OpenAI docs MCP usage
- Codex subagent configuration
- Codex-specific enforcement hierarchy

This folder is the source of truth for:

- why `framework-*` names exist
- how those surfaces should remain compatible across implementations
- what should be kept portable as the framework matures
- the rule that decision-type MCP/doc enforcement belongs in framework-owned
  rule surfaces rather than in implementation-specific runtime config

# Cursor Rules — Source Storage

This folder stores the source-of-truth copies for rule surfaces that the repo
intends to preserve and deploy. Files here use the `.cursor` suffix so they are
not activated directly.

## Rule Ownership Model

The repo now uses a clearer split:

- `.cursorrules`
  - Cursor/workspace bootstrap layer
- `AGENTS.md` plus project `.codex/config.toml`
  - Codex-native bootstrap layer for this repo
- active `.cursor/rules/*.mdc`
  - runtime rule layer for Cursor and repo guidance surfaces for Codex when the
    bootstrap instructs them to be consulted
- `roles/cursor/rules/*.mdc.cursor`
  - source copies for durable rule content that should be managed from the repo

For the framework capability, the primary source-managed family is now:
- `framework-mcp-and-tool-usage.mdc.cursor`
- `framework-knowledge-and-research.mdc.cursor`

Those are the authority surfaces for:
- decision-type MCP tool enforcement
- tool/resource authority by workflow role and question type

## Framework Rule Direction

The framework-owned rule family under `.cursor/rules/` is intentionally
implementation-agnostic where possible:

- `framework-*` for portable framework behavior
- `ansible-*` for domain-specific Ansible behavior
- `github-*` for GitHub workflow behavior

Decision-type tool/resource routing belongs in the `framework-*` family rather
than in `AGENTS.md`, runtime config, or ad hoc skill prose.

## Deploying Rules

When the `cursor` Ansible role manages these files, it should:
1. copy each tracked `*.mdc.cursor` file to `.cursor/rules/` stripping the suffix
2. keep `.cursorrules` aligned with the active framework file names for
   Cursor-native sessions
3. avoid describing `.cursorrules` as a native Codex startup source unless that
   behavior has been re-validated against current Codex docs/runtime

Until that deployment task is fully automated, keep the source copy and active
rule in sync manually for any file managed from this folder.

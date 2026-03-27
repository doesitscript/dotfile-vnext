# MCP Role Pattern v1 With Durable Plan Storage

Canonical approved plan for the MCP role-pattern cleanup and draw.io retrofit.

Tracked in GitHub issue #8.

## Summary

Implement the MCP-role pattern as repo-native process, not tribal knowledge.
v1 adds a specialized MCP role template, stronger MCP instructions, a reusable
validation/report pattern, a draw.io retrofit as the canonical example, and a
durable plan-storage rule where the repo plan is canonical and GitHub is the
higher-level roadmap mirror.

## Key Decisions

- approved plans are stored under `docs/plans/`
- GitHub mirrors the work at a higher level when available
- the repo plan must remain useful on its own if GitHub is unavailable
- the MCP template supports `cursor`, `vscode`, and `openapi`
- `openapi` is an explicit stub in v1 and should fail fast if selected
- default MCP target list is `['cursor']`
- the project root for MCP client config defaults to the current repo root
- target selection uses variables first and tags as focused execution helpers
- the draw.io role is the first canonical example, not the start of a full MCP-role migration

## Public Contract

- every approved plan gets a repo-stored durable artifact
- MCP roles should expose `<server>_state: present|absent`
- MCP roles should expose `<server>_targets` with default `['cursor']`
- MCP roles should document install, config, verify, and remove in the same shape
- MCP roles should carry a small machine-readable contract file

## Verification Targets

- confirm the framework says approved plans are stored in-repo and mirrored to GitHub
- confirm the MCP template captures the target model and `openapi` stub behavior
- retrofit draw.io to the new pattern
- validate default Cursor targeting and explicit VS Code targeting
- confirm the focused Mac/controller MCP play remains the canonical control surface

---
title: Morph-only MCP default on work laptop
id: morph-only-mcp-default
status: accepted
behavior_group: mcp-commission-scope
updated_at: "2026-09-23"
---

# Morph-only MCP default on work laptop

## Problem

Commissioning every MCP into Continue / Codex / Aider / OpenCode on the
corporate Mac caused tool noise, OAuth friction, and client-side failures that
hid the one MCP we were evaluating (Morph WarpGrep / Fast Apply).

## Fix (source packet)

- `host_vars/work-laptop.yaml`: `mcp_non_morph_enabled: false` plus
  `mcp_tool_enabled` map with only `morph-mcp: true`.
- `continue_ide_mcp_servers` lists Morph only (no AWS / Context7 / Firebase /
  multiagents-peer by default).
- `continue_ide_provision_firebase_cli: false`.
- Parent role defaults: `aider_mcp_*` and `opencode_cli_mcp_*` Context7 /
  Firecrawl off.
- Codex target block uses `mcp_tool_enabled` for the `enabled` flag.
- Morph routing templates stay lean; Continue Morph rule stays on.

## Do not regress

Re-enabling non-Morph MCPs requires an explicit `work-laptop-mcp-commission`
ask and a host_vars / client-list change — not a silent restore from an old
inbox config dump.

## Upstream ↔ downstream loop

Laptop evidence for this posture landed as sibling working-tree changes (not
only an `inbox/*.md` note). Upstream absorbed them into the packet; sync
pushes them back so the next laptop apply matches source.

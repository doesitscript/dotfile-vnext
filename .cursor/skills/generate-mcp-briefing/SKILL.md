---
name: generate-mcp-briefing
description: Discovers all MCP servers and tools dynamically, classifies them by mode and trigger condition, and writes the Tool Mode Map to .cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc. Run occasionally to keep the knowledge base current. Use when MCP servers change, tools are added, or the briefing needs refreshing.
---

# Generate MCP Briefing Skill

## Purpose

This skill maintains `02--cussorrules-mcp-briefieng-GENERATED.mdc` as the persistent MCP tool knowledge base for this project. Agents read that file at conversation start to know which tools to use in which mode — preventing them from ignoring MCP tools or re-deriving tool usage from scratch each conversation.

Run this skill when MCP servers or tools change. It discovers tools dynamically, classifies them using their descriptions and names, and surfaces uncertain placements for your review rather than guessing silently.

---

## Capabilities

### Generate
Discover all MCP tools, classify them, write the full generated file.

**Triggered by:** "regenerate the MCP briefing", "refresh the tool map", "update the generated rule", or after changing `.cursor/mcp.json`.

### Evaluate
Discover current MCP tools, compare against the existing generated file, report what is missing or changed. No writes.

**Triggered by:** "evaluate the MCP briefing", "is the briefing in sync?", "what tools are missing?", "report on MCP drift."

---

## Workflow: Generate

### Step 1 — Discover MCP Servers and Tools

- Read `.cursor/mcp.json` to get all server names — do NOT hardcode server names
- For each server found, enumerate all available tools and their descriptions from your live tool list
- Enumerate all available resources via `ListMcpResources`
- Discover fresh each time — do not use a cached list

### Step 2 — Classify Each Tool

For each discovered tool, read its name and description. Reason about:

1. **Which modes it applies to** — Agent, Plan, Debug, Ask, or multiple
2. **Which section within each applicable mode** — use the section definitions below
3. **What the trigger/condition text should be** — a short, specific "when X" phrase

**Section definitions:**

| Section | When to use it |
|---|---|
| `Required workflow` | Must be called in a fixed sequence for every Ansible change |
| `Required pre-task` | Must be called before writing any task or role |
| `Required when [condition]` | Becomes mandatory when a specific condition is true |
| `Call when [trigger]` | Should be called when a specific situation arises |
| `Not used unless explicit` | Does not apply to this mode or requires explicit user request |
| `Explicit instruction only` | Must never be called without the user explicitly asking |

**Confidence rule:**
- Confident in placement → classify it, write the trigger text, place it in the output
- Uncertain → mark it `[SUGGESTED]` and collect it for Step 4

### Step 3 — Write the Generated File

Write to `.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc` using this exact structure:

```
---
alwaysApply: true
---

## MCP Tool Knowledge Base

**Scope:** This file applies to ALL Cursor modes — Agent, Plan, Debug, and Ask.
It is not a code-creation-only reference. Any agent in any mode must consult
this file before deciding which tools to use. Ignoring these tools because you
are in Plan, Debug, or Ask mode is a rule violation.

**Purpose:** Persistent reference so agents do not re-derive tool usage from
scratch each conversation. Run the `generate-mcp-briefing` skill to refresh
this file when MCP servers or tools change.

---

## Tool Mode Map

### Agent mode — full execution

**Required workflow (must call in this order for every Ansible change):**
[ordered list]

**Required pre-task (before writing any task or role):**
[list]

**Required when [condition applies]:**
[list — each entry states the specific condition]

**Call when [trigger]:**
[list — each entry states the specific trigger]

**Not used in Agent mode unless task is explicitly about it:**
[list]

---

### Plan mode — read-only planning, no execution

**Required (must call before writing any plan involving Ansible):**
[list]

**Call when [trigger]:**
[list]

**Not used in Plan mode:**
[list]

---

### Debug mode — evidence collection and diagnosis

**Required (per REQUIRED-EVIDENCE-NO-ASSUMPTIONS-ON-FAILURE rule):**
[list]

**Required when [condition applies]:**
[list]

**Call when [trigger]:**
[list]

**Not used in Debug mode:**
[list]

---

### Ask mode — conversational and informational only

**Required for any Ansible design or idiom question:**
[list]

**Call when [trigger]:**
[list]

**Not used in Ask mode:**
[list]

---

## Tools Requiring Explicit User Instruction — Any Mode

Never call the following without the user explicitly requesting:

| Tool | Server | Reason |

---

## Reference Resources (available in all modes)

Fetched via `FetchMcpResource` — read-only documents, never "run":

| Resource URI | Server | Content |

---

## Needs Classification

Tools discovered but not confidently classified. Review and confirm or adjust
each suggested placement, then run the skill again to incorporate them.

[list of SUGGESTED items, each with: tool name, server, proposed section, reasoning]
```

### Step 4 — Surface Suggestions to User

After writing the file:
- List every `[SUGGESTED]` item with its proposed placement and your reasoning
- Ask the user to confirm, adjust, or reassign each one
- Remind user to run the skill again after confirming to write the final placements

---

## Workflow: Evaluate

1. Read `.cursor/mcp.json` — get all server names dynamically, no hardcoding
2. Enumerate all current tools and resources from the live MCP interface
3. Read existing `.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc`
4. Report to user (no writes):
   - Tools present in MCP but absent from the file
   - Tools in the file that no longer exist in MCP
   - Whether the file needs regeneration

---

## Reference

- Output file: `.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc`
- MCP config (source of server names): `.cursor/mcp.json`

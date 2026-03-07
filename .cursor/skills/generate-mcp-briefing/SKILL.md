---
name: generate-mcp-briefing
description: Discovers all MCP servers, tools, and resources, then generates the Tool Mode Map and writes it to .cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc. Use when the user asks to regenerate the MCP briefing, update the generated rule, refresh the tool map, evaluate the briefing, or report on MCP drift.
---

# Generate MCP Briefing Rule

## Purpose

Converts the dynamic procedure in `01--cursorrules--mcp-briefing.mdc` into a concrete output file. The rule instructs the agent to read MCP descriptors and produce a briefing; this skill performs that discovery and writes the result to the GENERATED file.

## Capabilities

### Capability 1: Generate (full workflow)

**When:** User says "regenerate the MCP briefing", "refresh the tool map", "update 02--cussorrules-mcp-briefieng-GENERATED", or after changing MCP configuration.

### Capability 2: Evaluate / Report (read-only)

**When:** User says "evaluate the MCP briefing", "report on the MCP briefing", "check if the briefing is up to date", "what's different in the MCP tools?", or "is the briefing in sync?"

**Behavior:** Discover current MCP state, read the existing `02--cussorrules-mcp-briefieng-GENERATED.mdc`, compare, and report only (no writes):
- Tools or resources in MCP but missing from the file
- Tools in the file that no longer exist or have changed
- Whether the file is in sync or needs regeneration

## Required Workflow (Generate)

### 1. Discover MCP Tools and Resources

- Read `.cursor/mcp.json` for server names (ansible, ansible-mcp, sysoperator, etc.)
- Enumerate all tools available from those servers (from your tool list / MCP interface)
- Enumerate all resources (e.g. `guidelines://ansible-content-best-practices`, etc.)
- Do not assume or use a cached list — discover fresh each time

### 2. Categorize by Mode

For each tool, assign to one or more modes based on purpose:

| Mode | Criteria |
|------|----------|
| **Agent** | Execution tools: validate, lint, run playbook, gather facts, etc. |
| **Plan** | Read-only: inventory, zen_of_ansible, best-practices resource. No execution. |
| **Debug** | Evidence collection: gather-facts, fetch-logs, diagnose-host, service-manager. |
| **Ask** | Informational only: zen_of_ansible, best-practices resource. No execution. |

### 3. Output Format

Generate content matching the structure of `02--cussorrules-mcp-briefieng-GENERATED.mdc`:

```markdown
---
alwaysApply: true
---

## Tool Mode Map

### Agent mode — full execution
**Required workflow:** ...
**Required pre-task:** ...
**Discretionary:** ...
**Not used in Agent mode unless task is explicitly about it:** ...

### Plan mode — read-only planning, no execution
**Required:** ...
**Discretionary:** ...
**Not used in Plan mode:** ...

### Debug mode — evidence collection and diagnosis
**Required:** ...
**Discretionary:** ...
**Not used in Debug mode:** ...

### Ask mode — conversational and informational only
**Required:** ...
**Discretionary:** ...
**Not used in Ask mode:** ...

## Reference Resources (available in all modes)
| Resource URI | Server | Content |

## Tools Not Covered in ansible-mcp-first.mdc or Other Existing Rules
[By server, list tools with no rule-defined workflow]
```

### 4. Write Output

Write the generated content to:

```
.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc
```

Include the YAML frontmatter with `alwaysApply: true`.

### 5. Confirm to User

- State that the file was regenerated
- Note any tools or resources added or removed compared to the previous version (if detectable)
- Remind user they can run this skill again whenever MCP servers change

## Required Workflow (Evaluate / Report)

1. Discover current MCP tools and resources (same as Generate step 1)
2. Read existing `.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc`
3. Compare current MCP state with what is documented in the file
4. Report to user (no writes):
   - Tools or resources in MCP but missing from the file
   - Tools in the file that no longer exist or have changed
   - Whether the file is in sync or needs regeneration

## Reference

- Source rule (procedure only): `.cursor/rules/01--cursorrules--mcp-briefing.mdc`
- Output file: `.cursor/rules/02--cussorrules-mcp-briefieng-GENERATED.mdc`
- Current MCP config: `.cursor/mcp.json`

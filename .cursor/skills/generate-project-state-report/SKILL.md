---
name: generate-project-state-report
description: >
  Examines the project comprehensively and produces two files inside
  docs/reports/YYYY-MM-DD_project_state_<ModelName>/: a project state report
  (README.md) for an AI-agent audience, and a Codex framework usage document
  (codex_framework_usage.md). Use when asked to "generate a project report",
  "state of the project", "document the project for another AI", or any
  variant of that intent.
---

# Skill: Generate Project State Report

## Purpose

Produce a durable, AI-readable snapshot of the project's current state plus a
dedicated document describing how the Codex framework is actively being used.

The primary audience is **another AI agent** that may be joining the repo fresh.
The goal is to give that agent enough grounded context to be productive quickly
without having to rediscover patterns from scratch.

This skill is also used as a maturity test: the quality of the report indicates
how well the agent understands the project, not just how well it summarizes text.

---

## When to Use This Skill

Use this skill when:

- the user asks for a "project report", "project state", or a document describing
  the current project for another AI
- periodic checkpoints are wanted to capture current state before a major change
- comparing how different models understand the same project (multiple runs, one
  per model)
- onboarding a new AI agent to this repo

Do not use this skill for narrow topic documentation. This skill is for a
comprehensive project-level snapshot.

---

## Output Location and Naming

Create a new directory:

```
docs/reports/<YYYY-MM-DD>_project_state_<ModelName>/
```

Where:
- `<YYYY-MM-DD>` is today's date
- `<ModelName>` is the short identifier for the model generating this report
  (e.g. `Claude-4.6-Sonnet`, `GPT-5`, `Gemini-2.5-Pro`)

The agent should use its own model identifier — not a generic label — so reports
from different models are distinguishable by filename alone.

Create two files inside that directory:

| File | Purpose |
|---|---|
| `README.md` | Main project state report — comprehensive, AI-audience |
| `codex_framework_usage.md` | Dedicated document on how the Codex framework is currently being used |

Do not create these files until the exploration phases are complete. Produce
output from understanding, not from premature drafting.

---

## Phase 1: Read Prior Reports

Before exploring the project, read the existing reports in `docs/reports/` to:

1. Understand what format prior models used
2. Identify what they flagged as unverified — resolve those where you can
3. Avoid replicating the same gaps they identified
4. Find where your runtime context gives you different or better visibility

Key prior report locations:
- `docs/reports/2026-03-26_project_state_GPT-5/` — GPT-5 Codex session
- `docs/reports/2026-03-26_project_state_Gemini-2.5-Pro/` — Gemini 2.5 Pro
- `docs/reports/2026-03-26_project_state_Claude-4.6-Sonnet/` — Claude 4.6 Sonnet (Cursor IDE)

Claude in Cursor IDE resolved the key open question from prior reports: whether
`.cursor/rules/*.mdc` files are injected into agent sessions. In Cursor, they are —
confirmed by their presence in the system context as `always_applied_workspace_rules`.
This is a Cursor-specific observation. Other runtimes (OpenAI Codex, Gemini) may
behave differently.

---

## Phase 2: Project Exploration

Explore the following surfaces in roughly this order. Read, inspect, and
synthesize — do not draft output yet.

### Infrastructure topology
- `inventory/inventory.yaml` — the authoritative system map
- `inventory/group_vars/*.yaml` — per-group variables
- `inventory/host_vars/*.yaml` — per-host variables (note secret hygiene)

### Governance and framework
- `AGENTS.md` — the durable behavioral contract
- `docs/codex_framework/README.md` — framework capability map and status
- `docs/codex_framework/partner_process.md` — working philosophy
- `docs/codex_framework/implemented_plans/` — accepted, implemented decisions
- `.cursor/rules/` — active rule files (list all, read key ones)
- `.cursor/skills/` — list all skills

### MCP tooling
- `.cursor/mcp.json` — configured MCP servers
- `roles/mcp_servers/README.md` — MCP server role pattern
- `roles/mcp_servers/ai.mcp_servers.instructions.md` — canonical pattern doc

### Playbook and role landscape
- `ls playbooks/` — all playbooks including sub-directories
- `ls roles/` — all role directories
- Focus on roles with thorough READMEs (especially recent or active ones)

### Active work signals
- `git log --oneline -20` — recent commit activity
- `git status` — current working tree state
- `ls docs/plans/` — approved plans
- `ls docs/diagnostics/` — diagnostic reference docs
- `ls artifacts/troubleshooting/` — collected troubleshooting artifacts

### Operational setup
- `ansible.cfg` — key configuration (inventory, vault, logging, callbacks)
- `.envrc` presence and purpose (do not read secrets)
- `.ansible-lint` and `.pre-commit-config.yaml` — verification infrastructure

### Feedback layer
- `docs/intake/` — operator feedback on AI response quality
- `docs/lessons-learned/codex/` — codex-specific lessons
- `docs/lessons-learned/ansible/` — ansible-specific lessons

---

## Phase 3: Synthesize Before Writing

Before drafting either file, synthesize the following internally:

1. **What is this project actually doing?** One paragraph, no jargon.
2. **What is the active engineering work right now?** What is unblocked, blocked, and in flight.
3. **What has changed since prior reports?** What new artifacts, patterns, or decisions exist.
4. **What can this session's runtime environment verify that prior reports left open?**
5. **What are the trust levels of different documentation surfaces?** Which docs are current, which are transitional, which are historical.
6. **What should an incoming AI do first, second, third?** Concrete entry point ordering.

Do not produce a report that simply summarizes what you read. Produce one that reflects judgment.

---

## Phase 4: Write README.md (Project State Report)

The main report must include:

### Required sections

1. **Header** — model name, date, audience, companion doc reference
2. **Unique vantage point note** — what this model/runtime can confirm or add beyond prior reports
3. **Snapshot caveat** — what was and was not run (lint, playbooks, etc.); is the working tree clean
4. **What this repo actually is** — one tight paragraph, no marketing language
5. **Infrastructure topology summary** — host groups, surfaces, naming conventions, transition direction
6. **Role and playbook landscape** — counts, domain breakdown, active playbook strategy
7. **Current active work** — what is in flight; what is blocked; what was recently completed
8. **MCP tooling** — configured servers, what each provides, operational significance
9. **Governance and AI framework** — layers, what is confirmed active, what is aspirational
10. **Maturity assessment** — scored table across key areas
11. **Trust hierarchy** — high / medium / low trust docs with reasoning
12. **Key risks** — what an incoming AI should know to avoid wrong assumptions
13. **Entry points by task type** — concrete file references for common starting points
14. **Operational setup** — environment activation, ansible.cfg summary
15. **Bottom-line judgment** — one tight paragraph with the key meta-finding
16. **Evidence basis** — list every file and source consulted

### Tone and style

- Write for an AI reader, not a human marketing audience
- Be concrete and direct; avoid hedging on things you can actually verify
- Be explicit about the difference between confirmed, inferred, and unverified
- Maturity scores should be honest; a 2/5 is a real finding, not a diplomatic gap

---

## Phase 5: Write codex_framework_usage.md

This document focuses entirely on how the Codex framework is being used right now.

### Required sections

1. **Header** — model name, date, purpose
2. **Runtime context note** — which runtime is running this (Cursor, Codex, API), what that means for rule enforcement
3. **What the framework actually is** — not what it aspires to be; what it currently does
4. **The five layers** — durable contract, always-applied rules, framework docs, skill workflows, registered docs (with confirmed vs. aspirational distinction per layer)
5. **The pre-flight gate system** — the four gate types with required tool sequences; this is the most operationally significant part of the framework
6. **The troubleshooting mode** — trigger conditions, required per-run format, evidence hierarchy, two-attempt cap
7. **Evidence that the framework is actually working** — concrete in-repo artifacts proving the framework produces real outputs (not just docs saying what should happen)
8. **What is not yet implemented** — honest gap list from the framework docs themselves
9. **The agent's operating experience in this session** — how the rules shaped this session's actual behavior (where they fired, where they didn't, what that reveals)
10. **Summary judgment** — what is the honest one-paragraph statement about this framework's maturity

### Key question this document must answer

A future model reading this document should be able to answer: "Is this framework real and operational, or is it documentation that describes intended behavior?" The answer must be supported with evidence, not assertion.

---

## Phase 6: Verify Output

After writing both files:

1. Confirm both files exist under the correctly named directory
2. Confirm the directory name includes today's date and the correct model identifier
3. Confirm the companion doc reference in `README.md` points to `codex_framework_usage.md`
4. Confirm the evidence basis section in `README.md` lists the actual files consulted
5. Do not run ansible-lint or validate-playbook on these docs (they are Markdown, not Ansible content)

---

## Conventions and Guardrails

- **Do not collapse confirmed, inferred, and unverified into one claim.** Use language like "confirmed," "inferred but reasonable," and "unverified" explicitly — the prior reports established this as a useful framework for honest reporting.
- **Do not fill maturity scores optimistically.** Gaps in secret hygiene, verification enforcement, or documentation freshness should score as gaps.
- **Do not describe the framework as multi-agent unless you have runtime evidence of it.** The project documents multi-agent as a future intent. Claiming it is implemented when it has not been observed is a distortion.
- **Preserve the prior reports.** Do not modify them. New reports go in new directories.
- **Date prefix must be sortable.** The format `YYYY-MM-DD` ensures reports sort chronologically by directory name.
- **Model name in the directory should match the actual model identifier.** Do not use generic labels like "AI" or "Agent."

---

## Reference: Folder and File Shape

```
docs/reports/
  2026-03-26_project_state_GPT-5/
    README.md
    state_snapshot.yaml
    current_codex_architecture.md
  2026-03-26_project_state_Gemini-2.5-Pro/
    README.md
    codex_framework_implementation.md
  2026-03-26_project_state_Claude-4.6-Sonnet/
    README.md
    codex_framework_usage.md
  <YYYY-MM-DD>_project_state_<ModelName>/   ← new report goes here
    README.md
    codex_framework_usage.md
```

Additional files (like `state_snapshot.yaml`) are optional and may be added if the
model finds them useful for structured data consumers.

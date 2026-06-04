# Agent Workflow Pattern Schema

Every reusable workflow pattern in this folder should include these fields.

## Front Matter

```yaml
---
status: draft|trial|active|retired
owner: codex-framework
applies_to:
  - plan-family-execution
---
```

## Required Sections

### Purpose

What kind of work this pattern coordinates.

### Triggers

User wording, plan states, repo conditions, or failure modes that activate the
pattern.

### Roles

Each role must define:

- responsibility
- read/write boundary
- allowed tools
- handoff artifact
- completion signal

### Parallel Work

Read-heavy, research-heavy, or independent validation work that can run in
parallel.

### Serialized Work

Writes, live apply, NetBox mutation, inventory edits, and dependency-sensitive
work that must be sequenced.

### Gates

Every workflow must name its gates. A gate should define:

- required input
- required evidence
- pass condition
- fail/send-back condition
- fallback when the tool or subagent is unavailable

### Artifacts

Receipt files, plan sections, logs, or other durable outputs the workflow must
produce.

### Completion Rule

The exact condition that allows the coordinator to report complete.

### Failure Rule

The exact condition that prevents completion, including what must happen when a
validator or dependency is unavailable.

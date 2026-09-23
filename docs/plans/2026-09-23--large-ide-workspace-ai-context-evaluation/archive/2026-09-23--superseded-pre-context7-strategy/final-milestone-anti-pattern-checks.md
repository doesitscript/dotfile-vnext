# Final milestone: anti-pattern checks

This file defines the milestone checks required before claiming that the large
IDE workspace problem has been understood or improved.

## Milestone goal

Determine whether the current repository and Cursor/agent runtime are causing,
contributing to, or not materially affecting the long-running basic usability
problems with home-lab models.

The result must distinguish:

- confirmed cause;
- contributing cause;
- unsupported hypothesis;
- separate model/gateway/tooling failure.

## Anti-pattern checks

### 1. Retrieval pollution

- Are `.venv/`, `logs/`, caches, generated artifacts, stale plans, or runtime
  outputs discoverable by normal search or agent retrieval?
- Do agents retrieve authoritative playbooks and docs, or noisy descendants?
- Does explicitly naming a log path still allow deliberate inspection?

### 2. Instruction pollution

- Are there duplicate or conflicting instructions across `AGENTS.md`, Cursor
  rules, Codex config, skills, plans, and client settings?
- Is authority precedence clear to every supported agent type?
- Are historical plans or generated instruction files being mistaken for active
  guidance?

### 3. Runtime pressure

- How much CPU and memory do Cursor renderers and GPU helpers use while idle,
  editing, searching, and running an agent?
- Do Composer wakelocks explicitly disable background throttling?
- Do they remain active after the agent should be idle?
- What resource cost comes from extension hosts, language servers, MCP servers,
  webviews, and multiple open Cursor windows?

The renderer/GPU-helper lane is a current-pass remediation target. It is not
being deferred merely because workspace cleanup is also required. The user
should receive an explanation of what “disabled background throttling” means
and whether the observed behavior is expected or excessive.

### 4. Model, gateway, and tool faults

- Do basic home-lab tasks fail in a minimal source-focused workspace too?
- Are context-window errors caused by retrieved content, injected instructions,
  or the model's actual limit?
- Are LiteLLM/vLLM routes, tool schemas, tool capability, and follow-up calls
  independently behaving correctly?
- Does the model fail because the task exceeds capability, or because the
  workspace gives it contradictory/noisy context?

## Required controlled comparison

Run the same representative basic home-lab tasks against:

1. the current full workspace;
2. a source-focused workspace excluding runtime/evidence bulk;
3. the same model and gateway configuration in both cases.

Record time to first useful answer, irrelevant retrieval, context size,
tool-call correctness, failure rate, CPU, and memory.

## Completion standard

Do not claim the workspace is fixed merely because directories are ignored or
Cursor CPU decreases. The milestone requires evidence showing whether basic
home-lab model usability improved, stayed unchanged, or remains blocked by a
separate model/gateway/tooling issue.


# Evaluation: home-lab AI usability, workspace size, and context cost

## Problem statement

The repository was observed at approximately 635 MB for `.venv/`, 327 MB for
`logs/`, 130 MB for `playbooks/`, and 25 MB for `docs/`. These sizes may cause
IDE indexing, file watching, search, language-server, and AI-agent context cost.

The immediate concern is not merely disk usage. It is whether generated or
runtime material is being presented as if it were source, and whether all AI
agent types have a durable repository-level boundary.

The broader concern is that this workspace architecture may be contributing to
long-running basic usability failures with home-lab models. The evaluation
must verify or rectify that hypothesis rather than assuming the directory sizes
are harmless or are the complete explanation.

## User requirements captured

| Area | Requirement |
|---|---|
| `logs/` | Exclude by default from AI-agent exploration; allow explicit user-named paths |
| `logs/` Git shape | Retain a Git-visible keep-file while ignoring descendants |
| `playbooks/` | Keep readable as source; investigate why text-oriented content is 130 MB |
| `docs/` | Keep readable, including wanted diagrams; separate unwanted bulk/generated content |
| `.venv/` | Keep available to local tools; avoid exposing it as agent context |
| Cross-agent behavior | Prefer Git/repository conventions over per-agent custom configuration |

## Evidence to collect next

1. `git ls-files` and `git check-ignore -v` for each target directory.
2. File count, extension, and largest-file inventory for each target directory.
3. Tracked-versus-untracked size attribution.
4. Duplicate and generated-content indicators in `playbooks/` and `docs/`.
5. `.venv/` package, cache, interpreter, and symlink inventory.
6. Repo wrapper references to `.venv/`, external caches, and generated output.
7. A controlled comparison of normal agent search behavior before and after
   repository-boundary changes, without assuming every client honors Git in the
   same way.
8. Active Composer wakelocks and whether they disable background throttling
   only during active work or remain active while the workspace should be idle.
9. Cursor renderer and GPU-helper CPU/memory samples, explicitly checking for
   improvement opportunities in this pass.
10. Extension-host and MCP-server process/resource attribution, including
    multiple simultaneous agent surfaces.
11. Instruction-surface inventory and precedence checks across AGENTS.md,
    Cursor rules, Codex config, skills, plans, and client-specific settings.
12. Basic home-lab task comparison across the full workspace and a minimal
    source-focused workspace.

## Failure-class hypotheses

| Class | What to verify |
|---|---|
| Retrieval pollution | Irrelevant logs, caches, generated files, stale plans, or runtime artifacts enter search/retrieval |
| Instruction pollution | Conflicting or excessive rules/settings displace authoritative project guidance |
| Runtime pressure | Renderer, GPU helper, extension hosts, MCP servers, language servers, and Composer loops consume resources |
| Model/gateway faults | Context limits, routing, tool capability, LiteLLM/vLLM, or model behavior fail independently of workspace shape |

## Options under evaluation

| Option | Benefit | Risk / limitation | Status |
|---|---|---|---|
| Git ignore baseline | Cross-tool, durable, simple | Not access control; does not untrack existing files | candidate |
| Keep-file plus ignored descendants | Preserves empty directory intent | Requires cleanup of already tracked descendants | candidate |
| Source/generated directory split | Clear semantics for agents and humans | Requires relocation and reference updates | pending research |
| Smaller/rebuilt `.venv/` | Reduces disk and accidental context | Must preserve wrapper/tool behavior | pending research |
| External cache locations | Keeps source tree clean | Adds environment/setup contract | pending research |
| Per-agent ignore/rule files | Immediate client-specific tuning | Duplicated, drifts, not universal | fallback only |

## Acceptance criteria for the next plan revision

- `logs/` default behavior and explicit-path behavior are separately described
  and testable.
- No proposed blanket exclusion hides source playbooks or useful documentation.
- Every large directory has a size explanation tied to actual files.
- `.venv/` has a documented execution boundary and a reproducible rebuild path.
- Git policy, repository layout, and optional client guidance have distinct
  ownership and rollback paths.
- The recommendation identifies anti-patterns and does not claim Git alone can
  enforce agent access semantics.
- The recommendation explains whether workspace hygiene is a confirmed cause,
  contributing cause, or unsupported hypothesis for home-lab usability.

# AI-suggested way forward

The project can be large without being a problem. The real problem is whether
large material is crossing the wrong boundary:

- source code and authoritative docs should be available to agents;
- logs and evidence should be opt-in;
- caches and virtual environments should be available to tools but invisible to
  normal AI exploration;
- generated artifacts should not sit beside source;
- stale plans and duplicated instructions should not compete with current
  authority.

A healthy setup can have a very large repository checkout if the AI-facing
surface is mostly a small, curated source tree.

## Scalable boundary layers

### 1. Git establishes the universal repository baseline

Use `.gitignore` for runtime data, caches, logs, virtual environments,
generated reports, archives, and other non-source material. This prevents
accidental commits and gives most IDEs and CLIs a common signal.

### 2. Repository layout establishes meaning

For example:

- `playbooks/` contains only source playbooks;
- `docs/` contains useful source documentation and intentional diagrams;
- `logs/` contains opt-in evidence;
- `.venv/` contains local execution dependencies;
- generated output goes under clearly named ignored directories.

This is more reliable than asking every AI tool to understand exceptions.

### 3. A repository-level agent contract explains semantics

Git can say “this is ignored.” It cannot fully say “this is evidence and should
only be opened when explicitly requested.” That meaning belongs in a durable
repository instruction surface such as `AGENTS.md`, with `.aiignore` or an
equivalent advisory file where supported.

### 4. Client settings optimize performance

Cursor workspace settings can exclude directories from file watching and
search. CLI tools can often respect Git exclusions or explicit path scopes.
These are useful accelerators, but they should not be the primary source of
truth.

## Important limitation

No single file is perfectly honored by every AI product. Git is the closest
common denominator, but it is not an access-control system. If a user
explicitly tells an agent to inspect `logs/foo/renderer.log`, that file should
still be available. The goal is “excluded from normal discovery,” not
“impossible to read.”

## Recommended treatment by location

- `.venv/`: keep operationally available, but exclude from Git, search,
  watching, and retrieval.
- `logs/`: ignore descendants, preserve a tracked keep-file/README, and make
  explicit-path inspection the normal exception.
- `playbooks/`: keep fully readable, but remove or relocate anything that is
  not actual playbook source.
- `docs/`: keep readable, while separating generated diagrams, exports,
  attachments, and historical bulk from canonical documentation.

## Additional concern: retrieval and instruction pollution

Even if large files are not committed, agents may still encounter:

- too many plans;
- duplicate rules;
- stale artifacts;
- broad MCP directory listings;
- multiple simultaneous agent sessions;
- generated files in source directories.

The evaluator skill should therefore test the whole repository boundary, not
simply report directory sizes.

## High-level conclusion

The target should be an “AI-facing source surface” that is smaller and more
authoritative than the complete working checkout. The working tree can remain
large for infrastructure tools, while normal AI context remains focused. This
can be made largely repository-wide and portable, with only minor Cursor/CLI
performance settings layered on top.


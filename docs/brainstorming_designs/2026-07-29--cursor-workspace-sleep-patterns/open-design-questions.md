# Open Design Questions

This file records the open design questions for the workspace-sleep packet,
plus the selected choices that the rest of the draft skill pack now uses.

Choices marked **Selected for this packet** are the ones implemented across:

- [cursor-workspace-sleep-plan.md](./cursor-workspace-sleep-plan.md)
- [workspace-sleep-toggle-skill-pack.md](./workspace-sleep-toggle-skill-pack.md)
- [workspace-sleep-skill-testing.md](./workspace-sleep-skill-testing.md)

---

## 1. What counts as the most upstream workspace location?

### Candidates

- active `.code-workspace` file when one owns the window
- repo-local `.vscode/settings.json` when no multi-root workspace owns the
  window
- user-global Cursor settings as a fallback

### Selected for this packet

- active `.code-workspace` file when one owns the window
- otherwise repo-local `.vscode/settings.json`
- never user-global Cursor settings by default

### Why this is the best choice

- it keeps behavior scoped to the current workspace/project
- it preserves local reversibility
- it avoids hidden machine-global drift

---

## 2. What is the best "small font" reminder equivalent in Cursor?

### Candidates

- generated compact note in the workspace file
- small README/header snippet in a known local surface
- lightweight status note in a managed settings or comment block

### Selected for this packet

- managed comment blocks in the touched owner files
- reminder text should point to `wake-sleeping-workspaces`
- no claim of a true native Cursor status badge or UI chip

### Why this is the best choice

- it is reversible
- it stays in the files the skill already manages
- it does not require inventing a fake UI integration the IDE may not support

---

## 3. Should the behaviors be one skill with modes or separate skills?

### Candidates

- one skill with mode switches
- separate named skills for each layer and reversal

### Selected for this packet

- separate named skills

Selected names:

- `toggle-soft-sleep-on`
- `toggle-soft-sleep-off`
- `toggle-hibernate-on`
- `toggle-hibernate-off`
- `toggle-ide-ui-off`
- `toggle-ide-ui-on`
- `wake-sleeping-workspaces`

### Why this is the best choice

- matches the requested naming discipline
- keeps prompts explicit
- makes the wake/reversal path discoverable by name

---

## 4. How should wake/discovery track prior state?

### Candidates

- marker comments only
- small sidecar manifest
- deterministic diff/remove against managed blocks only

### Selected for this packet

- a project-local sidecar manifest:
  `.cursor/workspace-sleep-state.json`
- managed comment blocks remain, but the manifest is the source of truth

### Why this is the best choice

- supports partial removal by layer
- avoids guessing ownership from comments alone
- gives the wake skill a clear inventory to inspect

---

## 5. Should "true cold repo" behavior be part of the default pack?

### Candidates

- yes, remove/close workspace folders as part of the same pack
- no, document it as related but different

### Selected for this packet

- no, keep it separate
- document it as stronger, related behavior outside the default sleep pack

### Why this is the best choice

- closing/removing a workspace folder is qualitatively stronger than excludes
- it changes the live workspace shape, not just visibility/indexing
- it deserves explicit operator intent

---

## 6. What surfaces are in scope for default implementation?

### Candidates

- any Cursor/VS Code setting surface
- workspace/project-only surfaces
- user-global settings too

### Selected for this packet

- workspace `.code-workspace`
- project `.vscode/settings.json`
- project `.cursorignore`
- project `.cursor/workspace-sleep-state.json`

Out of scope by default:

- `/Users/joshc/Library/Application Support/Cursor/User/settings.json`

### Why this is the best choice

- it keeps every mutation local and auditable
- it matches the requested scoping rule

---

## 7. How should missing default surfaces behave on first run?

### Candidates

- fail and ask the operator to pre-create files/objects
- create every possible surface eagerly up front
- treat missing owned surfaces as empty state and create only what is needed

### Selected for this packet

- treat missing owned surfaces as empty state
- create only the minimum local structure needed for the requested layer

Examples:

- missing `files.exclude` object => create it when `toggle-ide-ui-off` first
  needs it
- missing `.cursor/workspace-sleep-state.json` => treat as no sleeping targets
  yet, then create on first mutate
- missing workspace `"settings"` block => create the smallest valid `"settings"`
  object

### Why this is the best choice

- avoids unnecessary config churn
- keeps first-run behavior predictable
- prevents the build from depending on pre-seeded settings

---

## Remaining open items

These are still open even though the packet selected defaults:

- exact managed-block marker syntax
- exact JSON schema for `.cursor/workspace-sleep-state.json`
- whether reminder comments live in one file or every touched file
- whether `wake-sleeping-workspaces` should support dry-run listing by default

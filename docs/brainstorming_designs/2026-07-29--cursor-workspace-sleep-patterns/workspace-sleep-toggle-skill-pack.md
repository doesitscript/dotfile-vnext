# Workspace Sleep Toggle Skill Pack

This document is the build contract for the workspace-sleep skill pack.
The corresponding active skills now exist in
`/Users/joshc/develop/global-skills/skills/implementation/`.

The selected choices here come from
[open-design-questions.md](./open-design-questions.md).

---

## Pack purpose

Provide a narrow family of toggle skills that let an operator reduce Cursor
index attention, watcher churn, and IDE UI visibility for chosen project or
folder paths without touching user-global Cursor settings.

---

## Draft skill family

| Skill | Surface owner | Layer |
|---|---|---|
| `toggle-soft-sleep-on` | target project root | `.cursorignore` |
| `toggle-soft-sleep-off` | target project root | `.cursorignore` |
| `toggle-hibernate-on` | active `.code-workspace` or project `.vscode/settings.json` | `files.watcherExclude` plus soft sleep |
| `toggle-hibernate-off` | active `.code-workspace` or project `.vscode/settings.json` | remove watcher layer |
| `toggle-ide-ui-off` | active `.code-workspace` or project `.vscode/settings.json` | `search.exclude` + `files.exclude` plus lower layers |
| `toggle-ide-ui-on` | active `.code-workspace` or project `.vscode/settings.json` | remove UI layer |
| `wake-sleeping-workspaces` | reads target project manifest and touched settings owner | list or clear layers |

---

## Selected implementation contract

### 1. Narrow global skill family with project-scoped mutation

The build target is a narrow global skill family that applies
workspace/project-scoped mutations only, not a broad global machine manager.

Selected shape:

- workspace/project-scoped behavior only
- explicit on/off pair names
- one umbrella wake skill

### 2. Managed blocks where possible

Every inserted setting or ignore entry should be owned by a managed block or a
clearly marked managed JSON/object entry.

Desired behavior:

- add only owned entries
- remove only owned entries
- preserve unrelated existing excludes

### 3. Sidecar state manifest

The pack should record ownership in:

`<project-root>/.cursor/workspace-sleep-state.json`

Minimum fields:

- target path
- project root
- workspace settings owner path if one was touched
- active layers:
  - `soft_sleep`
  - `hibernate`
  - `ide_ui_off`
- inserted patterns/keys
- reminder surfaces
- timestamps

### 4. Compact reminder behavior

The pack should write compact reminder comments in touched local files rather
than invent a global Cursor UI integration.

Reminder text should mention:

- target is sleeping
- active layer(s)
- use `wake-sleeping-workspaces` to wake it

### 5. Distinct visibility layers

The implementation should preserve the difference between:

- agent/index visibility
- machine watcher visibility
- IDE UI visibility

That means removing one layer should not automatically remove stronger or lower
layers unless the operator explicitly asked for a full wake.

### 6. Missing defaults are normal first-run state

The pack should not require pre-seeded settings scaffolding beyond normal
workspace/project files.

Selected first-run contract:

- missing `.cursor/workspace-sleep-state.json` means "no sleeping targets yet"
- missing `files.exclude` / `search.exclude` / `files.watcherExclude` object at
  the chosen owner means "create this object now"
- missing reminder block means "no reminder exists yet"
- existing `.cursorignore` and existing settings files must be merged, not
  rewritten wholesale
- missing workspace/project owner file may be created only when that file is a
  valid local target under the scope rules

### 7. Sane baseline creation rules

Create the minimum valid structure needed for the chosen layer:

- `.cursorignore`
  - if missing, create it with a short header and the managed block only
- `.vscode/settings.json`
  - if missing, create a minimal valid JSON object
- `<active>.code-workspace`
  - if present but missing `"settings"`, create `"settings": {}`
- `.cursor/workspace-sleep-state.json`
  - create on first mutating skill run with an empty tracked-targets structure

The pack should not auto-add unrelated excludes just because a file was
created.

---

## Build sequence

1. Implement `toggle-soft-sleep-on` and `toggle-soft-sleep-off`
2. Implement manifest writing/reading
3. Implement first-run creation helpers for missing local surfaces
4. Implement `toggle-hibernate-on` and `toggle-hibernate-off`
5. Implement reminder comment behavior
6. Implement `toggle-ide-ui-off` and `toggle-ide-ui-on`
7. Implement `wake-sleeping-workspaces`
8. Run the full operator-in-IDE test plan

---

## Pre-build gaps now resolved in the packet

These gaps are now explicitly covered and should not be left to ad-hoc build
decisions:

- first-run behavior for missing `files.exclude`
- first-run behavior for missing state manifest
- merge behavior for existing project settings
- scope prohibition on user-global Cursor settings

---

## Explicitly excluded from default implementation

- user-global Cursor settings
- `.gitignore` mutation
- `.aiignore` mutation
- removing workspace folders from `.code-workspace`
- extension-specific side channels beyond the chosen surfaces

These stay documented but unimplemented by default:

- [experimental-and-not-implemented.md](./experimental-and-not-implemented.md)

---

## Recommended file ownership

### Per target project

- `<project-root>/.cursorignore`
- `<project-root>/.cursor/workspace-sleep-state.json`
- optionally `<project-root>/.vscode/settings.json`

### Per active workspace

- `<active-workspace>.code-workspace` when present and chosen as the settings
  owner

---

## Wake behavior

`wake-sleeping-workspaces` should support:

- list current sleeping targets
- wake one target fully
- wake one target to a lower layer
- wake all targets in the selected project

Default safe behavior:

- dry-run list first
- mutate only when explicitly confirmed

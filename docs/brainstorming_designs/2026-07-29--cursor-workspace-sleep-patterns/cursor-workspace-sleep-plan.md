# Cursor Workspace Sleep And Visibility Patterns

> Build-ready brainstorm packet with active `.cursor/skills/*` implementation.
> Parent packet: [README.md](./README.md)

---

## Purpose

Create a small family of workspace- and project-scoped toggle skills that can
"sleep" a project or folder at different strengths so Cursor spends less effort
indexing, watching, and showing that content while preserving an explicit wake
path.

This packet now records selected design choices, scoped mutation rules, draft
skill names, a sidecar-state model, and a test plan.

---

## Chosen Skill Names

The pack now uses explicit toggle pairs plus one umbrella wake skill:

| Skill name | Meaning |
|---|---|
| `toggle-soft-sleep-on` | Put a target into Cursor index / agent soft sleep |
| `toggle-soft-sleep-off` | Remove only the soft-sleep layer |
| `toggle-hibernate-on` | Add watcher hibernation and ensure soft sleep is present |
| `toggle-hibernate-off` | Remove the watcher hibernation layer |
| `toggle-ide-ui-off` | Hide the target from Search / Explorer and ensure lower layers are present |
| `toggle-ide-ui-on` | Remove the IDE UI invisibility layer |
| `wake-sleeping-workspaces` | List and/or clear one or more sleep layers for selected targets |

The selected names are applied throughout this packet and in the draft skill
pack spec:

- [workspace-sleep-toggle-skill-pack.md](./workspace-sleep-toggle-skill-pack.md)

---

## Danger

Do **not** target:

`/Users/joshc/Library/Application Support/Cursor/User/settings.json`

as part of the default implementation.

Why:

- it is user-global across all windows
- it is easy to lose track of changes there
- it creates drift outside the workspace/project contract

Selected rule:

- all default mutations must stay at the workspace or project level
- project-level files are acceptable
- user-global Cursor settings are documentation-only unless the operator
  explicitly asks for a machine-global exception

See also:

- [experimental-and-not-implemented.md](./experimental-and-not-implemented.md)

---

## Control-Surface Matrix

| Goal | Strongest default surface |
|---|---|
| Agents / Cursor index | `.cursorignore` |
| Extension / IDE watcher CPU | `files.watcherExclude` |
| Search UI | `search.exclude` |
| Explorer visibility | `files.exclude` |
| True cold repo | close/remove workspace folder |

---

## Allowed Mutation Surfaces

Paths below use this machine's layout. Relative paths are project-root relative
unless noted.

### Project-owned index surface

| Surface | Path shape | Default use |
|---|---|---|
| `.cursorignore` | `<project-root>/.cursorignore` | Soft sleep for a chosen target path inside that project root |

### Workspace/project-owned settings surfaces

| Surface | Path shape | Default use |
|---|---|---|
| Workspace settings | `<active>.code-workspace` `"settings"` block | Most-upstream writable owner when a multi-root workspace is active |
| Project settings | `<project-root>/.vscode/settings.json` | Default owner when no `.code-workspace` controls the window |

### Sidecar state surface

| Surface | Path shape | Default use |
|---|---|---|
| State manifest | `<project-root>/.cursor/workspace-sleep-state.json` | Track which layers own which inserted entries and which workspace settings file was touched |

Current repo examples:

- project index surface: [/.cursorignore](/Users/joshc/develop/dotfile-vnext/.cursorignore)
- project settings surface: [settings.json](/Users/joshc/develop/dotfile-vnext/.vscode/settings.json)

---

## Baseline Defaults And Gap Fill

Before build, treat these states as sane defaults rather than as errors:

| Surface | Current repo state | Build rule |
|---|---|---|
| `.cursorignore` | already exists | append only managed sleep entries; preserve existing baseline ignores |
| project `.vscode/settings.json` | already exists | merge into existing JSON; preserve unrelated settings |
| `files.watcherExclude` | already exists in project settings | merge managed entries into the existing object |
| `search.exclude` | already exists in project settings | merge managed entries into the existing object |
| `files.exclude` | missing in project settings today | create on first `toggle-ide-ui-off` use |
| `.cursor/workspace-sleep-state.json` | missing today | treat missing as empty state; create on first mutating sleep action |
| workspace `.code-workspace` `"settings"` | present in likely local workspaces | if missing in another workspace file, create `"settings": {}` on demand |
| reminder comment blocks | missing today | create only when the first relevant layer is applied |

Selected first-run rule:

- missing surface object/file where the pack owns behavior is a normal empty
  state, not a failure
- the pack should create only the minimum local structure needed for the chosen
  layer
- the pack should never "normalize" unrelated settings just because it touched
  the file

---

## Workspace Scope Rule

Selected upstream resolution:

1. resolve the target path to its owning project root
2. always update that project's `.cursorignore` for soft sleep
3. for watcher/UI layers:
   - if an active `.code-workspace` owns the window, write there
   - else write to the project's `.vscode/settings.json`
4. never write the user-global Cursor settings file by default
5. record every touched path and layer in the project-local state manifest

Additional first-run behavior:

6. if the chosen owner file exists but the needed object does not, create just
   that object
7. if the chosen owner file does not exist and it is workspace/project scoped,
   create it with the smallest valid baseline
8. if the chosen owner file is the user-global Cursor settings file, stop
   unless the operator explicitly requested the machine-global exception

The chosen design details are recorded here:

- [open-design-questions.md](./open-design-questions.md)

---

## Layer Behavior

### `toggle-soft-sleep-on`

- add the chosen path to `<project-root>/.cursorignore`
- create or update a managed comment block that points to
  `wake-sleeping-workspaces`
- record the target and layer in the state manifest

### `toggle-soft-sleep-off`

- remove only the managed soft-sleep entry for that target
- preserve stronger layers if they still exist
- update the state manifest

### `toggle-hibernate-on`

- ensure soft sleep is present
- add `files.watcherExclude` for the target at the workspace/project settings
  owner
- write a compact reminder comment block at that owner
- record ownership in the state manifest

### `toggle-hibernate-off`

- remove the watcher-exclude layer for the target
- keep soft sleep if still explicitly owned
- update the state manifest

### `toggle-ide-ui-off`

- ensure soft sleep and hibernate are present
- add `search.exclude` and `files.exclude`
- record the UI layer in the state manifest

### `toggle-ide-ui-on`

- remove `search.exclude` and `files.exclude` for the target
- preserve lower layers unless the operator asked for a full wake
- update the state manifest

### `wake-sleeping-workspaces`

- inspect the state manifest
- list sleeping targets and active layers
- optionally clear one target or all targets
- remove managed blocks and stale reminder comments

---

## Related But Different

These are intentionally **not** default sleep-skill targets. They are tracked
separately as excluded or experimental surfaces:

- user-global Cursor `settings.json`
- `.gitignore`
- `.aiignore`
- closing/removing workspace folders
- extension- or language-server-specific knobs outside the chosen surfaces

See:

- [experimental-and-not-implemented.md](./experimental-and-not-implemented.md)

---

## Draft Skill Pack

This packet now carries the concrete skill-pack contract used by the active
implementation:

- [workspace-sleep-toggle-skill-pack.md](./workspace-sleep-toggle-skill-pack.md)

That document applies the selected choices from
[open-design-questions.md](./open-design-questions.md) across:

- skill names
- state ownership
- managed-block behavior
- reminder behavior
- scope rules
- wake/undo behavior

---

## Testing

The pack now includes an operator-in-the-IDE testing plan with separate
assistant and user actions for every skill/layer:

- [workspace-sleep-skill-testing.md](./workspace-sleep-skill-testing.md)

---

## Apply / Verify / Undo / Change Class

| | |
|--|--|
| **Apply** | Build the draft skill pack against workspace/project surfaces only; use managed blocks and a project-local state manifest |
| **Verify** | Confirm chosen paths appear in the intended `.cursorignore` / settings surfaces, reminder comments are visible, and the state manifest matches the live inserts |
| **Undo** | Run `wake-sleeping-workspaces` or remove only the managed entries recorded in the state manifest |
| **Change class** | Implemented project skill pack with continuing test/documentation follow-through |

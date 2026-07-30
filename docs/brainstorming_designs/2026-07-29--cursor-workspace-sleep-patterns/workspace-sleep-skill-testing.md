# Workspace Sleep Skill Testing

This document defines how to test each draft skill with split responsibilities:

- the assistant makes the file/config mutation
- the user verifies the result in the IDE

The goal is to test both the file changes and the operator-visible effect.

---

## Test target

Use a harmless workspace/project path first, not a critical repo root.

Recommended test target pattern:

- a disposable folder inside a project root
- or a low-risk docs subtree

The same target should be used for the first end-to-end pass so layer
interactions are easy to see.

---

## General test rhythm

For every skill:

1. assistant applies one layer
2. user verifies the exact file changes in the IDE
3. user verifies the visible effect in the IDE
4. assistant removes or changes the layer
5. user confirms the undo path worked

---

## First-run baseline tests

These tests exist specifically to cover the currently missing-but-sane
defaults.

### First-run test A — missing state manifest

### Assistant does

- run the first mutating layer against a target in a project that has no
  `.cursor/workspace-sleep-state.json`

### User does in Cursor

- confirm the manifest file was created only after the mutating action
- confirm the file records the target and active layer
- confirm no unrelated files were created as side effects

### First-run test B — missing `files.exclude`

### Assistant does

- run `toggle-ide-ui-off` against a target where the chosen settings owner has
  no `files.exclude` object yet

### User does in Cursor

- confirm `files.exclude` was created
- confirm only the managed target entry was added there
- confirm existing unrelated settings stayed intact

### First-run test C — missing workspace/project settings object

### Assistant does

- use a test owner file that lacks the needed object such as
  `files.watcherExclude`, `search.exclude`, or a workspace `"settings"` block

### User does in Cursor

- confirm the missing object was created with the minimum valid shape
- confirm the requested managed entry was inserted
- confirm no broad rewrite of the file happened

---

## Test 1 — `toggle-soft-sleep-on`

### Assistant does

- add the chosen target path to the target project's `.cursorignore`
- create/update the project-local state manifest
- add the compact wake reminder comment

### User does in Cursor

- open the changed `.cursorignore` and confirm the managed block exists
- open the state manifest and confirm the target path is listed
- ask Cursor/Agent a question that would normally roam the codebase and confirm
  the target path is no longer an automatic discovery candidate
- verify that opening the exact file/path directly still works

---

## Test 2 — `toggle-soft-sleep-off`

### Assistant does

- remove only the managed soft-sleep entry for the target
- update the state manifest

### User does in Cursor

- confirm the `.cursorignore` managed entry is gone
- confirm the state manifest no longer lists the soft-sleep layer
- ask Cursor/Agent a similar question and confirm the target can again be seen
  by normal project discovery

---

## Test 3 — `toggle-hibernate-on`

### Assistant does

- ensure soft sleep is present
- add `files.watcherExclude` at the selected workspace/project settings owner
- update the state manifest

### User does in Cursor

- open the touched settings file and confirm the watcher exclude entry exists
- verify the state manifest records the settings owner path
- verify the object was created if it was missing before the test
- make a visible file change under the target path from outside the editor or
  via terminal
- confirm the IDE no longer reacts as noisily to changes under that target

Note:

- the watcher effect may need a window reload to become obvious

---

## Test 4 — `toggle-hibernate-off`

### Assistant does

- remove only the watcher exclude layer
- preserve soft sleep if still owned
- update the state manifest

### User does in Cursor

- confirm `files.watcherExclude` no longer contains the target's managed entry
- confirm the target remains soft-slept if that layer is still active
- make another file change and confirm watcher behavior is restored

---

## Test 5 — `toggle-ide-ui-off`

### Assistant does

- ensure lower layers are present
- add `search.exclude` and `files.exclude`
- update the state manifest

### User does in Cursor

- confirm the settings file contains managed `search.exclude` and
  `files.exclude` entries
- confirm `files.exclude` was created if it did not exist before the test
- verify the target path disappears from Explorer
- verify Search no longer returns matches from that target
- verify the state manifest records the UI layer

---

## Test 6 — `toggle-ide-ui-on`

### Assistant does

- remove only the IDE UI invisibility layer
- preserve lower layers unless a full wake was requested
- update the state manifest

### User does in Cursor

- confirm `search.exclude` and `files.exclude` managed entries are gone
- verify the target path returns to Explorer
- verify Search sees the target again
- confirm lower layers remain only if expected

---

## Test 7 — `wake-sleeping-workspaces`

### Assistant does

- run a dry-run list first
- show all tracked targets/layers from the state manifest
- then wake one target or all targets as requested

### User does in Cursor

- confirm the dry-run list matches the visible file/config state
- after wake, confirm managed entries are removed from all touched surfaces
- verify the target is again visible in Explorer and Search
- verify `.cursorignore` no longer contains the managed soft-sleep entry
- verify the state manifest is empty or reduced as expected

---

## End-to-end downgrade test

This is important because the layers stack.

Sequence:

1. assistant applies `toggle-ide-ui-off`
2. user verifies all three layers are active
3. assistant applies `toggle-ide-ui-on`
4. user verifies UI visibility returns but lower layers remain if expected
5. assistant applies `toggle-hibernate-off`
6. user verifies watcher behavior returns while soft sleep remains
7. assistant applies `toggle-soft-sleep-off`
8. user verifies the target is fully awake

---

## Failure questions for every run

If a test fails, capture:

- which file was supposed to change
- which file actually changed
- whether the state manifest matched reality
- whether the visible IDE behavior matched the file state
- whether a reload was required

# Cursor workspace sleep patterns (brainstorm)

**Status:** active design packet for a workspace-sleep skill pack now rebuilt in
`/Users/joshc/develop/global-skills` / not active repo truth beyond design and
test guidance.

This packet captures a build-ready design for reducing Cursor agent/index
noise, file-watcher churn, and IDE UI clutter through layered workspace- and
project-scoped sleep behaviors.

## Scope

- define a ready-to-build project skill pack for project/folder sleep states
- lock workspace/project-only mutation scope
- forbid user-global Cursor settings as a default mutation surface
- name the toggle skills as explicit pairs (`*-on`, `*-off`, `*-sleep`,
  `*-wake`)
- preserve the intended operator UX, including compact reminders and a named
  wake-up path
- include a human-in-the-IDE test plan

## Packet files

- [cursor-workspace-sleep-plan.md](./cursor-workspace-sleep-plan.md)
  Primary ready-to-build plan packet
- [open-design-questions.md](./open-design-questions.md)
  Open decisions plus selected choices used by the rest of the packet
- [workspace-sleep-toggle-skill-pack.md](./workspace-sleep-toggle-skill-pack.md)
  Build contract for the draft skill pack
- [workspace-sleep-skill-testing.md](./workspace-sleep-skill-testing.md)
  Assistant-step + operator-in-IDE verification plan
- [experimental-and-not-implemented.md](./experimental-and-not-implemented.md)
  Related surfaces intentionally excluded from the default implementation

## Treat this packet as

- the design packet for the workspace-sleep skills now implemented in
  `/Users/joshc/develop/global-skills`
- the place where chosen behavior is recorded
- implementation guidance and follow-on test documentation

## Primary note

The selected model distinguishes:

1. agent/index sleep
2. machine-visible watcher hibernation
3. IDE UI invisibility
4. a combined wake path

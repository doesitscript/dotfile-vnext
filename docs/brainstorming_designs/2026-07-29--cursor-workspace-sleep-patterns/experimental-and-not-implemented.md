# Experimental And Not Implemented

This file records related surfaces and behaviors that are intentionally **not**
part of the default workspace-sleep skill pack.

---

## Danger-only surface

### User-global Cursor settings

Path:

`/Users/joshc/Library/Application Support/Cursor/User/settings.json`

Status:

- documented
- danger-only
- not a default mutation target
- not implemented in the draft pack

Reason:

- machine-global scope
- easy to lose track of changes
- outside the chosen workspace/project-only contract

---

## Related but different surfaces

### `.gitignore`

Status:

- not included
- not implemented

Reason:

- Git concern first
- not the clean contract for Cursor sleep behavior

### `.aiignore`

Status:

- not included
- not implemented

Reason:

- advisory context boundary for some tools
- not the Cursor index contract

### Close/remove workspace folder

Status:

- experimental concept only
- not implemented in the default pack

Reason:

- stronger than sleep/exclude behavior
- changes the live workspace shape rather than just visibility/indexing

### Extension- or language-server-specific settings

Status:

- experimental
- not implemented

Examples:

- product-specific indexing toggles
- language-server scan knobs
- extension-owned watcher overrides

Reason:

- harder to generalize cleanly
- out of scope for the initial narrow pack

---

## Not included by default even if useful later

- machine-global hibernate
- machine-global UI invisibility
- machine-global wake state inventory
- automatic workspace-folder removal

These can be revisited later only as explicit follow-on work.

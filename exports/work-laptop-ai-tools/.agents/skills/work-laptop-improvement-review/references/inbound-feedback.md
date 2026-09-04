# Inbound feedback from the work laptop

The external sibling often pushes **corrections** back after a home→laptop
sync. That is expected. Do not treat it as noise.

## Why it happens

| Home / packet assumption | Work laptop reality |
| --- | --- |
| `~/develop/...` | `~/Documents/develop/...` |
| nvm bin == npm global bin | `~/.npmrc` `prefix=` → separate global root |
| Interactive sudo OK every run | Prefer skip become tags day-2 |
| LiteLLM key already in vault on disk | Must hydrate + drop ciphertext |
| Continue/Cline URL shape identical | Continue omits `/v1`; Cline includes it |

The workflow **accepts** these differences. Responsibility is to **capture**
them in `deviations/` so we improve every time we accommodate one.

## Classification

| Signal | Treat as |
| --- | --- |
| Laptop author / corporate identity commit fixing runtime | Inbound feedback |
| Message: missing path, npm shim, empty Continue, sudo hosts | Inbound feedback |
| Parent sync commit only (“sync sibling”, catalog copy) | Home→laptop delivery (still review for missed deviations) |
| Pure docs typo with no runtime claim | Low priority |

## Required outcomes for inbound feedback

1. **Register or update** a deviation id (do not leave only in commit message).
2. **Re-apply recipe** someone can run after wipe/reinstall.
3. **behavior_group** + at least one **generalize_to** peer (or explicit “none”).
4. If the fix is already in a role, set `status: promoted` and keep the entry.

## Anti-pattern (resurface)

```text
Laptop hits bug → one-off fix in sibling → merge → forgotten
→ reinstall / new similar tool → same bug again
```

Correct loop:

```text
Laptop hits bug → register deviation → promote to role/skill when stable
→ checklist peers in behavior_group → day2-apply re-applies
```

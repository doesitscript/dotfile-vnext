---
# Copy to entries/<id>.md and fill. Register the id in register.yaml.

id: example-id
status: accepted  # accepted | promoted | obsolete
behavior_group: npm-global-install
title: Short title
---

## Trigger (what the laptop did differently)

- Environment fact (e.g. `~/.npmrc` has `prefix=...`)
- Symptom (exact error or empty UI)

## Evidence (inbound)

- Commit / PR / chat date:
- Sibling SHA or message:

## Accommodation (what we accepted)

- Packet / role change:
- Why deviation is OK to keep:

## Re-apply (if wipe / reinstall / role re-run)

```bash
# Exact commands or playbook tags
```

## Generalize (same behavior_group)

| Similar tool / config | Same risk? | Status |
| --- | --- | --- |
| e.g. morph-mcp npm global | yes | pending / applied |

## Do not

- Revert to home-Mac-only assumptions without updating this entry

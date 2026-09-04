---
id: homebrew-uv-idempotence
status: promoted
behavior_group: homebrew-idempotence
title: Precheck brew list before install (uv)
---

## Trigger

- `community.general.homebrew` failed when `uv` was already current / dependents noise.

## Accommodation

- `brew list --versions` first; install only when absent.
- Playbook env: `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK`, `HOMEBREW_NO_AUTO_UPDATE` as needed.

## Re-apply

- Keep role precheck; do not “fix” by forcing brew upgrade on day-2.

## Generalize

- Other formula installs on this packet that fail when already present — copy precheck pattern.

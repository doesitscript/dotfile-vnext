---
id: bootstrap-openssl-content-gate
status: promoted
behavior_group: bootstrap-preflight
title: Bootstrap OpenSSL-skip gate via python mac.yml content (not only .packet-revision)
---

## Trigger (what the laptop did differently)

- Bootstrap previously failed closed on `.packet-revision` SHA/revision mismatch
  even when `roles/python/tasks/mac.yml` already had the OpenSSL-skip tasks
- Partial sync / dirty trees produced false “stale packet” failures
- The real danger is the **old** brew task
  `Ensure Python tooling dependencies are installed on macOS` reinstalling
  `openssl@3`

## Evidence (inbound)

- Sibling working-tree bootstrap matched parent packet (revision-file gate
  removed; content greps retained)
- `.packet-revision` still ships as a sync/documentation marker
  (`python_mac_revision=openssl-skip-v2`)

## Accommodation (what we accepted)

- `bootstrap/bootstrap-macos-ansible.sh` `require_current_python_brew_tasks`:
  - fails if the stale brew-installer task name is still present
  - fails if `Report existing OpenSSL instead of reinstalling` is missing
  - logs git HEAD when available; does **not** fail solely on
    `.packet-revision` mismatch
- Contract constants `PACKET_REVISION_*` remain for the marker file and
  human docs; they are not the live fail gate

## Re-apply (if wipe / reinstall / role re-run)

```bash
# From the packet / sibling checkout on the work Mac:
./bootstrap/bootstrap-macos-ansible.sh
# or after git pull:
rg -n "Report existing OpenSSL|Ensure Python tooling dependencies are installed on macOS" \
  roles/python/tasks/mac.yml
# expect: Report existing OpenSSL present; old Ensure Python tooling... absent
```

## Generalize (same behavior_group)

| Similar tool / config | Same risk? | Status |
| --- | --- | --- |
| Other bootstrap preflights keyed only to a revision file | yes | prefer content probes of the protected task |
| Day-2 playbook after partial sync | yes | verify role task text, not only HEAD SHA |

## Do not

- Reintroduce a hard fail that blocks bootstrap when mac.yml is already correct
- Re-enable `community.general.homebrew` openssl install/upgrade in python mac tasks

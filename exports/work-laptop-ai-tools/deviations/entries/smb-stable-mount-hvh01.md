---
id: smb-stable-mount-hvh01
status: promoted
behavior_group: smb-share-mount
title: Stable HVH-01 public mount at ~/mnt/hvh-01-public (unmount Finder /Volumes first)
---

## Trigger (what the laptop did differently)

- Finder already mounted `\\HOM-LAB-HVH-01\public` under `/Volumes/...`
- macOS rejected a second mount at the packet’s stable path
  `~/mnt/hvh-01-public` (`WORK_LAPTOP_PUBLIC_FOLDER`)
- Copy helpers then pointed at a missing mount; rsync failed with missing source

## Evidence (inbound)

- Inbox `noted_diffs.md` (2026-09-09) — stable mount + Finder duplicate note
- Sibling-only `helpers/work-mac-local-models/setup_shares.sh` (was not in
  parent packet; docs already referenced it)
- Hardcoded `SMB_USER=joshc` would break the work laptop (`a805120`)

## Accommodation (what we accepted)

- Packet helper `helpers/work-mac-local-models/setup_shares.sh` unmounts any
  existing SMB mount of that share, then mounts at `~/mnt/hvh-01-public`
- `SMB_USER` defaults to `$USER` (override with env if needed)
- Asserts `models/` exists (HVH-01 only; HVH-02 public has no `models/`)

## Re-apply (if wipe / reinstall / role re-run)

```bash
cd ~/Documents/develop/work-laptop-ai-tools   # or sibling path on laptop
helpers/work-mac-local-models/setup_shares.sh
# optional: SMB_USER=a805120 helpers/work-mac-local-models/setup_shares.sh
source helpers/work-mac-local-models/share-paths.sh
test -d "${WORK_LAPTOP_PUBLIC_FOLDER}/models"
```

## Generalize (same behavior_group)

| Similar tool / config | Same risk? | Status |
| --- | --- | --- |
| Any work-laptop SMB mount that assumes `~/mnt/...` while Finder owns `/Volumes` | yes | apply same unmount-then-stable-mount pattern |
| Future Ansible `present|absent` mount role for this packet | yes | encode this helper’s behavior |
| HVH-02 public mounts | no models/ — do not use for model copy | documented in share_topology.md |

## Do not

- Copy the controller path `~/HomelabSMB/hvh-01-public` onto the work laptop
- Hardcode home-Mac username `joshc` as the SMB user
- Stage model weights on HVH-02 public

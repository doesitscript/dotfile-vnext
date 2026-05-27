# NetBox service inventory should use hybrid preview, not direct auto-write

## What happened

The repo already had a good curated NetBox service model for the GPU lane, but
there was pressure to make service capture more automatic.

The dangerous shortcut would have been to let live Docker or K3s runtime state
write NetBox directly.

## What we learned

For this repo, the durable middle ground is:

- keep repo seed data as the only NetBox mutation authority
- add read-only runtime discovery for Docker and K3s
- compare curated repo state, runtime state, and live NetBox state
- reconcile in repo first, then seed NetBox

## Why this is better here

- it preserves code-first recovery for NetBox
- it keeps names, tags, comments, and custom fields intentional
- it makes drift visible without turning temporary runtime state into source of truth
- it scales better than permanent manual curation alone

## The tradeoff

Hybrid preview is not zero-maintenance:

- operators still need to review drift
- repo seed data still needs updates when the intended service inventory changes

That extra review is worth it here because the alternative is allowing runtime
noise or temporary breakage to churn NetBox.

## Proven workflow

Use:

1. storage/gpu lane curated `services:` blocks in `roles/ipam_netbox/defaults/main.yml`
2. read-only preview via `ipam_netbox_service_inventory_discovery_preview`
3. curated seed apply via `ipam_netbox_seed_*`

Do not skip straight from runtime discovery to NetBox mutation.

---
title: "Product hydrate proof — windows_artifact_cache after reclaim-to-H"
status: verified
authority: operator
retrieved_at: "2026-09-23"
last_reviewed_at: "2026-09-23"
---

# Product present / hydrate proof (HVH-02)

## Intent

Prove that after reclaim-to-H, product-shaped `windows_artifact_cache`
`state=present` (same cold-first `cold_paths` order as `hyperv_ubuntu_vm`
`present.yml` / `present_server_iso.yml`) restores Azure + remaster rebuild
bases from cold, and a second pass reports `hot_already` (skip download /
remaster restore). Remaster hot vs cold signatures must match so
`present_server_iso` would skip remaster upload.

Live VMs were **not** started/stopped; full docker/k3s `present` was not run.

## Commands

```bash
# Baseline probe (cold present, hot rebuild bases missing; Docker VM Running)
# C:\Windows\Temp\product_hydrate_baseline.ps1 / product_hydrate_after.ps1

# Check-mode (insufficient — see Outcomes)
bin/codex-env ansible-playbook /tmp/product_hydrate_proof.yaml \
  -i inventory/inventory.yaml --check

# Live product-shaped hydrate proof (pass1 cold→hot, pass2 hot_already)
bin/codex-env ansible-playbook /tmp/product_hydrate_proof.yaml \
  -i inventory/inventory.yaml

# Restore reclaim posture
bin/codex-env ansible-playbook /tmp/product_hydrate_reoffload.yaml \
  -i inventory/inventory.yaml
```

Proof playbooks lived under `/tmp/` for this turn (not committed steady-state).

## Outcomes

| Step | Result | Evidence |
| --- | --- | --- |
| Baseline | cold Azure/remaster present; hot rebuild bases missing; Docker VM Running on canonical VHDX | probe |
| `--check` | **blocked as proof** — hydrate tasks report changed but result maps lack `source` under check | assert failed: dict has no attribute `source` |
| Pass 1 live | **pass** — all four `source=cold`, `hot_exists=true` | PLAY RECAP `ok=52 changed=4 failed=0` (full run) |
| Pass 2 live | **pass** — all four `source=hot_already`, no remaster/Azure re-copy | debug summary |
| Remaster sig | **pass** — `remaster_signatures_match: true` | hot vs cold signature compare |
| Re-offload | **pass** — four `hot_removed=true`; hot rebuild bases missing again; cold kept | reoffload PLAY RECAP + after probe |

Pass-1 / pass-2 summary (live):

```json
{
  "pass1_sources": {"archive": "cold", "vhd": "cold", "remaster_iso": "cold"},
  "pass2_sources": {"archive": "hot_already", "vhd": "hot_already", "remaster_iso": "hot_already"},
  "remaster_signatures_match": true
}
```

Hot paths used (inventory storage root `D:\` on HVH-02):

- `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\` — Azure archive + VHD
- `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-dkr-02\` — remaster ISO + signature

## Doc / inventory drift from proof

- None requiring code change. Product path order already cold-first.
- HRL Q&A promoted `draft` → `reviewed` to match live contract; indexes rebuilt.
- Default reclaim profiles unchanged (`hyperv_ubuntu_rebuild_bases` only).

## NetBox / identity lag

Read-only: legacy Hyper-V VM `server-225-ubuntu` absent; canonical VHDX attached;
`live-object-registry.yml` already lists `server-225-ubuntu` →
`hom-lab-ctl-dkr-02`. **No NetBox tag run** (no lag evidence).

## Disposition

`verified` — product hydrate contract after reclaim-to-H proved and reclaim
posture restored.

---
title: "Homelab routing layer — GL.iNet Flint / OpenWrt"
status: brainstorm
created: 2026-09-01
hardware_eta: "1–2 days (operator)"
execution_status: packet-active
supersedes:
  - docs/brainstorming_designs/raw-needs-import-and-format.md
  - docs/brainstorming_designs/draft-needs-import-router-considerations.md
---

# Homelab routing layer — GL.iNet Flint / OpenWrt

Brainstorm packet: **Flint routing layer** + **Windows static management IP** +
server/repo actions. One coordinated homelab network hardening effort.

## How to treat this material

- **Not** active repo truth, approved scope, or a `docs/plans/` packet.
- Promote through `docs/intake/` or `docs/plans/` before treating as SSOT.
- Do not delete Windows/Hyper-V networking until replacements are validated.

## Recommended execution order

```text
1. windows-hyperv-management-static-ip-plan.md  Phase 0 (BIOS) → Phases 1–4
2. ansible-repo-actions-now.md                 server/repo (parallel where safe)
3. flint-openwrt-routing-layer-plan.md         after stable .158 / .234 on Windows
```

## Packet contents

| File | Purpose | Execute marking |
| --- | --- | --- |
| [windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md) | **Windows static IP** — both HVH hosts, BIOS gate, Ansible phases | → `.executed.md` when done |
| [windows-hyperv-management-static-ip-ai-brief.md](windows-hyperv-management-static-ip-ai-brief.md) | Agent task slice for static IP plan | → `.executed.md` when done |
| [flint-openwrt-routing-layer-plan.md](flint-openwrt-routing-layer-plan.md) | Flint L3 cutover, GT6 → AP | → `.executed.md` when done |
| [flint-openwrt-routing-layer-supplement.md](flint-openwrt-routing-layer-supplement.md) | Routing-layer analysis (Flint scope only) | reference; rename optional |
| [ansible-repo-actions-now.md](ansible-repo-actions-now.md) | Portproxy, Traefik, orchestration | → `.executed.md` when done |

**Document boundary:** supplement = Flint/routing only; actions-now = server/repo;
static IP plan = Windows `host_ip` on management vNIC.

## Execution marking (this packet)

When a plan file in this folder is **fully executed**:

1. Set `execution_status: executed` and `executed_at: YYYY-MM-DD` in YAML frontmatter.
2. Rename `filename-plan.md` → `filename-plan.executed.md` (insert `.executed` before `.md`).

Convention repo-wide from **2026-09-01**:
[brainstorming_designs README § Executed plan marking](../README.md#executed-plan-marking).

Do **not** rename until the plan’s phases are verified. Partial work stays un-suffixed.

## Status

| Workstream | State |
| --- | --- |
| Static IP Phase 0 (HVH-01 BIOS) | **in progress** — shutdown sent 2026-09-01 |
| Static IP Phases 1–4 (Ansible) | **not started** — waiting on BIOS |
| Flint hardware | pending (ETA ~1–2 days) |
| Flint cutover | not started |
| ansible-repo-actions-now | active reference |

## Related repo surfaces

- `inventory/host_vars/hom-lab-hvh-{01,02}.yaml`
- `roles/hyperv_networking`
- `inventory/group_vars/all/homelab_router_gt6.yml`
- `docs/diagnostics/hyperv-router-static-route-guide.md`

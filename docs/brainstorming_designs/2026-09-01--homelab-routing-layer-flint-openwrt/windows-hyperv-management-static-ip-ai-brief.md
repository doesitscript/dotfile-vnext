---
title: "AI brief — Hyper-V management static IPv4 (agent execution slice)"
status: brainstorm
created: 2026-09-01
parent_plan: windows-hyperv-management-static-ip-plan.md
execution_status: pending
executed_at: null
---

# AI brief — Hyper-V management static IPv4

**Canonical plan:** [windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md)
(phases, both hosts, BIOS prerequisite, execution marking).

This file is the **agent execution slice** — task-level steps for Phase 1+
only. **Do not run Phases 1–4 until** operator completes Phase 0 (onboard Wi‑Fi
disabled in BIOS on HVH-01).

---

## Execution marking

When the agent completes all Ansible phases in the parent plan:

1. Mark parent plan per its § Execution marking.
2. Rename this file → `windows-hyperv-management-static-ip-ai-brief.executed.md`
3. Set `execution_status: executed` and `executed_at` in frontmatter.

---

## Agent steps (Phase 1 — role extension)

**Module policy (research 2026-09-01):** No Galaxy/community module assigns
Windows host IPv4. Use **`ansible.windows.win_powershell`** for DHCP disable +
`New-NetIPAddress` + interface-scoped gateway routes; use
**`ansible.windows.win_dns_client`** for DNS; do **not** use `win_route` for the
default gateway (no interface binding). Extend existing
`routed_private_subnet.yml` patterns — do not fork a second DNS/gateway
implementation.

1. Add `management_os_ipv4_mode`, `management_os_ipv4_address`,
   `management_os_ipv4_prefix_length` to `hyperv_config` defaults and
   `meta/argument_specs.yml`.
2. Implement `tasks/management_os_static_ipv4.yml`:
   - `win_powershell`: `Set-NetIPInterface -Dhcp Disabled`; remove stale DHCP
     addresses; `New-NetIPAddress` with `management_os_ipv4_address` /
     `management_os_ipv4_prefix_length`; gateway via existing
     `New-NetRoute` idiom on `_hyperv_routed_public_adapter_alias`.
   - `ansible.windows.win_dns_client`: `adapter_names` + `dns_servers` from
     `public_dns_servers_ipv4`.
   - Reuse vars from `routed_private_subnet.yml` (`host_ip`, `public_gateway_ipv4`,
     adapter alias resolution).
3. Wire include in `main.yml` after External switch when `mode == static`; refactor
   gateway/DNS block in `routed_private_subnet.yml` to share `win_dns_client`.
4. Update role README — document module matrix and “no upstream IP module” rationale.

## Agent steps (Phase 2 — HVH-02)

- Set inventory vars per parent plan.
- Run preview + `hyperv_networking` with `--limit HOM-LAB-HVH-02`.
- Capture evidence in plan receipt (do not rename files until both hosts done if
  doing single execution batch).

## Agent steps (Phase 3 — HVH-01)

- **Gate:** confirm operator finished BIOS disable (single Wi‑Fi NIC visible).
- Set inventory vars per parent plan.
- Run preview + apply `--limit HOM-LAB-HVH-01`.

## Agent steps (Phase 4)

- Set `management_os_boot_recovery_state: absent` on both hosts (if not already).
- Re-run apply; confirm scheduled task absent.

---

**Do not** execute until user confirms Phase 0 complete.

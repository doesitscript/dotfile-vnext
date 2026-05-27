---
name: Name Alignment + NetBox Metadata
lifecycle: incomplete
moved_from: .cursor/plans/name_alignment_+_netbox_metadata_ba618ac6.plan.md
overview: Rename all server-225 inventory names to the canonical compact scheme, eliminate umbrella/delegation-wrapper roles, promote sub-roles to top-level capability roles, update group/metadata vars, add NetBox custom fields and stack tags, and wire Docker labels into all compose templates.
open_work: Track H5 — retire static inventory and migrate group_vars to NetBox-derived groups (separate plan).
todos:
  - id: pre-plan-windows
    content: "PRE-PLAN COMPLETE: Windows computers renamed to hom-lab-ctl-hvh-01 and hom-lab-ctl-hvh-02. IMMEDIATE ACTION: update ansible_host: DESKTOP-VLLM -> 192.168.50.158 (IP, safer than hostname until DNS resolves) in inventory/host_vars/hom-lab-ctl-hvh-02.yaml"
    status: completed
  - id: track-g-delete-wrappers
    content: "Delete delegation-wrapper sub-roles (server_225/gpu_driver_validation, server_225/windows_base, server_225/stacks_main, network_server/windows_base, network_server/backup_baseline); update consumer comments in windows_base and common/gpu_driver_validation"
    status: completed
  - id: track-g-promote-stacks-network
    content: "Move roles/network_server/stacks_network/ -> roles/stacks_fuzlang_net/; update deploy_network_stacks.yaml and deploy_network_stacks_hvh02.yaml callers; update Track D/E references"
    status: completed
  - id: track-g-promote-other-subroles
    content: "Move roles/network_server/docker_runtime/ -> roles/hyperv_docker_runtime/; move roles/network_server/storage_layout/ -> roles/hyperv_storage_layout/; add deprecation note to roles/network_server/README.md"
    status: completed
  - id: track-a-host-file-rename
    content: Rename inventory/host_vars/server-225-ubuntu.yaml to hom-lab-ctl-dkr-02.yaml and update all inventory files (inventory.yaml, hosts_mapping.yaml, host_vars, group_vars)
    status: completed
  - id: track-a-playbooks
    content: "Update all playbooks: replace hosts: server-225-ubuntu with hosts: hom-lab-ctl-dkr-02"
    status: completed
  - id: track-a-roles
    content: "Update all roles: ipam_netbox defaults (8 virtual_machine refs), seed task names, backup_db, hyperv_ubuntu_vm specs, automation_awx, k3s_litellm_gateway, logging_alloy template"
    status: completed
  - id: track-b-group-rename
    content: "Rename inventory group server_225 -> hvh_02 in inventory.yaml; rename group_vars/server_225/ -> group_vars/hvh_02/; rename roles/server_225/ -> roles/hvh_02/; update groups['server_225'] conditions in secrets_render, secrets_verify, scheduled_task_verify, gpu_driver_validation, windows_base"
    status: completed
  - id: track-c-metadata-vars
    content: "Update physical_node: server-225 and host_name: Server-225 to hom-lab-ctl-hvh-02 in group_vars/hvh_02/main.yml"
    status: completed
  - id: gap1-vault-rename
    content: "Decrypt inventory/group_vars/server_225/vault.yml, rename vault_server_225_win_password -> vault_hvh_02_win_password, re-encrypt after dir rename, update 3 comment lines in host_vars"
    status: completed
  - id: track-f-additional-refs
    content: "Update ensure_api_token.yml tag name; hom-lab-ctl-hvh-02-ipv6.yaml; host_vars_windows.yml.j2 comment; contracts/fuzlang.contract.yaml (4 Server-225 refs); framework-netbox-modeling.mdc rule text; delete facts/server-225.json; remove server-225-wsl dead code from scripts/lib.sh"
    status: completed
  - id: track-d-tags
    content: Add 4 stack-* tags (stack-logging, stack-fuzlang-net, stack-netbox, stack-semaphore) to ipam_netbox/defaults/main.yml
    status: completed
  - id: track-d-custom-fields-task
    content: Create roles/ipam_netbox/tasks/seed_custom_fields.yml using netbox_custom_field module; wire into present.yml and add playbook tag
    status: completed
  - id: track-d-service-model
    content: "Add custom_fields: blocks to all 9 service entries in ipam_netbox/defaults/main.yml; strip structured YAML blobs from comments:; update deployed_by_role to stacks_fuzlang_net after Track G"
    status: completed
  - id: track-e-docker-labels
    content: Add com.homelab.stack and com.homelab.deployed-by labels to all 3 compose templates and the 2 docker_container tasks in logging_loki; use stacks_fuzlang_net role name after Track G
    status: completed
  - id: track-h-nb-inventory-primary
    content: "POST-PLAN: H1–H4 nb_inventory promotion (H5 separate: retire static inventory)"
    status: completed
  - id: track-h5-static-inventory-retirement
    content: "FOLLOW-UP PLAN: Remove inventory/inventory.yaml from ansible.cfg; migrate group_vars to NetBox-derived group names"
    status: pending
isProject: false
---

# Name Alignment + NetBox Service Metadata Plan

---

## Execution order (dependency-sequenced)

```
PRE-PLAN (user, manual)
  └─ Windows computer rename + update ansible_host in hom-lab-ctl-hvh-02.yaml

Track G  ← do first: cleans up role structure before umbrella dirs are renamed
  G1: Delete delegation-wrapper sub-roles (zero callers, safe to delete)
  G2: Promote stacks_network → stacks_fuzlang_net (update 2 playbook callers)
  G3: Promote docker_runtime → hyperv_docker_runtime
      Promote storage_layout → hyperv_storage_layout
      Deprecate network_server umbrella (now empty shell)

Track A  ← inventory/playbook/role rename: server-225-ubuntu → hom-lab-ctl-dkr-02
  A1: Rename host_vars file; update inventory.yaml, hosts_mapping, group_vars
  A2: Update playbook hosts: lines
  A3: Update role refs (ipam_netbox, logging_alloy, etc.)

Track B  ← group rename: server_225 → hvh_02
  B1: Rename group key in inventory.yaml
  B2: Rename group_vars/server_225/ → group_vars/hvh_02/
  B3: Rename roles/server_225/ → roles/hvh_02/ (emptied by Track G)
  B4: Fix groups['server_225'] conditions in 5 common role files

Track C  ← metadata vars: physical_node, host_name
Gap 1   ← vault variable rename (tied to Track B)

Track F  ← additional server-225 reference cleanup + deletions

Tracks D/E  ← NetBox custom fields + Docker labels (independent; do last)
```

---

## Complete name mapping

| What | Old name | New name |
|---|---|---|
| Ubuntu Docker VM (inventory key + guest hostname) | `server-225-ubuntu` | `hom-lab-ctl-dkr-02` |
| Ansible group | `server_225` | `hvh_02` |
| `group_vars` directory | `inventory/group_vars/server_225/` | `inventory/group_vars/hvh_02/` |
| Role umbrella directory | `roles/server_225/` | `roles/hvh_02/` |
| Physical node metadata var | `physical_node: server-225` | `physical_node: hom-lab-ctl-hvh-02` |
| Host display name var | `host_name: Server-225` | `host_name: hom-lab-ctl-hvh-02` |
| Windows computer name `DESKTOP-VLLM` | manual rename before plan | short form ≤14 chars |
| Windows computer name `AI-NET-SERVER` | manual rename before plan | short form ≤14 chars |

## Role structural changes

| Old location | Status | New location | Reason |
|---|---|---|---|
| `roles/server_225/gpu_driver_validation/` | **Delete** | — | Delegation wrapper only; callers use `common/gpu_driver_validation` directly |
| `roles/server_225/windows_base/` | **Delete** | — | Delegation wrapper only |
| `roles/server_225/stacks_main/` | **Delete** | — | Empty stub (README only) |
| `roles/network_server/windows_base/` | **Delete** | — | Delegation wrapper only |
| `roles/network_server/backup_baseline/` | **Delete** | — | Legacy scaffold; active work moved to `windows_server_backup` |
| `roles/network_server/stacks_network/` | **Promote** | `roles/stacks_fuzlang_net/` | Real implementation; named for the capability (fuzlang-net stack), not the node |
| `roles/network_server/docker_runtime/` | **Promote** | `roles/hyperv_docker_runtime/` | Real implementation; not yet wired to a playbook |
| `roles/network_server/storage_layout/` | **Promote** | `roles/hyperv_storage_layout/` | Real implementation; not yet wired to a playbook |
| `roles/network_server/` (umbrella) | **Deprecate** | README deprecation note | Empty shell after sub-roles promoted; leave stub |
| `roles/server_225/` (umbrella) | **Rename** | `roles/hvh_02/` | Empty after G1; rename in Track B alongside group |

---

## PRE-PLAN — Status: COMPLETE (Windows rename done)

Both Windows computers have been renamed:
- `DESKTOP-VLLM` → `hom-lab-ctl-hvh-02` ✓
- `AI-NET-SERVER` → `hom-lab-ctl-hvh-01` ✓

**Immediate action before any other step (first file change in the plan):**

Update [`inventory/host_vars/hom-lab-ctl-hvh-02.yaml`](inventory/host_vars/hom-lab-ctl-hvh-02.yaml) line 8:

```yaml
# Before:
ansible_host: "DESKTOP-VLLM"

# After — permanent. IP is the correct pattern for ansible_host in this project:
ansible_host: "192.168.50.158"
```

Also update the comment on line 4 to remove the `DESKTOP-VLLM` reference.

**This is a permanent change, not temporary.** Reasons:
- `hom-lab-ctl-hvh-01` already uses `ansible_host: 192.168.50.234` (IP) — this is the established pattern
- `nb_inventory` will also use IPs via `compose: ansible_host: primary_ip4.address.split('/')[0]` — static and dynamic inventory align
- The inventory key (`hom-lab-ctl-hvh-02:`) carries the canonical name; `ansible_host` is only the connection target
- No local DNS means hostname-based `ansible_host` would fail on every Ansible run

`hom-lab-ctl-hvh-01` uses `ansible_host: 192.168.50.234` (IP already) — no change needed.

---

## NetBox / shadow inventory path (background)

The Windows rename makes the names converge: NetBox already has `hom-lab-ctl-hvh-02` as the device name. The mismatch (`DESKTOP-VLLM` on Windows vs `hom-lab-ctl-hvh-02` in NetBox) is now gone.

`nb_inventory` is already configured in `inventory/netbox.yml` and wired alongside the static inventory in `ansible.cfg`. It queries hosts tagged `ansible-managed` and builds `ansible_host` from `primary_ip4` in NetBox — so it's IP-based, same pattern as the static inventory.

See **Track H** below for the steps to promote it to primary.

---

## Track G — Role structural cleanup (do first)

### G1 — Delete delegation-wrapper sub-roles

All 5 are pure wrappers with zero playbook callers. Verified safe to delete:

- **Delete** `roles/server_225/gpu_driver_validation/` — `validate_windows_gpu_hosts.yaml` already calls `common/gpu_driver_validation` directly
- **Delete** `roles/server_225/windows_base/` — callers use `roles/windows_base` directly
- **Delete** `roles/server_225/stacks_main/` — empty stub, README only
- **Delete** `roles/network_server/windows_base/` — callers use `roles/windows_base` directly
- **Delete** `roles/network_server/backup_baseline/` — legacy scaffold, active work in `windows_server_backup`

Update the consumer list comments in:
- [`roles/windows_base/tasks/main.yml`](roles/windows_base/tasks/main.yml) line 10 — remove `server_225/windows_base` and `network_server/windows_base` from "Consumed by:" comment
- [`roles/common/gpu_driver_validation/tasks/main.yml`](roles/common/gpu_driver_validation/tasks/main.yml) line 7 — remove `server_225/gpu_driver_validation` from "Consumed by:" comment

### G2 — Promote `stacks_network` → `roles/stacks_fuzlang_net/`

- **Move** `roles/network_server/stacks_network/` → `roles/stacks_fuzlang_net/`
- Update `roles/stacks_fuzlang_net/tasks/main.yml` header comment (role name)
- Update [`playbooks/deploy_network_stacks.yaml`](playbooks/deploy_network_stacks.yaml) line 10: `role: network_server/stacks_network` → `role: stacks_fuzlang_net`
- Update [`playbooks/deploy_network_stacks_hvh02.yaml`](playbooks/deploy_network_stacks_hvh02.yaml) line 13: same change; also update `hosts: server-225-ubuntu` → `hosts: hom-lab-ctl-dkr-02` (Track A work but same file)

Note: The role's internal Docker filter `com.docker.compose.project=fuzlang-net` and `COMPOSE_PROJECT_NAME=fuzlang-net` stay unchanged — that's the stack's runtime identity, not the role name.

### G3 — Promote remaining sub-roles to top-level

- **Move** `roles/network_server/docker_runtime/` → `roles/hyperv_docker_runtime/`
- **Move** `roles/network_server/storage_layout/` → `roles/hyperv_storage_layout/`
- No playbook callers to update (not yet wired; wiring is follow-up work)
- Add deprecation notice to `roles/network_server/README.md`: sub-roles have been promoted; this umbrella is a stub

---

## Track A — Rename `server-225-ubuntu` → `hom-lab-ctl-dkr-02`

### Inventory files

- **Rename** [`inventory/host_vars/server-225-ubuntu.yaml`](inventory/host_vars/server-225-ubuntu.yaml) → `inventory/host_vars/hom-lab-ctl-dkr-02.yaml`
- [`inventory/inventory.yaml`](inventory/inventory.yaml) — 3 occurrences of host key `server-225-ubuntu:`
- [`inventory/hosts_mapping.yaml`](inventory/hosts_mapping.yaml) — crosswalk entry
- [`inventory/host_vars/hom-lab-ctl-hvh-02.yaml`](inventory/host_vars/hom-lab-ctl-hvh-02.yaml) — `hyperv_ubuntu_docker_vm_hostname` and `hyperv_ubuntu_docker_vm_inventory_host`
- [`inventory/host_vars/hom-lab-ctl-k3s-02.yaml`](inventory/host_vars/hom-lab-ctl-k3s-02.yaml) — cross-references
- [`inventory/host_vars/mac-dev.yaml`](inventory/host_vars/mac-dev.yaml) — cross-references
- [`inventory/group_vars/server_225/main.yml`](inventory/group_vars/server_225/main.yml) — `docker_engine_host: "server-225-ubuntu"` and header comment
- [`inventory/group_vars/all.yaml`](inventory/group_vars/all.yaml), `dev_3090.yaml`, `dev_workstation.yaml` — any references

### Playbooks (change `hosts: server-225-ubuntu`)

- [`playbooks/deploy_ansible_ui_semaphore.yaml`](playbooks/deploy_ansible_ui_semaphore.yaml)
- [`playbooks/deploy_automation_awx.yml`](playbooks/deploy_automation_awx.yml)
- [`playbooks/deploy_ipam_netbox.yaml`](playbooks/deploy_ipam_netbox.yaml) — 7 `hosts:` lines + comments
- [`playbooks/deploy_network_stacks_hvh02.yaml`](playbooks/deploy_network_stacks_hvh02.yaml) — `hosts:` line (role caller already updated in G2)
- [`playbooks/deploy_development_nodes.yaml`](playbooks/deploy_development_nodes.yaml), [`playbooks/site.yaml`](playbooks/site.yaml), [`playbooks/role_only.yaml`](playbooks/role_only.yaml) — comment/reference cleanup

### Roles

- [`roles/ipam_netbox/defaults/main.yml`](roles/ipam_netbox/defaults/main.yml) — 8 `virtual_machine: server-225-ubuntu` service entries
- [`roles/ipam_netbox/tasks/seed_server_225_model.yml`](roles/ipam_netbox/tasks/seed_server_225_model.yml) — task names + debug strings
- [`roles/ipam_netbox/tasks/backup_db.yml`](roles/ipam_netbox/tasks/backup_db.yml) — delegate_to / target references
- [`roles/hyperv_ubuntu_vm/meta/argument_specs.yml`](roles/hyperv_ubuntu_vm/meta/argument_specs.yml) — example values
- [`roles/automation_awx/defaults/main.yml`](roles/automation_awx/defaults/main.yml)
- [`roles/k3s_litellm_gateway/defaults/main.yml`](roles/k3s_litellm_gateway/defaults/main.yml)
- [`roles/logging_alloy/templates/alloy_macos.alloy.j2`](roles/logging_alloy/templates/alloy_macos.alloy.j2) — Loki endpoint hostname

---

## Track B — Rename `server_225` group → `hvh_02`

- [`inventory/inventory.yaml`](inventory/inventory.yaml) — rename group key `server_225:` → `hvh_02:`
- **Rename directory** `inventory/group_vars/server_225/` → `inventory/group_vars/hvh_02/`
- **Rename role directory** `roles/server_225/` → `roles/hvh_02/` (emptied by Track G; just a README at this point)
- Update internal header comment in the renamed `main.yml`

### Critical — `groups['server_225']` conditions in common roles

These silently break (condition always `False`) after the group rename — **must update to `groups['hvh_02']`**:

- [`roles/common/secrets_render/tasks/main.yml`](roles/common/secrets_render/tasks/main.yml) — 1 condition
- [`roles/common/secrets_verify/tasks/main.yml`](roles/common/secrets_verify/tasks/main.yml) — 3 conditions
- [`roles/common/scheduled_task_verify/tasks/main.yml`](roles/common/scheduled_task_verify/tasks/main.yml) — 8 conditions
- [`roles/common/gpu_driver_validation/tasks/main.yml`](roles/common/gpu_driver_validation/tasks/main.yml) — verify and update
- [`roles/windows_base/tasks/main.yml`](roles/windows_base/tasks/main.yml) — verify and update

---

## Track C — Physical node metadata vars

In [`inventory/group_vars/hvh_02/main.yml`](inventory/group_vars/server_225/main.yml) (after Track B rename):

```yaml
# Before:
physical_node: server-225
host_name: Server-225

# After:
physical_node: hom-lab-ctl-hvh-02
host_name: hom-lab-ctl-hvh-02
```

---

## Gap 1 — Vault variable rename (run alongside Track B)

`vault_server_225_win_password` in `inventory/group_vars/server_225/vault.yml`. All consumers are commented-out lines.

1. `ansible-vault decrypt inventory/group_vars/server_225/vault.yml`
2. Rename `vault_server_225_win_password` → `vault_hvh_02_win_password`
3. `ansible-vault encrypt inventory/group_vars/hvh_02/vault.yml` (after directory rename)
4. Update comment lines in:
   - [`inventory/host_vars/hom-lab-ctl-hvh-02.yaml`](inventory/host_vars/hom-lab-ctl-hvh-02.yaml) line 26
   - [`inventory/host_vars/hom-lab-ctl-hvh-02-ipv6.yaml`](inventory/host_vars/hom-lab-ctl-hvh-02-ipv6.yaml) lines 23, 26
   - [`playbooks/templates/host_vars_windows.yml.j2`](playbooks/templates/host_vars_windows.yml.j2) line 12

---

## Track F — Additional server-225 reference cleanup

- [`roles/ipam_netbox/tasks/ensure_api_token.yml`](roles/ipam_netbox/tasks/ensure_api_token.yml) — tag name `ipam_netbox_seed_server_225_model` → `ipam_netbox_seed_hvh_02_model`
- [`contracts/fuzlang.contract.yaml`](contracts/fuzlang.contract.yaml) — 4 `Server-225` hostname strings
- [`.cursor/rules/framework-netbox-modeling.mdc`](.cursor/rules/framework-netbox-modeling.mdc) — rule line stating VM name stays as `server-225-ubuntu`
- **Delete** `facts/server-225.json` — unreferenced historical snapshot
- [`scripts/lib.sh`](scripts/lib.sh) — remove dead `server-225-wsl` special-case block (lines 430–431+); update help text examples

---

## Track D — NetBox service metadata (custom fields + stack tags)

### New tags in [`roles/ipam_netbox/defaults/main.yml`](roles/ipam_netbox/defaults/main.yml)

```yaml
- name: stack-logging
  slug: stack-logging
  description: Deployed by the logging_loki role (Loki + Grafana)
  color: "20c997"
- name: stack-fuzlang-net
  slug: stack-fuzlang-net
  description: Deployed by stacks_fuzlang_net role (Langfuse, MinIO, Postgres, Redis, ClickHouse)
  color: "fd7e14"
- name: stack-netbox
  slug: stack-netbox
  description: Deployed by ipam_netbox role
  color: "0d6efd"
- name: stack-semaphore
  slug: stack-semaphore
  description: Deployed by ansible_ui_semaphore role
  color: "6610f2"
```

### New `custom_fields:` block on each of the 9 service entries

```yaml
custom_fields:
  compose_project: "fuzlang-net"      # or: netbox, semaphore, logging, k8s-langfuse, k8s-litellm
  deployed_by_role: "stacks_fuzlang_net"   # updated name after Track G
  stack_name: "fuzlang-net"
```

### New task file `roles/ipam_netbox/tasks/seed_custom_fields.yml` (create)

Uses `netbox.netbox.netbox_custom_field` to create 3 custom field definitions on the Service object type:
- `compose_project` (type: text)
- `deployed_by_role` (type: text)
- `stack_name` (type: select, choices: logging, fuzlang-net, netbox, semaphore, langfuse, litellm)

Wire into [`roles/ipam_netbox/tasks/present.yml`](roles/ipam_netbox/tasks/present.yml) before service seeding.
Add tag `ipam_netbox_seed_custom_fields` to [`playbooks/deploy_ipam_netbox.yaml`](playbooks/deploy_ipam_netbox.yaml).

### Comments cleanup

Remove structured YAML blobs from every `comments:` field in [`roles/ipam_netbox/defaults/main.yml`](roles/ipam_netbox/defaults/main.yml). Move container, image, compose_project, deployed_by_role data into `custom_fields:`. Keep only human-readable prose in `comments:`.

---

## Track E — Docker labels in compose templates

### [`roles/stacks_fuzlang_net/templates/docker-compose.yml.j2`](roles/network_server/stacks_network/templates/docker-compose.yml.j2) (path after Track G)

Add to each service (postgres, redis, clickhouse, minio, langfuse):

```yaml
labels:
  com.homelab.stack: "fuzlang-net"
  com.homelab.deployed-by: "stacks_fuzlang_net"
```

### [`roles/ipam_netbox/templates/docker-compose.yml.j2`](roles/ipam_netbox/templates/docker-compose.yml.j2)

Add to each service (netbox, netbox-worker, postgres, redis, redis-cache):

```yaml
labels:
  com.homelab.stack: "netbox"
  com.homelab.deployed-by: "ipam_netbox"
```

### [`roles/ansible_ui_semaphore/templates/docker-compose.yml.j2`](roles/ansible_ui_semaphore/templates/docker-compose.yml.j2)

```yaml
labels:
  com.homelab.stack: "semaphore"
  com.homelab.deployed-by: "ansible_ui_semaphore"
```

### [`roles/logging_loki/tasks/main.yml`](roles/logging_loki/tasks/main.yml) (docker_container module)

Add `labels:` to both `community.docker.docker_container` tasks:

```yaml
labels:
  com.homelab.stack: "logging"
  com.homelab.deployed-by: "logging_loki"
```

---

## Track H — Promote `nb_inventory` to primary (post-plan)

**Status: H1–H4 completed 2026-05-27.** H5 remains a separate follow-up plan.

Implementation note: inventory groups were further refined to Option B lane names
(`hyperv_lane_gpu`, `hyperv_lane_storage`) after this plan was drafted.

### H1 — Verify nb_inventory is healthy — DONE

Six `ansible-managed` hosts with `ansible_host` from `primary_ip4` (tunnel
`http://127.0.0.1:18000`): hom-lab-ctl-dkr-01/02, hom-lab-ctl-hvh-01/02,
hom-lab-ctl-k3s-01/02.

### H2 — Run NetBox seed — DONE

```bash
bin/codex-env ansible-playbook playbooks/deploy_ipam_netbox.yaml \
  -e ipam_netbox_api_url=http://127.0.0.1:18000 \
  --tags ipam_netbox_seed_hom_lab_ctl_hvh_02_model,ipam_netbox_seed_hom_lab_ctl_hvh_01_vm_model,ipam_netbox_seed_windows_share_hosts_model
```

Play recap: `ok=75 changed=1 failed=0`.

### H3 — Flip ansible.cfg — DONE

[`ansible.cfg`](../../../ansible.cfg): `inventory = inventory/netbox.yml, inventory/inventory.yaml`

### H4 — Validate ping — DONE (partial)

- `hom-lab-ctl-dkr-02`, `mac-dev`: `ansible.builtin.ping` SUCCESS
- `hom-lab-ctl-hvh-01/02`: `ansible.windows.win_ping` SUCCESS (builtin ping fails on PowerShell SSH)

### H5 — Retire static inventory — OPEN (separate plan)

Remove `inventory/inventory.yaml` from `ansible.cfg` and migrate `group_vars/` to
NetBox-derived group names when ready.

---

## Known residuals (intentionally not changed)

- `docs/reports/` — historical AI-generated state snapshot
- `legacy_inventory_aliases` / ipam purge tasks — explicit migration-only references to `server-225*`
- `roles/network_server/` umbrella stub — deprecation note; delete when confirmed unused

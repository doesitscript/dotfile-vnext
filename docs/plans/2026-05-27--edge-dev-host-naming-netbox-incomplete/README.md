---
name: Edge Dev Host Naming + NetBox Modeling
lifecycle: incomplete
overview: Migrate mac-dev, dev-3090-win, and dev-workstation-win to compact schema NetBox device names, seed them in ipam_netbox, integrate nb_inventory, and add edge services when hosts are online.
related_plans:
  - docs/plans/2026-05-27--name-alignment-netbox-metadata-incomplete/README.md
  - docs/plans/2026-05-27--netbox-ipam-completion-incomplete/README.md
  - docs/intake/netbox/netbox-value-roadmap.md
open_work:
  - Lock compact names and role codes (Phase 0)
  - dev-3090-win deferred until provisioned
  - dev-workstation-win intermittent connectivity
prerequisite_plans:
  - IPAM prefixes optional but recommended first — see netbox-ipam-completion plan
todos:
  - id: phase-0-naming
    content: "Run critical-naming-analysis; lock names; update resource-roles.yml if new codes accepted"
    status: pending
  - id: phase-1-dev-fleet-model
    content: "Add ipam_netbox_dev_fleet_model + seed_dev_fleet_model.yml + deploy_ipam_netbox tags"
    status: pending
  - id: phase-2-offline-posture
    content: "Seed deferred hosts as planned/offline; staged vs ansible-managed tag policy"
    status: pending
  - id: phase-3-repo-aliases
    content: "hosts_mapping legacy_inventory_aliases; validate_netbox_repo_consistency.sh"
    status: pending
  - id: phase-4-edge-services
    content: "dev-3090 ollama/litellm NetBox services when host online"
    status: pending
  - id: phase-5-nb-inventory
    content: "nb_inventory host count check; ping/win_ping smoke per host"
    status: pending
isProject: false
---

# Edge Dev Host Naming + NetBox Modeling

**Planner/Steward view:** Hyper-V lane hosts already use compact `hom-lab-ctl-*` names in NetBox. This plan is **only** the three edge/dev machines below — not K3s (already seeded), not IPAM prefixes (sibling plan).

---

## Scope

| Inventory key | Proposed NetBox name | Role | Platform (NetBox) | Connection |
|---|---|---|---|---|
| `mac-dev` | `hom-lab-exe-mac-01` | execution-plane Mac controller | `macos-15` (new seed) | Live — Ansible execution node |
| `dev-3090-win` | `hom-lab-aix-gpu-01` | AI/GPU Windows box | `windows-11` or `windows-server-2025` | **Deferred** |
| `dev-workstation-win` | `hom-lab-dev-wks-01` | general dev workstation | `windows-11` | Intermittent |

**Out of scope here:** `hom-lab-ctl-k3s-01/02` (done), IPAM `/24` prefixes, storage-lane `hom-lab-ctl-dkr-01` services, config contexts, H5 static inventory retirement.

---

## Naming / Modeling Diagram

```mermaid
graph LR
  subgraph inventory [Ansible inventory keys]
    mac_dev[mac-dev]
    dev3090[dev-3090-win]
    dev_wks[dev-workstation-win]
  end

  subgraph netbox [NetBox device names]
    nb_mac[hom-lab-exe-mac-01]
    nb_gpu[hom-lab-aix-gpu-01]
    nb_wks[hom-lab-dev-wks-01]
  end

  subgraph mapping [hosts_mapping.yaml]
    aliases[legacy_inventory_aliases]
  end

  mac_dev -.->|alias| nb_mac
  dev3090 -.->|alias| nb_gpu
  dev_wks -.->|alias| nb_wks
  aliases --> mapping
  nb_mac --> site_homelab[site homelab]
  nb_gpu --> site_homelab
  nb_wks --> site_homelab
```

---

## Architecture/Structure Diagram

```mermaid
graph TB
  subgraph repo [dotfile-vnext]
    inv_static["inventory/inventory.yaml<br/>mac-dev, dev-*-win"]
    inv_nb["inventory/netbox.yml"]
    mapping["inventory/hosts_mapping.yaml"]
    hv_mac["inventory/host_vars/mac-dev.yaml"]
    hv_3090["inventory/host_vars/dev-3090-win.yaml"]
    hv_wks["inventory/host_vars/dev-workstation-win.yaml"]
    playbook["playbooks/deploy_ipam_netbox.yaml"]
    subgraph ipam [roles/ipam_netbox]
      defaults["defaults/main.yml<br/>ipam_netbox_dev_fleet_model NEW"]
      seed_dev["tasks/seed_dev_fleet_model.yml NEW"]
      seed_win["seed_windows_share_hosts_model.yml<br/>pattern reference"]
    end
    endpoint["roles/common/endpoint_verify<br/>dev-3090 URLs"]
  end

  subgraph netbox_api [NetBox]
    devices["devices exe-mac / aix-gpu / dev-wks"]
    ips["mgmt0 + primary IP"]
    tags["ansible-managed when ready"]
    svc["services ollama litellm on gpu host"]
  end

  playbook --> seed_dev
  defaults --> seed_dev
  seed_dev --> devices
  seed_dev --> ips
  seed_dev --> tags
  seed_dev --> svc
  inv_nb --> netbox_api
  inv_static -.->|"connection vars until H5"| hv_mac
  mapping --> inv_nb
```

---

## Phase 0 — Naming gate (blocks all seeds)

**Authority:** `docs/reference/naming-standards/` (`render-patterns.yml`, `context.yml`, `resource-roles.yml`). Use `critical-naming-analysis` skill if disputed.

**Policy:** NetBox **name == slug**. Recommended: **keep inventory keys** (`mac-dev`, etc.); NetBox uses compact names; wire `legacy_inventory_aliases` in `hosts_mapping.yaml`.

**Open decisions:**

1. Register role codes `mac`, `gpu`, `wks` and domains `exe`, `dev` in `resource-roles.yml`, or map to `srv` / `vlm`.
2. Whether to ever rename inventory keys to match NetBox (breaking) — default **no**.
3. NetBox `status` for offline hosts: `planned` vs `offline`.

**Apply:** Analysis + schema doc update.

**Verify:** Name table signed off in this README.

**Undo:** Revert schema docs.

**Change class:** idempotent config.

---

## Phase 1 — Dev fleet NetBox seed

**Apply:**

- `ipam_netbox_dev_fleet_model` in `defaults/main.yml` (devices, roles, platforms, interfaces, tags).
- `tasks/seed_dev_fleet_model.yml` — mirror `seed_windows_share_hosts_model.yml` task order.
- Playbook tags: `ipam_netbox_seed_dev_fleet_model_preview`, `ipam_netbox_seed_dev_fleet_model`.

**IPs (from inventory / hosts_mapping):**

| Device | Source |
|---|---|
| `hom-lab-exe-mac-01` | `hostvars['mac-dev'].host_ip` / `192.168.50.33` |
| `hom-lab-aix-gpu-01` | `192.168.50.191` (physical_node dev-3090) |
| `hom-lab-dev-wks-01` | `hostvars['dev-workstation-win'].host_ip` / `192.168.50.70` |

**Verify:**

```bash
bin/codex-env ansible-playbook playbooks/deploy_ipam_netbox.yaml \
  -e ipam_netbox_api_url=http://127.0.0.1:18000 \
  --tags ipam_netbox_seed_dev_fleet_model_preview
```

Then `--tags ipam_netbox_seed_dev_fleet_model`.

**Undo:** Manual NetBox delete or future absent path.

**Change class:** idempotent seed.

**Depends on:** Phase 0 complete; NetBox API reachable (tunnel OK).

---

## Phase 2 — Offline / deferred posture

**Process:**

1. Model in code even when host is down.
2. Seed `dev-3090-win` as **`planned`** until `ansible_surfaces.state` is not `deferred`.
3. **Tag policy (recommended):** seed with `inventory-staged` first; add `ansible-managed` only when SSH/WinRM verified — controls `nb_inventory` inclusion (`query_filters: tag: ansible-managed`).
4. Connection secrets stay in `host_vars/` / vault until H5.
5. When online: `active` + `ansible-managed` + inventory smoke test.

**Verify:** `ansible-inventory -i inventory/netbox.yml --host hom-lab-exe-mac-01` (or alias resolution documented).

**Undo:** Remove tags / set decommissioning.

**Change class:** operational gate on top of idempotent seed.

---

## Phase 3 — Repo aliases + consistency

- `hosts_mapping.yaml`: `legacy_inventory_aliases` for each compact name.
- `scripts/validate_netbox_repo_consistency.sh`: allowlist new strings.
- `roles/ipam_netbox/README.md`: document dev-fleet tags.

**Verify:** consistency script passes after seed.

**Change class:** idempotent config.

---

## Phase 4 — Edge service objects

| Host | Services | Source |
|---|---|---|
| `hom-lab-aix-gpu-01` | Ollama `:11434`, LiteLLM `:4000` | `roles/common/endpoint_verify/tasks/main.yml` |
| `hom-lab-exe-mac-01` | Optional — skip unless needed | Controller, not service host |

Reuse `netbox_service` loop + Service custom fields from GPU lane seed.

**Verify:** NetBox device page lists services.

**Change class:** idempotent seed.

**When:** After Phase 1 and host connectivity confirmed for GPU box.

---

## Phase 5 — nb_inventory validation

- Expect **+1 to +3** hosts in `nb_inventory` when `ansible-managed` applied (mac-dev first; others when staged).
- `ansible.builtin.ping` on mac-dev; `ansible.windows.win_ping` on Windows surfaces.
- Document `--limit` for hosts still `planned`.

**Does not include H5** (retire `inventory/inventory.yaml`) — see name-alignment plan.

---

## Apply / Verify / Undo / Change class

| Phase | Apply | Verify | Undo | Class |
|---|---|---|---|---|
| 0 Naming | Schema + agreement | Name table locked | Revert docs | config |
| 1 Seed | `seed_dev_fleet_model` | NetBox devices + IPs | Delete objects | idempotent seed |
| 2 Offline | Status + tags | nb_inventory scope | Remove tags | operational |
| 3 Repo | mapping + script | consistency pass | Revert aliases | config |
| 4 Services | service loop on gpu | NetBox UI | Delete services | idempotent seed |
| 5 Inventory | tag + ping | host count + reachability | Remove ansible-managed | verification |

---

## Prerequisites

- Phase 0 naming locked.
- `vault_netbox_api_token` in `vault.yml`.
- NetBox API: `http://127.0.0.1:18000` (tunnel) per `docs/one_off_tasks/investigate_networking_issue.md`.

---

## Diagram Inventory

### Diagrams Included

- **Architecture/Structure Diagram**: inventory, ipam_netbox seed path, NetBox objects.
- **Naming/Modeling Diagram**: inventory key → NetBox name alias mapping.

### Additional Diagrams Available On Request

- **State Transition Diagram**: `planned` → `active` + `ansible-managed`.
- **Deployment Flow**: playbook tag order Phases 1 → 4.
- **Integration Sequence**: nb_inventory pickup after tag flip.

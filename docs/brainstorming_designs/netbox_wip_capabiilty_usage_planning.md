# NetBox WIP — capability usage planning

**Live naming map:** [`docs/reference/naming-standards/live-object-registry.yml`](../reference/naming-standards/live-object-registry.yml) and [`README.md`](../reference/naming-standards/README.md) (current vs retired names).

**Status snapshot:** 2026-05-27 (post name-alignment + lane seeds)

**Active finish roadmap (no edge dev hosts):** [`docs/plans/2026-05-27--netbox-wip-finish-roadmap-incomplete/README.md`](../plans/2026-05-27--netbox-wip-finish-roadmap-incomplete/README.md)

**Implementation detail:** [`docs/plans/2026-05-27--netbox-ipam-completion-incomplete/README.md`](../plans/2026-05-27--netbox-ipam-completion-incomplete/README.md)

**Deferred / separate:** Edge dev hosts (`mac-dev`, `dev-3090-win`, `dev-workstation-win`) — [`docs/plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md`](../plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md)

---

## Done since this note was written

| Topic | Status |
|---|---|
| Compact host names in NetBox | **Done** — `HOM-LAB-HVH-01/02`, `hom-lab-ctl-dkr-01/02`, `hom-lab-ctl-k3s-01/02` seeded |
| `ansible-managed` tag | **Done** for seeded Hyper-V lane hosts (6 in `nb_inventory`) |
| Shadow / primary inventory | **Done** — `ansible.cfg` lists `inventory/netbox.yml` first; shadow proven |
| Service objects (GPU lane) | **Done** — 9 services on dkr-02 / k3s-02 via `ipam_netbox_hom_lab_ctl_hvh_02_model` |
| Service objects (storage lane) | **Done** — storage-lane `dkr-01` services seeded in `ipam_netbox_hom_lab_ctl_hvh_01_vm_model` |
| K3s nodes in NetBox | **Done** — both k3s VMs in hvh-01 and hvh-02 VM model seeds |
| Legacy exec-hvh / primary-hvh gap | **Closed** — migrations + purge tasks in `ipam_netbox` |

---

## Still open (tracked in plan)

### Service objects (original lines 4–8)

- **GPU lane:** implemented (see above).
- **Storage lane (`hom-lab-ctl-dkr-01`):** now modeled with curated services plus hybrid runtime discovery preview for parity checks.
- **Edge fleet (`mac-dev`, `dev-3090`, `dev-workstation`):** not modeled — [edge-dev-host naming plan](../plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md).

### Subnet prefixes (original line 34)

**Meaning:** NetBox needs **Prefix** objects (e.g. `192.168.137.0/24`) as parents in IPAM, not only host IPs on interfaces. Without prefixes: no subnet utilization, weaker IP validation, no prefix-based reporting.

| Prefix | Use |
|---|---|
| `192.168.50.0/24` | LAN management |
| `192.168.138.0/24` | hvh-01 guest network |
| `192.168.137.0/24` | hvh-02 guest network |

**Status:** **Done** (2026-05-27) — three `/24` prefixes seeded via `ipam_netbox_seed_prefixes`.

### Edge hosts not in NetBox (original line 36)

| Host | In NetBox? | Online? | Process |
|---|---|---|---|
| `mac-dev` | No | Yes (controller) | [Edge-dev plan](../plans/2026-05-27--edge-dev-host-naming-netbox-incomplete/README.md) Phases 0–1 |
| `dev-3090-win` | No | Deferred | Edge-dev plan: `planned` seed; `ansible-managed` when provisioned |
| `dev-workstation-win` | No | Intermittent | Edge-dev plan: confirm IP/name when online |
| `hom-lab-ctl-k3s-*` | **Yes** | When VMs up | Already seeded — not part of this gap |

---

## Original sections — current read

### Tagging / controlled vocabulary (lines 11–13)

**Usable now.** Tags are seeded in `ipam_netbox`; stack tags (`stack-netbox`, `stack-fuzlang-net`, …) wired. Continue using tags before custom fields.

### Config contexts (lines 15–18)

**Done (2026-05-27).** Contexts `homelab-naming-context` and `homelab-hyperv-guest-routing` seeded via `ipam_netbox_seed_config_contexts`.

### Dynamic inventory / nb_inventory (lines 20–24)

**Working** for tagged objects. Any host with `ansible-managed` appears automatically. Do not tag deferred hosts until you want them in default inventory scope.

### Shadow inventory (line 26)

**Proven** — use tunnel URL for API when LAN portproxy is broken (`docs/one_off_tasks/investigate_networking_issue.md`).

### Partially done / diverged (lines 28–30)

**Stale — ignore.** Replaced by name-alignment execution; see “Done” table above.

---

## Other worthwhile follow-ups (not in original WIP list)

| Item | Why | Where |
|---|---|---|
| H5 retire static inventory | Drop duplicate `host_vars` IPs when NetBox owns them | name-alignment plan open_work |
| LAN NetBox API (portproxy) | Mac can use `192.168.50.158:8000` without SSH tunnel | networking one-off |
| `netbox-value-roadmap.md` refresh | Still references `server-225-ubuntu`, old Step 2 host table | docs/intake/netbox/ |
| Service inventory discovery workflow | Keep repo seed authoritative while comparing against live Docker/K3s runtime and live NetBox | `docs/diagnostics/netbox-service-inventory-hybrid-preview.md` |
| Token source for `nb_inventory` | Roadmap Step 3 — vault-backed token vs `NETBOX_TOKEN` env | inventory/netbox.yml |

---

## Questions (resolved / pointer)

| Question | Answer |
|---|---|
| What are subnet prefixes? | Parent `/24` objects in IPAM; see “Still open” above |
| How to add offline hosts? | Code-first seed → `planned` status → `ansible-managed` when connectable; plan Phase 3 |

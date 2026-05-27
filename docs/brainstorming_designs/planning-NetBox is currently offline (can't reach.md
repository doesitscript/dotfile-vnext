NetBox is currently offline (can't reach `192.168.50.158:8000`), so I'll work from the committed state rather than live data.

---

## What NetBox can do — capability map

**IPAM (IP Address Management)**
- Own all IP addresses, prefixes/subnets, VLANs, and VRFs
- Track used vs available addresses per subnet
- Assign IPs to interfaces (VM or physical device)
- First-class primary IP → `ansible_host` via `nb_inventory`

**DCIM (Data Center Infrastructure Management)**
- Model physical devices: manufacturer, device type, device role, platform (OS)
- Rack and location hierarchy
- Physical interface definition (NICs, ports)
- Power and cabling (optional, not relevant to homelab yet)

**Virtualization**
- Cluster types, clusters, virtual machines, VM interfaces
- VM role, platform, IP — the full logical model of a guest

**Service objects**
- Name, protocol, port assigned to a device or VM
- Lightweight service registry — what's listening where without SSHing

**Tagging / controlled vocabulary**
- Tags as first-class grouping primitive
- `nb_inventory` groups by tag automatically → replaces hand-maintained group_vars

**Config contexts**
- JSON/YAML data blocks applied to devices/VMs by region, site, role, platform, or tag
- Can replace host_vars for non-connection data (feature flags, tuning values)

**Dynamic inventory for Ansible (`nb_inventory`)**
- Groups by site, tag, role, platform, cluster, cluster_type, is_virtual
- Derives `ansible_host` from primary IP
- Any host added to NetBox with `ansible-managed` tag appears automatically in Ansible

**API + webhooks**
- Full REST API — any seed task becomes a live query
- Webhooks can trigger external automation on object create/change/delete

**Change log**
- Built-in audit trail for every object change — who changed what and when

---

## Where the project stands

### Done ✓
- NetBox running on `hom-lab-ctl-dkr-01` (server-225-ubuntu)
- `nb_inventory` wired into `ansible.cfg` as a combined source alongside static inventory
- `ansible_host` compose fixed — produces clean IP strings
- `NETBOX_TOKEN` in `.envrc` — no manual export needed
- Shadow inventory proven working (as of ~May 19)
- Seeded: site `homelab`, tags, device roles, platforms, manufacturers, device types
- `exec-hvh-01` and `primary-hvh-01` seeded and verified in NetBox

### Partially done / diverged
- **Host naming has moved on.** Static `host_vars/` now has `hom-lab-ctl-hvh-01`, `hom-lab-ctl-hvh-02`, `hom-lab-ctl-dkr-01`, `hom-lab-ctl-k3s-01`, `hom-lab-ctl-k3s-02` — these are new compact names that are almost certainly NOT yet seeded in NetBox. NetBox likely still has `exec-hvh-01` / `primary-hvh-01` from before the rename. This is the primary gap right now.
- **`ansible-managed` tag coverage is incomplete.** Only the original seeded hosts have the tag. The new host names won't appear in `nb_inventory` until they're seeded.

### Not started yet
- **IPs still live in static `host_vars`** — `192.168.50.234`, `192.168.50.158`, `192.168.138.10`, `192.168.137.10`, etc. are all in YAML files. NetBox isn't yet the authority for these.
- **Subnet prefixes not in NetBox** — `192.168.50.0/24`, `192.168.138.0/24`, `192.168.137.0/24` not seeded as IPAM prefixes
- **k3s nodes, mac-dev, dev-workstation, dev-3090** — not in NetBox at all
- **Service objects** — nothing seeded (NetBox UI, Semaphore, etc.)
- **Config contexts** — not used yet

### The most important next step

Re-seed or update NetBox to match the current host naming. The static inventory has moved to compact names (`hom-lab-ctl-*`) but NetBox still has the old names. Until those align, `nb_inventory` produces a different host set than the static inventory and they can't be merged cleanly. That's the blocker for Tier 2.

Do you want to start with that alignment — figure out what's in NetBox right now vs what the static inventory shows — and then seed the gaps?

# Terraform + Cloud Posse + Zerto Layout Plan

> Plan-like brainstorm — not an approved `docs/plans/` packet or repo authority.
> Shaped from exported conversation; candidate architecture only.
> Parent packet: [README.md](./README.md)
>
> **Scaled-out companion:** multi-surface management plane, AWS accounts, and
> Azure workload protection —
> [`terraform-multi-surface-data-protection-scaled-out-plan.md`](./terraform-multi-surface-data-protection-scaled-out-plan.md)
>
> **Zerto vocabulary companion:** ZVM, VRA, VPG, journals, and repo naming map —
> [`zerto-infrastructure-world-mapping-plan.md`](./zerto-infrastructure-world-mapping-plan.md)

---

## User

If I added Terraform into my project or just into my home lab but held to my naming, I'm pretty sure I could adopt Cloud Posse / Geodesic organization and still adhere to my schema. How would a directory tree look with names if I were to add Zerto (backup solution)? Give me a schema for the layout of all the Terraform (whether modules and folders are involved, please show me).

---

## Assistant

**Planner/Steward view:** You can adopt Cloud Posse / Geodesic / Terragrunt (or Atmos) organization without abandoning your schema. The trick is a clean split: **directory hierarchy carries placement** (lane, capability, unit), while **Cloud Posse `label` / `context` carries rendered IDs and tags** mapped to `hom-lab-ctl-<role>-<idx>`.

Your repo already captured the mapping research in `docs/reference/naming-standards/archive/cloud-posse-context-integrated.md` and `terragrunt-structure-not-yet-integrated.md`. Active schema baseline remains:

```text
<tenant>-<environment>-<domain>-<role>-<idx>
→ HOM-LAB-HVH-01
```

**Diagrams (schema notation):** [diagrams/](./diagrams/) — start with
[`cst-hom-lab-ctl-dia-data-protection-naming-01.md`](./diagrams/cst-hom-lab-ctl-dia-data-protection-naming-01.md)
and [`cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md`](./diagrams/cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md).

---

### Core pattern: three layers

| Layer | Cloud Posse / Geodesic name | Your homelab meaning | Naming rule |
|-------|----------------------------|----------------------|-------------|
| **Modules** | `terraform/modules/` | Reusable capability patterns | **snake_case** dirs (Terraform convention) |
| **Components** | Atmos component OR Terragrunt unit | One deployable stack instance | **kebab-case** dirs; path = placement |
| **Stacks / Live** | `stacks/` or `infrastructure-live/` | Where instances land | Mirrors **lane + domain**, not long encoded strings |

**Principle from your cross-ecosystem notes:** put hierarchy in folders and tags, not in one giant string like `hom-lab-ctl-lane-storage-zerto-zvm-01`.

---

### Cloud Posse label ↔ your schema

Map once in root `context.tf` / `globals.hcl`:

| Cloud Posse label | Your `context.yml` field | Value |
|-------------------|--------------------------|-------|
| `namespace` | namespace | `cst` (metadata / canonical IDs only) |
| `tenant` | tenant | `hom` |
| `environment` | environment / site | `lab` |
| `stage` | domain | `ctl` |
| `name` | role code | `zrt`, `bkp`, `hvh`, `dkr`, … |
| `attributes` | idx + modifiers | `["01"]`, `["vra"]`, `["gpu-lane"]` |

Example rendered IDs (L4 baseline + L6 canonical):

```text
hom-lab-ctl-zrt-01                              # L4 ZVM logical hostname (candidate)
hom-lab-ctl-bkp-01                              # L4 generic backup-server (candidate bkp)
cst-hom-lab-ctl-service-zerto-01                # L6 documentation / catalog ID
cst-hom-lab-ctl-dia-zerto-homelab-topology-01   # L6 diagram ID (this packet)
```

For Zerto specifically, add **`zrt`** as a **candidate service role** (like `nbx`, `lfs`) and keep **`bkp`** for generic backup infrastructure. Zerto VRAs attach to existing **`hvh`** hosts — they are components on `HOM-LAB-HVH-01/02`, not new hostnames.

---

### Recommended monorepo layout (inside or beside `dotfile-vnext`)

Two valid placements:

1. **Sibling repo** `hom-lab-infrastructure` (Cloud Posse classic: modules + live separate)
2. **In-repo** `terraform/` subtree (keeps Ansible + TF co-located)

Below assumes **in-repo** `terraform/`; swap root if you prefer a dedicated infra repo.

```text
dotfile-vnext/
├── ansible/                          # optional rename/shim — today: inventory/, roles/, playbooks/
├── terraform/
│   ├── README.md
│   ├── versions.tf                   # provider pins, backend contract
│   │
│   ├── context/                      # SSOT label defaults (Cloud Posse null-label)
│   │   ├── defaults.tf               # tenant=hom, environment=lab, stage=ctl
│   │   ├── label_order.tf            # label_order for homelab
│   │   └── tags.tf                   # ansible-managed, homelab, netbox sync tags
│   │
│   ├── modules/                      # REUSABLE — no environment values baked in
│   │   ├── label/                    # thin wrapper around cloudposse/label/null
│   │   ├── hyperv/
│   │   │   ├── vm/                   # generic Hyper-V guest pattern
│   │   │   └── vswitch/              # optional
│   │   ├── networking/
│   │   │   └── static-route/         # guest subnet routing intent
│   │   ├── data-protection/
│   │   │   ├── zerto/
│   │   │   │   ├── zvm/              # Zerto Virtual Manager appliance
│   │   │   │   ├── site/             # Zerto site pairing / pairing policy
│   │   │   │   ├── vra/              # VRA on a Hyper-V host
│   │   │   │   ├── protection-group/ # VM protection membership
│   │   │   │   └── journal/          # journal datastore / retention policy
│   │   │   └── veeam/                # future; same category
│   │   └── observability/            # if TF ever owns cloud-side bits
│   │
│   ├── components/                   # COMPOSABLE units (Atmos) OR module+wrapper roots
│   │   └── terraform/
│   │       ├── hyperv-vm/
│   │       ├── zerto-zvm/
│   │       ├── zerto-vra/
│   │       ├── zerto-site/
│   │       └── zerto-protection-group/
│   │
│   └── stacks/                       # LIVE INSTANCES — Terragrunt/Atmos deploy surface
│       ├── _global/                  # non-lane-specific (pairing, DNS intent, IAM if cloud)
│       │   ├── zerto-site-pairing/
│       │   │   └── terragrunt.hcl
│       │   └── backup-catalog-path/  # aligns with netbox.yml backup_path_segment policy
│       │
│       └── hom/
│           └── lab/
│               └── ctl/              # domain = control plane
│                   ├── account.hcl   # shared inputs: tenant, environment, domain, tags
│                   ├── region.hcl    # homelab: "region" = lane
│                   │
│                   ├── lane-storage/     # hyperv_lane_storage
│                   │   ├── lane.hcl      # guest_subnet: 192.168.138.0/24, hvh-01 anchor
│                   │   ├── hyperv/
│                   │   │   └── host-hvh-01/    # metadata only; host exists via Ansible
│                   │   ├── data-protection/
│                   │   │   ├── zerto/
│                   │   │   │   ├── vra-hvh-01/
│                   │   │   │   │   └── terragrunt.hcl
│                   │   │   │   ├── protection-group-k3s-01/
│                   │   │   │   │   └── terragrunt.hcl
│                   │   │   │   ├── protection-group-dkr-01/
│                   │   │   │   │   └── terragrunt.hcl
│                   │   │   │   └── journal-store-01/
│                   │   │   │       └── terragrunt.hcl
│                   │   │   └── (future veeam-...)
│                   │   └── services/       # only if TF owns something Ansible doesn't
│                   │
│                   ├── lane-gpu/         # hyperv_lane_gpu
│                   │   ├── lane.hcl      # guest_subnet: 192.168.137.0/24, hvh-02 anchor
│                   │   ├── data-protection/
│                   │   │   └── zerto/
│                   │   │       ├── vra-hvh-02/
│                   │   │       │   └── terragrunt.hcl
│                   │   │       ├── protection-group-k3s-02/
│                   │   │       │   └── terragrunt.hcl
│                   │   │       └── protection-group-dkr-02/
│                   │   │           └── terragrunt.hcl
│                   │   └── hyperv/
│                   │       └── host-hvh-02/
│                   │
│                   └── shared/           # cross-lane resources
│                       └── data-protection/
│                           └── zerto/
│                               └── zvm-01/           # hom-lab-ctl-zrt-01 candidate VM
│                                   └── terragrunt.hcl
│
├── geodesic/                         # optional Cloud Posse shell (Docker-based toolbox)
│   ├── Dockerfile
│   ├── Makefile
│   └── rootfs/
│       └── etc/geodesic/
│           └── geodesic.env          # ATMOS_STACK, TF_VAR_* , AWS_PROFILE if needed
│
└── (existing) inventory/, roles/, playbooks/   # Ansible remains steady-state CM
```

---

### Zerto decomposition (what each folder owns)

See diagram
[`cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md`](./diagrams/cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md)
for the full topology (live `hom-lab-ctl-*` hosts vs candidate Zerto units).

| Unit directory | Module | Protects / attaches to | Rendered name (L4) |
|----------------|--------|------------------------|---------------|
| `shared/.../zvm-01` | `zvm` | new management VM | `hom-lab-ctl-zrt-01` |
| `lane-storage/.../vra-hvh-01` | `vra` | `HOM-LAB-HVH-01` | attributes `vra-hvh-01` on host id |
| `lane-gpu/.../vra-hvh-02` | `vra` | `HOM-LAB-HVH-02` | attributes `vra-hvh-02` |
| `.../protection-group-k3s-01` | `protection-group` | `hom-lab-ctl-k3s-01` | group name from PG module + tags |
| `.../protection-group-k3s-02` | `protection-group` | `hom-lab-ctl-k3s-02` | same pattern |
| `.../journal-store-01` | `journal` | journal LUN/path on storage lane | `hom-lab-ctl-bkp-journal-01` or attribute on `bkp` |

**Boundary with Ansible:** Hyper-V hosts and guest VMs (`hvh`, `dkr`, `k3s`) stay Ansible-owned today. Terraform/Zerto modules should **reference** existing `inventory_hostname` values as inputs, not invent parallel names.

---

### Example Terragrunt unit (ZVM)

```hcl
# terraform/stacks/hom/lab/ctl/shared/data-protection/zerto/zvm-01/terragrunt.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "lane" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/modules/data-protection/zerto/zvm"
}

dependency "hyperv_storage_lane" {
  config_path = "../../../../lane-storage/hyperv/host-hvh-01"
  mock_outputs = { host_fqdn = "HOM-LAB-HVH-01" }
}

inputs = {
  # Cloud Posse context — maps to your schema
  namespace   = "cst"
  tenant      = "hom"
  environment = "lab"
  stage       = "ctl"
  name        = "zrt"
  attributes  = ["01"]

  # Homelab anchors (from live-object-registry / inventory)
  hyperv_host            = "HOM-LAB-HVH-01"
  management_subnet_cidr = "192.168.138.0/24"
  guest_ip               = "192.168.138.20"   # example; pick unused IP

  netbox_sync = {
    inventory_hostname = "hom-lab-ctl-zrt-01"
    lane_group         = "hyperv_lane_storage"
    role_code          = "zrt"
  }

  tags = {
    ansible-managed = "false"   # until an Ansible role owns day-2
    homelab         = "true"
    capability      = "zerto"
  }
}
```

Example **protection group** unit naming the protected VM explicitly:

```hcl
inputs = {
  name       = "zrt"
  attributes = ["pg", "k3s", "01"]
  protected_vm_inventory_hostname = "hom-lab-ctl-k3s-02"
  zvm_endpoint = dependency.zvm.outputs.api_url
}
```

---

### Geodesic + Atmos (optional Cloud Posse orchestration)

If you want full Geodesic/Atmos instead of raw Terragrunt:

```text
terraform/
├── atmos.yaml                    # stack/catalog config
├── stacks/
│   └── hom-lab-ctl.yaml          # stack selects components + vars
├── components/
│   └── terraform/
│       ├── zerto-zvm/
│       │   └── component.yaml
│       └── zerto-vra/
│           └── component.yaml
└── modules/                      # same as above
```

Stack name **`hom-lab-ctl`** mirrors your baseline context (`hom` + `lab` + `ctl`), not a new vocabulary.

---

### Schema additions before you commit

Your active registry has `bkp` (backup-server) as **candidate** but no `zrt` yet. Before treating Zerto as integrated:

1. Add to `resource-roles.yml`:
   - `zrt: { full: zerto-manager, status: candidate }` under `services` or `operations`
2. Add `terraform.yml` under `docs/reference/naming-standards/` (same pattern as `ansible.yml`) — module dir rules, stack path rules, label mapping
3. Add live rows to `live-object-registry.yml` when ZVM/VRAs are real
4. Run capability introduction checklist for a new automation surface

---

### Ansible vs Terraform split (recommended)

| Concern | Owner | Why |
|---------|-------|-----|
| Hyper-V VM create, OS, OpenSSH, GPU drivers | Ansible (existing) | Already steady-state |
| NetBox seed / naming SSOT | Ansible `ipam_netbox` | Repo authority today |
| Zerto sites, VRAs, protection groups, RPO/RTO | Terraform modules + stacks | Vendor API / declarative DR intent |
| Day-2 Zerto ops (failover test, license) | Ansible role later OR TF only | Pick one SSOT per knob |

---

### Apply / Verify / Undo / Change class

| | |
|--|--|
| **Apply** | `terragrunt run --all apply` from `stacks/hom/lab/ctl/...` or Atmos `atmos terraform apply zerto-zvm -s hom-lab-ctl` |
| **Verify** | Zerto UI + protected VM replication state; NetBox row for `hom-lab-ctl-zrt-01`; inventory cross-check |
| **Undo** | `terragrunt destroy` per unit; protection groups before VRAs before ZVM |
| **Class** | Idempotent config for Zerto objects; ZVM deploy may be bootstrap/semi-manual first slice |

---

**Outcomes:** Cloud Posse organization fits your schema if **`tenant/environment/stage/name`** map to **`hom/lab/ctl/<role>`**, lanes replace cloud **regions**, and Zerto splits into **`modules/` (patterns) + `stacks/` (instances)** with VRAs bound to existing **`hom-lab-ctl-hvh-0x`** hosts and a shared **`hom-lab-ctl-zrt-01`** management identity.

Follow-up offered in the original thread: draft the `terraform.yml` naming registry slice and a minimal `zrt` candidate entry for `resource-roles.yml` aligned to the capability introduction checklist.

---

### Sources checked

- `docs/reference/naming-standards/README.md`: baseline pattern and naming layers
- `docs/reference/naming-standards/context.yml`: tenant/environment/domain codes
- `docs/reference/naming-standards/resource-roles.yml`: `bkp` candidate, service vs host boundaries
- `docs/reference/naming-standards/render-patterns.yml`: baseline and canonical ID patterns
- `docs/reference/naming-standards/live-object-registry.yml`: lane groups and live hostnames
- `docs/reference/naming-standards/archive/cloud-posse-context-integrated.md`: label/context mapping
- `docs/reference/naming-standards/archive/terragrunt-structure-not-yet-integrated.md`: live vs modules layout
- `docs/reference/naming-standards/archive/cross-ecosystem-patterns-not-yet-integrated.md`: hierarchy-in-structure principle

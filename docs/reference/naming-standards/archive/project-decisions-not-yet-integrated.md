# Project-Specific Naming Decisions

## Purpose

This document captures naming decisions made for this dotfile-vnext project, including rationale, deviations from standards, and migration paths for existing resources.

## Project Context

- **Type:** Homelab infrastructure automation
- **Primary tools:** Ansible, NetBox, Docker, Hyper-V, K3s (future)
- **Scale target:** 10-50 VMs/containers, 5-10 physical/virtual hosts
- **Philosophy:** Optimize for "100 nodes" not "works today"

## Core Decisions

### 1. NetBox Is Source of Truth

**Decision:** NetBox owns host, VM, platform, site, role, IP, and cluster facts.

**Rationale:**
- Durable IPAM/DCIM model that scales
- Dynamic inventory eliminates static inventory maintenance
- Native fields for most infrastructure concepts
- Well-documented API and Ansible collection

**Impact:**
- VM names come from NetBox, not static inventory
- Platform information lives in NetBox `platform` field, not in names
- IP addresses assigned via NetBox, not hardcoded

**Project-safe update flow:**
1. Update repo seed/config first: inventory, role defaults, seed tasks, docs,
   aliases, and naming metadata.
2. Run the repo consistency gate:
   `ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml --tags ipam_netbox_repo_consistency`
3. Apply the NetBox seed/update only after the gate passes.

Live NetBox changes that are not reproducible from the repo are treated as
drift, not as completed source-of-truth work.

**Migration:**
- Existing static inventory becomes seed data for NetBox
- `inventory/netbox.yml` in shadow mode until validated
- Gradual cutover as NetBox model matures

### 2. Name Equals Slug for Repo-Controlled Objects

**Decision:** For NetBox objects this repo controls, display name equals slug (lowercase-kebab).

**Rationale:**
- Reduces cognitive overhead when reading YAML, API responses, inventory
- Makes it obvious which string is "real"
- Aligns with automation-first environment
- Simplifies troubleshooting

**Exception:** Proper product names preserve vendor casing (`Windows Server 2025`, `Ubuntu 24.04`).

**Examples:**
- ✅ Display name: `hyperv-host`, Slug: `hyperv-host`
- ✅ Display name: `docker-engine`, Slug: `docker-engine`
- ✅ Display name: `Windows Server 2025`, Slug: `windows-server-2025` (proper name exception)
- ❌ Display name: `Hyper-V Host`, Slug: `hyperv-host` (creates confusion)

### 3. Cloud Posse / NetBox Context Names With Details In Fields

**Decision:** Infrastructure object names follow a Cloud Posse-inspired context
pattern adapted for NetBox:

```text
<namespace?>-<tenant>-<environment>-<stage>-<role_code>-<nn>
```

The current baseline example is:

```text
home-lab-auth-hvh-01
```

**Rationale:**
- Cloud Posse-style context gives a standard pattern instead of one-off names.
- NetBox owns the rich source-of-truth fields behind the rendered name.
- Platform, IP, site, cluster, role, tags, and legacy aliases remain structured and queryable.
- Historical names do not drive the mature schema unless explicitly promoted into a controlled registry.
- Name recommendations must show the data fields that produced the name.

**Current state:**
- Existing inventory aliases such as `hom-lab-ctl-hvh-02` and the retired
  network-server Windows control alias remain legacy/control aliases.
- Existing compact VM names such as `nsrv-dkr-01` and `nsrv-k3s-01` can remain
  when they are already approved durable inventory names for a specific VM lane.
- New NetBox-facing names should meet or exceed the baseline context pattern.

**What belongs where:**

| Concept | In Name? | In NetBox Field / Context | Example |
|---|---|---|---|
| Namespace | Optional | Config context or project context | `castle` |
| Tenant | Yes when stable | NetBox tenant, tag, or config context | `home` |
| Environment/site | Yes when name must stand alone | NetBox site | `lab` |
| Stage | Yes when stable and useful | Tag, config context, or custom field | `auth` |
| Role code | Yes | Device role / VM role | `hvh` -> `hyperv-host` |
| Sequence | Yes | Part of name | `01`, `02` |
| Platform | No | Platform | `Ubuntu 24.04` |
| IP address | No | Interface + primary IP | `192.168.137.10` |
| Host placement | No | Cluster / device relationship | `server-225-hyperv` |
| Historical hostnames | No | Legacy alias, comments, config context | `hom-lab-ctl-hvh-02` |

**Required candidate data shape:**

```yaml
candidate:
  name: home-lab-auth-hvh-01
  schema: "<tenant>-<environment>-<stage>-<role_code>-<nn>"
  context:
    namespace:
      value: castle
      include_in_name: false
    tenant:
      value: home
    environment_or_site:
      value: lab
    stage:
      value: auth
    role_code:
      value: hvh
    sequence:
      value: "01"
  role:
    slug: hyperv-host
    name: hyperv-host
  platform:
    name: Windows Server 2025
    slug: windows-server-2025
```

**Role code examples:**

| Role code | NetBox role slug | Example name |
|---|---|---|
| `hvh` | `hyperv-host` | `home-lab-auth-hvh-01` |
| `dkr` | `docker-engine` | `nsrv-dkr-01` |
| `k3s` | `k3s-node` | `nsrv-k3s-01` |
| `nas` | `file-share` | `home-lab-data-nas-01` |

The role-code registry is intentionally small. Add codes only when the NetBox
role exists or is part of an accepted model.

### 4. Ansible Role Names Are Capability-Focused

**Decision:** Name roles for the capability they manage, not the OS they currently target.

**Pattern:** `<capability>` or `<component>_<subcomponent>`

**Examples:**
- ✅ `speech_central` (capability: speech synthesis)
- ✅ `docker` (capability: Docker engine)
- ✅ `ipam_netbox` (capability: NetBox IPAM)
- ❌ `speech_central_mac` (OS-specific suffix)

**Rationale:**
- Roles should scale to multiple OSes
- OS dispatch happens inside role via `tasks/main.yml` → `mac.yml`, `ubuntu.yml`, `windows.yml`
- Name describes what it does, not where it runs
- Future OS support doesn't require new role names

**Migration:**
- Existing OS-suffixed roles gradually refactored
- New roles follow capability-focused pattern
- Document in role README when role has OS limitations

### 5. Ansible Tags Use Underscores, NetBox Tags Use Hyphens

**Decision:** Explicitly separate Ansible tag namespace from NetBox tag namespace via delimiter.

**Pattern:**
- Ansible play tags: `ipam_netbox_present` (underscores)
- NetBox object tags: `ansible-managed` (hyphens)

**Rationale:**
- Ansible tags are Python identifiers (must use underscores)
- NetBox tags are URL slugs (convention is hyphens)
- Visual distinction prevents confusion between systems
- Never reuse same string as both Ansible tag and NetBox slug

**Examples:**
- Ansible: `--tags ipam_netbox_seed_tags`
- NetBox slug: `ansible-managed`

### 6. Vault Variables Use `vault_` Prefix

**Decision:** All vault variables prefixed with `vault_`, role-owned variables follow `vault_<role>_<field>`.

**Pattern:**
- `vault_ipam_netbox_db_password`
- `vault_ansible_ui_semaphore_admin_password`
- `vault_server_225_win_password`

**Rationale:**
- Immediately distinguishable from plain variables
- Role prefix ties secret to owner
- Prevents accidental secret exposure
- Standard pattern across security-conscious Ansible projects

**Placement:**
- Host credentials → `inventory/group_vars/<group>/vault.yml` or `inventory/host_vars/<host>/vault.yml`
- App secrets → project-root `vault.yml` with role sections

### 7. Package Version Pinning Via Version Contracts

**Decision:** Capability-managed packages must never use `state: latest`. Version contracts track desired versions.

**Pattern:**
```yaml
# In inventory/group_vars/all.yaml
langfuse_tooling_version_contract:
  cli: "0.0.10"

# In role defaults/main.yml
langfuse_cli_version: "{{ langfuse_tooling_version_contract.cli | default('') }}"
langfuse_cli_package_name: "langfuse-cli@{{ langfuse_cli_version }}"
```

**Rationale:**
- Upgrades are deliberate code changes, not runtime side effects
- Same playbook run produces identical results regardless of timing
- Version pins are version-controlled and reviewable
- Exception: `package_manager` role's `upgrade_all` is intentional system maintenance

**Migration:**
- New packages start with version contracts
- Existing unpinned packages migrate at next version change

## Existing Resource Naming Review

### Current VM: `server-225-ubuntu`

**Assessment:** Legacy verbose name.

**Future:** Rename at rebuild using the current context pattern, for example
`home-lab-app-dkr-01` if the accepted context is tenant `home`, environment/site
`lab`, stage `app`, role code `dkr`, sequence `01`.

**Reason:** Current name is stable and working. Rename at rebuild, not as in-place change.

### Current Hosts: `hom-lab-ctl-hvh-02`, `hom-lab-ctl-hvh-02-powershell`

**Assessment:** Windows host is `hom-lab-ctl-hvh-02`. `hom-lab-ctl-hvh-02-powershell` is SSH alias for OpenSSH access to PowerShell on Windows host.

**Future:** Keep as control aliases. Do not promote `server-225`/`s225` into the
mature name schema unless a future decision explicitly makes it a controlled
scope code.

**Reason:** Host names are deeply embedded in inventory, SSH config, WinRM config.
They are operational aliases, not source-of-truth naming standards.

### Current Roles: `ipam_netbox`, `hyperv_ubuntu_vm`, `speech_central`

**Assessment:** Already capability-focused. Good.

**Future:** Continue this pattern.

### Current Service Endpoints

**Current:** Port-proxies are declared in Ansible inventory and the application
services are seeded into NetBox as application service records.

**Decision:** Model LAN-published applications as NetBox application services
on the VM or device that actually runs the service. For the current
server-225 stack, `netbox-web`, `semaphore-web`, and `loki-http` are services
on `server-225-ubuntu`. `grafana-web` is also modeled there because it is
Docker-published on the same VM, though it is not currently LAN-forwarded
through the Windows portproxy.

**Reason:** NetBox service records represent the running application endpoint.
The Windows host remains modeled as the publishing/transport device through
tags and service comments because NetBox does not natively model
application-level port forwarding/PAT as a first-class relationship.

## Open Questions

### Historical Scope Codes

**Question:** Should historical codes such as `s225` or `nsrv` represent durable
scope identity?

**Current decision:** No, not by default. They remain aliases until explicitly
promoted into a controlled scope-code registry.

**Decision point:** Only revisit if physical-node lineage becomes a first-class
context dimension that NetBox cannot represent more cleanly with native fields,
tags, or config context.

### Legacy Name Retirement

**Question:** When should `server-225-ubuntu` be renamed to a context-standard
name such as `home-lab-app-dkr-01`?

**Current thinking:** At VM rebuild or major refactor.

**Decision point:** When Docker node is rebuilt or VM template changes.

### Service Endpoint Modeling

**Question:** How should LAN-published services (NetBox, Semaphore, port-proxies) be modeled?

**Decision:** Use NetBox application service records on the service parent.

**Current implementation:**
- Service parent: `server-225-ubuntu`
- Published by: `home-lab-auth-hvh-02` / legacy alias `hom-lab-ctl-hvh-02`
- Services: `netbox-web`, `semaphore-web`, `loki-http`, `grafana-web`
- Access URLs are stored in service comments until a stronger URL/service
  catalog pattern is adopted.

**Remaining gap:** Automate service seed generation from role defaults and
`guest_published_tcp_ports` so adding a published service in Ansible creates or
updates the matching NetBox service automatically.

### Cluster Naming

**Question:** Should Hyper-V clusters follow the context pattern, such as
`home-lab-auth-hvh-cls-01`, or stay closer to NetBox-native role/set naming?

**Current thinking:** Follow the Cloud Posse / NetBox context standard when
renaming or creating new cluster objects. Keep historical cluster names as
aliases or migration notes unless actively migrating the NetBox object.

**Decision point:** When the cluster model is updated or a second cluster is added.

## Migration Strategy

### Principle: Rename at Natural Boundaries

- Don't force immediate renames
- Rename at rebuild, refactor, or replacement points
- New resources follow new patterns immediately
- Document migration intention in this file

### Gradual NetBox Adoption

**Phase 1 (Current):** Seed NetBox with `server-225` model, shadow inventory mode

**Phase 2:** Validate `nb_inventory` groups and vars match static inventory

**Phase 3:** Cut over playbooks to NetBox inventory for `server-225` subset

**Phase 4:** Expand to additional hosts and VMs

**Phase 5:** Retire static `inventory/inventory.yaml` when all hosts in NetBox

### Legacy Role Refactors

**When refactoring OS-specific roles:**
1. Create new capability-focused role
2. Move OS-specific logic to `tasks/<os>.yml`
3. Update playbooks to use new role
4. Mark old role as deprecated in README
5. Remove old role after cutover complete

**Do not:** Rename roles in-place (breaks dependencies)

## Naming Quick Reference for This Project

### VMs

**Pattern:** `<namespace?>-<tenant>-<environment>-<stage>-<role_code>-<nn>`

**Examples:** `home-lab-app-dkr-01`, `home-lab-cls-k3s-01`

### NetBox Devices

**Pattern:** `<namespace?>-<tenant>-<environment>-<stage>-<role_code>-<nn>`

**Examples:** `home-lab-auth-hvh-01`

### Ansible Roles

**Pattern:** `<capability>` or `<component>_<subcomponent>`

**Examples:** `docker`, `ipam_netbox`, `hyperv_networking`

### Ansible Variables

**Pattern:** `<role_name>_<variable>`

**Examples:** `ipam_netbox_state`, `docker_version`

### Ansible Tags

**Pattern:** `<role_name>` or `<role_name>_<operation>`

**Examples:** `ipam_netbox`, `ipam_netbox_present`

### NetBox Tags

**Pattern:** `<dimension>` (lowercase-hyphen)

**Examples:** `ansible-managed`, `homelab`, `hyperv`, `docker`

### Vault Variables

**Pattern:** `vault_<role_name>_<field>`

**Examples:** `vault_ipam_netbox_api_token`, `vault_server_225_win_password`

### Playbooks

**Pattern:** `<action>_<resource>_<target>.yml`

**Examples:** `deploy_ipam_netbox.yml`, `troubleshoot_windows_remote_access.yml`

## References

- NetBox plan: `docs/plans/2026-05-08--netbox-naming-and-ansible-integration/`
- Framework rules: `.cursor/rules/framework-netbox-modeling.mdc`, `.cursor/rules/ansible-coding-standards.mdc`
- Version contract pattern: `roles/langfuse_cli/`, `roles/common/node/`
- Existing naming discussions: `docs/brainstorming_designs/homelab_naming_model.md`

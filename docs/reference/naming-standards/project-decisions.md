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

### 3. Compact VM Names With Details in Fields

**Decision:** VM names follow `<scope>-<role>-<nn>` pattern with details in NetBox fields.

**Target pattern:**
```
s225-dkr-01    # server-225 scope, docker role, instance 01
s225-k3s-01    # server-225 scope, k3s role, instance 01
```

**Rationale:**
- Short names are easier to type, read, and use in CLIs
- Platform, IP, site, cluster details belong in structured fields
- Name stays stable even if underlying details change
- Follows industry patterns (AWS, GCP, enterprise naming)

**Current state:**
- Existing `server-225-ubuntu` VM name preserved until rebuild
- New VMs follow compact pattern
- Migration happens at natural rebuild/replacement points

**What belongs where:**

| Concept | In Name? | In NetBox Field | Example |
|---|---|---|---|
| Host scope | Yes | Device or custom field | `s225` |
| Role | Yes | VM role + tags | `dkr`, `k3s` |
| Sequence | Yes | Part of name | `01`, `02` |
| Platform | No | Platform | `Ubuntu 24.04` |
| IP address | No | Interface + primary IP | `192.168.137.10` |
| Host placement | No | Cluster | `server-225-hyperv` |

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

**Future:** `s225-dkr-01` when VM is rebuilt.

**Reason:** Current name is stable and working. Rename at rebuild, not as in-place change.

### Current Hosts: `server-225-win`, `server-225-win-powershell`

**Assessment:** Windows host is `server-225-win`. `server-225-win-powershell` is SSH alias for OpenSSH access to PowerShell on Windows host.

**Future:** Keep for now. Scope code `s225` adoption pending.

**Reason:** Host names are deeply embedded in inventory, SSH config, WinRM config. Stable until broader `s225` scope model finalizes.

### Current Roles: `ipam_netbox`, `hyperv_ubuntu_vm`, `speech_central`

**Assessment:** Already capability-focused. Good.

**Future:** Continue this pattern.

### Current Service Endpoints

**Current:** Port-proxies tracked in static inventory (e.g., NetBox on `192.168.50.158:8000`).

**Future:** Model as NetBox service objects or service records.

**Reason:** Service modeling pattern not yet decided. Keep in inventory until NetBox service model is designed.

## Open Questions

### Scope Code: `s225`

**Question:** Should `s225` represent the physical host (`server-225`), a site/location scope, or just operator shorthand?

**Current thinking:** Physical host scope.

**Decision point:** When adding second physical host or modeling multi-site.

### Legacy Name Retirement

**Question:** When should `server-225-ubuntu` be renamed to `s225-dkr-01`?

**Current thinking:** At VM rebuild or major refactor.

**Decision point:** When Docker node is rebuilt or VM template changes.

### Service Endpoint Modeling

**Question:** How should LAN-published services (NetBox, Semaphore, port-proxies) be modeled?

**Options:**
1. NetBox service records on the VM
2. NetBox service records on the Windows host
3. Keep in Ansible inventory as port-proxy config

**Current thinking:** Option 1 (service records on VM) makes most sense.

**Decision point:** When NetBox service modeling is implemented.

### Cluster Naming

**Question:** Should Hyper-V cluster be named `server-225-hyperv` or `s225-hyperv`?

**Current thinking:** Follow same scope pattern as VMs when scope model finalizes.

**Decision point:** When scope code is finalized and second cluster is added.

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

**Pattern:** `<scope>-<role>-<nn>`

**Examples:** `s225-dkr-01`, `s225-k3s-01`

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

# NetBox Naming Conventions

## Source

- Official NetBox Documentation: https://docs.netbox.dev/en/stable/
- Device Model: https://docs.netbox.dev/en/stable/models/dcim/device/
- Device Role Model: https://docs.netbox.dev/en/stable/models/dcim/devicerole/

## Hard Requirements (MUST)

### Device Names

- **Uniqueness**: Device names must be unique within a site, unless the device has been assigned to a tenant
- **Optional**: Device names are optional — devices can be unnamed
- **Scope**: When set, name must be unique to the assigned site and tenant combination

### Slug Generation

- **URL-Friendly**: Slugs must be URL-friendly identifiers
- **Uniqueness**: Slugs must be unique within their object type
- **Case**: Lowercase recommended for consistency (though NetBox generates slugs from display names)

## Recommendations (SHOULD)

### Display Name vs Slug

- NetBox generates slugs automatically from display names by default
- For programmatic/automation-heavy environments, **align display name with slug** to reduce cognitive load
- Pattern: Use lowercase-kebab for both display name and slug when repo controls the object
- Exception: Proper product names (e.g., "Windows Server 2025", "Ubuntu 24.04") should preserve vendor casing

### Native Fields Before Custom Fields

NetBox has rich native models. Before creating custom fields, check if a native field already exists:

| Concept | NetBox Native Field | Notes |
|---|---|---|
| Operating system / software stack | `platform` | Platform object with name, slug, manufacturer |
| Host function / purpose | `device_role` or `virtual_machine_role` | Role with name, slug, color, optional hierarchy |
| Physical hardware model | `device_type` | Manufacturer + model, includes component templates |
| Environment / physical location | `site` | Site with name, slug, description, optional physical address |
| Specific location within site | `location` | Optional nested location hierarchy within a site |
| Virtualization layer | `cluster_type` + `cluster` | Cluster assigns VMs to hypervisor group |
| VM placement on specific host/cluster | `cluster` assignment | VMs assigned to clusters; clusters can be assigned to devices |
| Network address | `ip_address` assigned to `interface` | IPs belong to interfaces, not directly to devices/VMs |
| Management IP | `primary_ip4` / `primary_ip6` | Designated primary management address |
| Out-of-band management | `oob_ip` | Separate management network address |
| Ownership / automation labels | `tag` | Seed tags first, apply to objects |

### Tag-Based Controlled Vocabulary

Before adding custom fields for boolean, category, or ownership labels, use tags:

- Tags are first-class controlled vocabulary
- **Lowercase-hyphen slugs**: `ansible-managed`, `homelab`, `hyperv`
- Seed tags via API/Ansible so they're version-controlled
- Apply tags to objects for queryable dimensions
- Tags enable powerful filtering and grouping in `nb_inventory` and API queries

### Object Hierarchy (REQUIRED)

NetBox enforces specific hierarchies. Understand them before creating objects:

**Physical hierarchy:**
```
Site → [Location] → Device → Device Components
```

**Virtual hierarchy:**
```
Site → Cluster Type → Cluster → Virtual Machine → Interface → IP Address
```

**Network hierarchy:**
```
Site → Prefix → IP Address
```

**Rules:**
- Cannot create a VM without a cluster
- Cannot assign IPs without creating the interface first
- Cannot add a device without a site
- Location is optional within a site

### Role Naming

- **Functional names**: Name roles by function, not by vendor or model
  - Good: `hyperv-host`, `docker-engine`, `k3s-master`
  - Avoid: `dell-r750`, `server-225-type`
- **Hierarchy**: Device roles support optional parent/child relationships
- **VM-capable roles**: Mark roles that apply to VMs with the `VM Role` flag

### Platform Naming

- **Proper product names**: Use canonical vendor casing
  - "Windows Server 2025" not "windows-server-2025"
  - "Ubuntu 24.04" not "ubuntu-24-04"
- **Association**: Platforms can be associated with specific manufacturers
- **Consistency**: Use consistent platform names across all objects

## Common Patterns

### Deterministic Server Naming

NetBox documentation references deterministic naming patterns built from:

- **Site code**: Short identifier for physical location
- **Role code**: Function-based identifier
- **Sequence number**: Numeric suffix for instances

Example pattern:
```
<site-code>-<role>-<sequence>
```

Implementations:
- `lab-hv-k3s-master-01` — lab site, hyperv, k3s master, instance 01
- `prod-db-primary-01` — prod site, database, primary role, instance 01
- `dev-app-worker-03` — dev site, application, worker role, instance 03

### What Belongs in the Name vs Fields

**In the name:**
- Site/location identifier (if short and stable)
- Primary function/role identifier (if compact)
- Sequence number (for instance differentiation)

**In NetBox fields, not the name:**
- IP addresses → `primary_ip4`/`primary_ip6`
- Operating system → `platform`
- Detailed function → `device_role`
- Physical model → `device_type`
- Ownership → `tenant`
- Automation intent → `tags`
- Environment → `tags` or site-based grouping

## nb_inventory Integration

NetBox's dynamic inventory plugin groups by:

- `device_roles` → creates groups like `device_role_hyperv_host`
- `platforms` → creates groups like `platform_ubuntu_22_04`
- `sites` → creates groups like `site_homelab`
- `clusters` → creates groups like `cluster_k3s_homelab`
- `cluster_types` → creates groups like `cluster_type_kubernetes`
- `tags` → creates groups like `tag_ansible_managed`
- `tenants` → creates groups like `tenant_engineering`

**Design principle:** Structure objects so `nb_inventory` naturally produces useful groups without custom logic.

## Constraints

- **Case sensitivity**: Names and slugs are case-sensitive in NetBox database
- **Special characters**: Slugs are URL-safe (alphanumeric + hyphens + underscores)
- **Length**: No documented hard limits, but practical limits apply for UI/API usability
- **Uniqueness scope**: Most objects enforce uniqueness within their parent (site, cluster, etc.)

## Rationale

### Why Native Fields First

- NetBox's data model is optimized for IPAM/DCIM at scale
- Native fields participate in built-in filtering, grouping, API query patterns
- Custom fields add maintenance burden and don't integrate as deeply
- Future NetBox features assume standard object shapes

### Why Tags Before Custom Fields

- Tags are queryable across all object types
- Tags enable API filtering: `GET /api/extras/tags/<slug>/tagged-objects/`
- Tags integrate with `nb_inventory` grouping automatically
- Tags are lightweight — no schema changes required

### Why Name = Slug for Programmatic Environments

- Reduces cognitive overhead when reading YAML, API responses, inventory dumps
- Makes it obvious which string is "real" when troubleshooting
- Aligns with automation-first environments (homelab, infrastructure-as-code)
- Exception for proper product names preserves vendor clarity

## Anti-Patterns to Avoid

- ❌ Embedding IP addresses in device/VM names
- ❌ Encoding platform in names when `platform` field exists
- ❌ Creating custom fields for data NetBox already models natively
- ❌ Inconsistent casing between display name and slug for repo-controlled objects
- ❌ Creating devices/VMs without checking hierarchy requirements first
- ❌ Assigning IPs directly to devices/VMs (they belong to interfaces)

## References

- NetBox models: https://docs.netbox.dev/en/stable/models/
- NetBox API: https://docs.netbox.dev/en/stable/integrations/rest-api/
- Dynamic inventory plugin: https://docs.ansible.com/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html

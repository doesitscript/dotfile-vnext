# Naming Standards Reference

## Purpose

This folder contains aggregated naming research from authoritative sources across multiple infrastructure and automation ecosystems. It serves as a lightweight local registry for brainstorming, evaluating, and creating names for:

- Ansible roles, playbooks, and variables
- NetBox objects (devices, VMs, sites, clusters, platforms, roles, tags)
- Infrastructure resources (cloud, containers, orchestration)
- Repository structures and conventions

## Project Stance: Continual Maturity and Improvement

**All existing naming in this project is subject to improvement based on research and best practices.**

This project does not force-fit new research into existing conventions. Instead:

1. **Research drives improvement** — when authoritative sources show better patterns, we adapt
2. **Existing decisions are not sacred** — they were the best choice at the time with available knowledge
3. **Migration is intentional** — we don't rename everything at once, but we do set direction
4. **New work follows better patterns** — recent research guides new resources
5. **Legacy can coexist** — old names can remain until natural rebuild/replacement points

### Design Philosophy

- **Authority over precedent** — when official docs conflict with existing repo patterns, the docs win
- **Clarity over brevity** — readable beats compact when scale matters
- **Consistency over snowflakes** — one good pattern beats ten custom solutions
- **Forward-looking** — optimize for "100 nodes" not "works today"

## Current Emerging Standard

Prioritize Cloud Posse-style context assembly and NetBox-native source-of-truth
fields when naming infrastructure objects.

The current baseline pattern to meet or exceed is:

```text
<namespace?>-<tenant>-<environment>-<stage>-<role_code>-<nn>
```

For current NetBox-backed homelab device naming, the working baseline example is:

```text
home-lab-auth-hvh-01
```

The `namespace` segment is optional in the rendered name. Keep it out of the
name when it would be redundant, but still track it as context.

Every recommendation using this standard must show the data that produced it:

```yaml
context:
  namespace:
    value:
    include_in_name:
  tenant:
    value:
  environment_or_site:
    value:
  stage:
    value:
  role_code:
    value:
  sequence:
    value:
role:
  slug:
  name:
platform:
  name:
  slug:
netbox:
  site:
  tenant:
  device_role:
  platform:
  tags: []
  config_context: {}
  custom_fields: {}
```

Historical inventory names such as `server-225-win` and the retired
network-server Windows control alias
can remain as aliases and migration context. They do not define the mature
schema unless a future decision explicitly promotes them into a controlled
scope-code registry.

### NetBox Update Order

NetBox-backed naming changes are not done when the UI or API has changed. The
project-safe path is repo seed/config first, the repo consistency gate second,
and NetBox apply third:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml \
  --tags ipam_netbox_repo_consistency
```

That gate blocks stale active references to retired NetBox names in inventory,
playbooks, scripts, and stored plans, while allowing explicit legacy-alias and
migration context.

### How to Use This Folder

When naming a new resource:

1. Start with the current emerging standard above.
2. Check the relevant ecosystem guide, with Cloud Posse context and NetBox modeling first for infrastructure identity.
3. Review patterns and examples.
4. Apply the pattern consistently.
5. Document exceptions in project-specific notes.

When existing names conflict with research:

1. Document the gap
2. Propose alignment for new work
3. Plan migration at natural boundaries (rebuilds, refactors)
4. Don't force immediate renames unless actively harmful

## Research Sources

This folder aggregates guidance from:

- **NetBox** — DCIM/IPAM naming conventions
- **Cloud Posse** — Terraform context module and tagging patterns
- **Terragrunt** — Infrastructure-as-code directory and resource naming
- **Kubernetes** — DNS-1123 naming rules and workload conventions
- **AWS** — Tagging and resource naming best practices
- **Ansible** — Role, playbook, inventory, and variable naming
- **Docker** — Container and image naming rules
- **Community examples** — Real-world patterns from widely-adopted projects

## Folder Structure

```
naming-standards/
├── README.md                          # This file
├── research-plan.md                   # Systematic research execution plan
├── netbox-naming.md                   # NetBox conventions and patterns
├── cloud-posse-context.md             # Cloud Posse context module patterns
├── terragrunt-structure.md            # Terragrunt directory and naming patterns
├── kubernetes-naming.md               # Kubernetes DNS-1123 and workload naming
├── aws-tagging.md                     # AWS tagging and resource naming
├── ansible-naming.md                  # Ansible role, playbook, variable naming
├── docker-naming.md                   # Docker container and image naming
├── community-examples.md              # Real-world examples from widely-used repos
├── cross-ecosystem-patterns.md        # Common patterns across systems
└── project-decisions.md               # Project-specific naming decisions and rationale
```

## Status

- **Research phase**: Active
- **Coverage**: Multi-ecosystem (8+ systems)
- **Application**: Guides new work, flags improvement opportunities
- **Enforcement**: Framework rules reference this folder when applicable

## Integration Points

This research feeds into:

- `.cursor/rules/framework-netbox-modeling.mdc` — NetBox-specific naming gates
- `.cursor/rules/ansible-coding-standards.mdc` — Ansible naming conventions
- `docs/plans/2026-05-08--netbox-naming-and-ansible-integration/` — Active NetBox modeling work
- Future: role templates, scaffolding tools, automated naming validators

## Next Steps

1. Complete systematic research of all source links
2. Extract patterns, rules, and examples from each ecosystem
3. Identify cross-cutting principles
4. Document project-specific decisions and deviations
5. Create quick-reference tables for common naming scenarios
6. Build naming decision trees for complex resources

---

*This folder represents the project's commitment to evidence-based naming that scales with the infrastructure.*

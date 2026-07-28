# Homelab capability policy (data, not prose)

Versioned YAML under this directory is the durable home for capability-selector
logic discussed for Open WebUI / AI lanes / storage / GPU placement.

## Mental model

```text
policy/execution_roles.yml     = “what ai-client-ui means + how to match”
inventory host_vars            = “facts about this host” (classes, planes, state)
classify_host                  = computes labels/roles at runtime
open_webui_state: present      = “commission this capability here”
```

Lots of designators live in **policy**; inventory stays relatively thin host
truth + commission flags. Do not stamp derived roles onto every host_vars file.

**Roles consume this data.** Host inventory still declares *facts about the host*
(`hardware_classes`, `runtime_planes`, `policy_classes`, `node_classes`,
`inventory_surface_role`). Policy defines *what those mean* and how they map to
execution roles and Kubernetes intent.

**Product flow skill:** `.cursor/skills/homelab-product-capability-flow/`
(library → plan → Ansible intake → apply → NetBox).

| File | Purpose |
| --- | --- |
| `hardware_classes.yml` | Controlled vocabulary for GPUs, VRAM, storage |
| `execution_roles.yml` | Personas + match rules + k8s + per-role `depends_on` |
| `runtime_planes.yml` | Named planes hosts may enable |
| `k8s_mapping.yml` | Shared label/taint vocabulary (affinity, not hostname) |
| `coverage.yml` | Inventory hosts that must classify |
| `process_order.yml` | **SSOT** for process/`depends_on` / apply order |
| `compose_stacks.yml` | Compose layout contract (salvaged from fuzlang) |
| `legacy_node_map.yml` | Historical main_node → inventory map (salvaged) |
| `netbox_service_metadata.yml` | NetBox service/tag guidance (salvaged) |

## Process order (`depends_on`)

Do not leave dependency order only in prose. See `process_order.yml`:

```text
policy_data → inventory_structure → classify_host
  → runtime_plane_report / k8s_node_policy / open_webui
```

Role `meta/main.yml` Ansible `dependencies:` enforce classify-before-apply when
facts are missing. Playbook headers mirror the same chains.

## Interpreter

```text
playbooks/classify_homelab_hosts.yaml  →  roles/classify_host
```

Read-only by default: prints `host_classification` per inventory host. No
hostname targeting — hosts match via inventory fields + policy match rules.

Coverage: `policy/coverage.yml` — every inventory host must have selector
structure or `classification_status`. Unmatched structure fails classify.

## Anti-invent gate

Before inventing `hosts:` / placement: research `policy/*.yml`, then run
classify. See AGENTS.md Research Expectations §13 and
`homelab-ansible-first-entry`.

## Enforcement (gated)

| Role | Default | Mutates when |
| --- | --- | --- |
| `k8s_node_policy` | report only | `k8s_node_policy_state: present` **and** `k8s_node_policy_apply: true` |
| `runtime_plane` | report only | `runtime_plane_state: present` **and** `runtime_plane_apply: true` |

Do not enable apply until a preview receipt looks correct.

## Related

- HRL: `implementation-guides/ansible/capability-selectors-netbox-ansible-k8s.md`
- HRL Open WebUI: `implementation-guides/open-webui/ansible-compose-option-a.md`
- Product contracts: `contracts/open-webui.yaml`, `contracts/litellm.yaml`
- Contracts index: `contracts/README.md`
- Skill: `homelab-product-capability-flow`
- Legacy archive only: `contracts/fuzlang.contract.yaml` (do not grow)

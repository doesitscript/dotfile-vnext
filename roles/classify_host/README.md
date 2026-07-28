# classify_host

Interprets repo `policy/*.yml` against inventory host fields and sets
`host_classification` (and convenience facts) for later roles.

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/classify_homelab_hosts.yaml` |
| **Verify** | Play prints `host_classification` per host; `policy_ok: true` |
| **Undo** | N/A (read-only facts; no host mutation) |
| **Change class** | Idempotent report / derived facts |

## Inputs (inventory)

- `hardware_classes`, `node_classes`, `policy_classes`
- `runtime_planes.<plane>.enabled`
- `inventory_surface_role` (e.g. `docker_engine`)

## Outputs (facts)

- `host_classification` — full dict
- `host_execution_role` — first matched role
- `host_execution_roles` — all matched roles
- `host_k8s_labels` / `host_k8s_taints` / `host_k8s_selectors`
- `host_runtime_planes` — enabled plane keys

## Anti-pattern

Do not target `hosts: HOM-LAB-HVH-02`. Classification is data-driven.

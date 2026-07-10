# k3s_traefik_routes

Shared capability role that applies Kubernetes Ingress objects for **K3s
kube-system Traefik** from the route registry.

## SSOT

| Layer | Location |
|-------|----------|
| Patterns | `docs/reference/naming-standards/ansible.yml` → `k3s_traefik_routes` |
| Reference instances | `docs/reference/naming-standards/live-object-registry.yml` → `ingress_routes` |
| Runtime registry | `inventory/group_vars/k3s_cluster.yaml` → `k3s_traefik_routes_entries`, `k3s_traefik_routes_http_node_port` |

## Lifecycle

```yaml
k3s_traefik_routes_state: present | absent
```

Default **`absent`** until operator sets `present` for apply.

## Does / does not

| Does | Does not |
|------|----------|
| Apply/remove Ingress CRs | Install Traefik from scratch |
| Pin packaged Traefik HTTP NodePort via `HelmChartConfig` | Manage app secrets |
| Standard labels/annotations | Deploy Helm releases |
| Verify backend Services exist and live Traefik HTTP NodePort alignment | |

## Playbook

`playbooks/k3s_traefik_routes.yaml` — tags: `k3s_traefik_routes_apply`, `k3s_traefik_routes_verify`, `k3s_traefik_routes_preview`

## Apply / Verify / Undo / Change class

| | |
|---|---|
| **Apply** | `--tags k3s_traefik_routes_apply -e k3s_traefik_routes_state=present` on `hom-lab-ctl-k3s-02`; packaged Traefik `web` NodePort is pinned from `k3s_traefik_routes_http_node_port` |
| **Verify** | `--tags k3s_traefik_routes_verify`; confirm Traefik Service, declared `web` NodePort, and backend Services |
| **Undo** | `k3s_traefik_routes_state: absent` |
| **Class** | Idempotent config |

## Related

- `roles/homelab_hosts_file_mac` — mac-dev operator hostnames
- `guest_published_tcp_ports` `k3s-traefik-http` on `HOM-LAB-HVH-02`
- `docs/intake/k3s-hyperv-traefik-blueprint.md`

# Findings

## Purpose

- This file is the detailed correlation and duplicate-entry audit for the `2026-07-09--homelab-lan-edge-drift-remediation-incomplete` packet.
- `README.md` remains the governed plan entrypoint; this file carries the high-signal findings that support the plan scope and receipt.

## Naming Baseline

- Canonical host naming for the Windows storage-lane host is now `HOM-LAB-HVH-01`.
- The older `HOM-LAB-HVH-01` form should be treated as stale except where explicitly preserved as history or compatibility evidence.
- Canonical host naming for the Windows GPU-lane host is `HOM-LAB-HVH-02`.
- Plan prose should use `HOM-LAB-HVH-01` and `HOM-LAB-HVH-02` for the host/project names. Repo file paths remain lowercase where that is how the files are stored.

## Authority And Duplicate-Entry Findings

### `HOM-LAB-HVH-02` LAN publish identity

| Value family | Active owner / consumer surfaces | Finding |
|---|---|---|
| `192.168.50.158` publish IP | `inventory/host_vars/HOM-LAB-HVH-02.yaml`, `inventory/hosts_mapping.yaml`, `inventory/group_vars/all/homelab_router_gt6.yml`, `docs/reference/naming-standards/live-object-registry.yml` | Active authority agrees on `.158` as the modeled steady state |
| Repeated `.158` consumers | `inventory/netbox.yml`, `roles/mcp_servers/netbox/defaults/main.yml`, `roles/k3s_traefik_routes/defaults/main.yml`, `roles/homelab_hosts_file_mac/defaults/main.yml`, `inventory/host_vars/hom-lab-ctl-dkr-02.yaml`, operator docs | Several repeats were hard-coded consumer copies rather than authority-driven values |
| Live drift value `.159` | Live Windows probe output and DNS-investigator evidence | `.159` appeared as live drift, not as active repo authority |
| `os_hostname` | `inventory/host_vars/HOM-LAB-HVH-02.yaml`, `inventory/hosts_mapping.yaml`, `docs/reference/naming-standards/live-object-registry.yml` | Registry previously lagged with `DESKTOP-VLLM`; active repo/host truth is `HOM-LAB-HVH-02` |

### `HOM-LAB-HVH-01` storage-lane identity

| Value family | Active owner / consumer surfaces | Finding |
|---|---|---|
| `192.168.50.234` publish IP | `inventory/host_vars/HOM-LAB-HVH-01.yaml`, `inventory/hosts_mapping.yaml`, `docs/reference/naming-standards/live-object-registry.yml`, storage-lane consumer config | Repo authority stays aligned on `.234` |
| `192.168.138.x` guest lane | `inventory/host_vars/hom-lab-ctl-dkr-01.yaml`, `inventory/host_vars/hom-lab-ctl-k3s-01.yaml`, storage-lane consumer config | No repo renumber was discovered; the issue stayed in live recovery / direct reachability |
| Host naming | `inventory/host_vars/HOM-LAB-HVH-01.yaml`, `inventory/hosts_mapping.yaml`, plan packet text | The project recently renamed `HOM-LAB-HVH-01` to `HOM-LAB-HVH-01`; any remaining `ctl` references are packet drift or history |

### Service-publication families

| Service family | Active modeled layers | Finding |
|---|---|---|
| `langfuse.hom.lab` | `inventory/group_vars/k3s_cluster.yaml`, `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/reference/naming-standards/live-object-registry.yml`, `roles/ipam_netbox/defaults/main.yml` | Declared across four active layers; live publication stayed unhealthy |
| `litellm.hom.lab` | `inventory/group_vars/k3s_cluster.yaml`, `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/reference/naming-standards/live-object-registry.yml`, `roles/ipam_netbox/defaults/main.yml` | Declared across four active layers; live publication stayed unhealthy |
| `netbox/semaphore/loki` LAN names | `homelab_hosts_file` catalog, `inventory/netbox.yml`, role defaults / consumer literals | Owners were stable, but the `.158` publish edge still failed from `mac-dev` during verification |

## Live-State Findings From Execution

### Hyper-V hosts

- `HOM-LAB-HVH-02` was observed in a drifted state where `.159` appeared on the external interface while portproxy listeners and repo authority remained on `.158`.
- The documented IPv6 fallback for `HOM-LAB-HVH-02` stayed usable even after the IPv4 management path degraded, and it was sufficient to complete the Hyper-V owner playbook.
- `HOM-LAB-HVH-01` recovered enough for SSH on `.234` and published storage ports to answer again after the Hyper-V owner reapply.

### Guest-lane reachability

- Direct guest reachability from `mac-dev` to `192.168.137.x` and `192.168.138.x` remained blocked at the end of the execution slice.
- The affected guest VMs were still reachable indirectly through SSH proxying via their Hyper-V hosts.
- This means VM power state and guest SSH were not the final blocker; the remaining blocker sat in routing/publication verification from `mac-dev`.

### K3s publication

- Only `litellm-gateway-ingress` existed live during verification; `langfuse-web-ingress` was still absent.
- `EndpointSlice` objects existed for Langfuse and LiteLLM, but classic `Endpoints` objects were empty for the relevant services.
- Direct NodePort probes to `30000` and `30400` failed.
- Traefik host-header probes for `langfuse.hom.lab` and `litellm.hom.lab` returned `404`.

### Dependency recovery and remaining K3s blocker

- Earlier logs showed Langfuse and LiteLLM failing on storage dependencies at `192.168.50.234`.
- After storage-lane recovery, those dependency ports were reachable again from `mac-dev`, and storage containers on `192.168.138.10` were healthy.
- The remaining K3s block shifted to node egress / image-pull behavior:
  - Langfuse pods moved into `ErrImagePull` / `ImagePullBackOff`
  - LiteLLM events reported failed resolution or pull attempts against `docker.litellm.ai`
  - guest egress probes from the K3s node failed, including ping to `1.1.1.1`

## Plan-Shaping Conclusions

- Keep `.158` as the canonical `HOM-LAB-HVH-02` publish edge unless a future authority audit proves `.159` is intentional steady state.
- Keep `.234` as the canonical `HOM-LAB-HVH-01` publish edge; current remaining work is live networking/publication, not repo renumber.
- Treat the `HOM-LAB-HVH-01` rename as already approved and integrate it across packet prose and future receipts, while leaving real lowercase file paths intact unless the repo explicitly renames those files too.
- Separate the packet into `README.md`, `findings.md`, and `fixes.md` so correlation evidence and remediation sequencing can evolve independently without bloating the governed entrypoint.

## Stability Receipt — 2026-07-09

- `kubectl` from `mac-dev` works against both clusters again.
- `hom-lab-ctl-k3s-02` is reachable with `kubectl --context hom-lab-ctl-k3s-02 get pods -A`.
- `langfuse.hom.lab` returns `200 OK`.
- `litellm.hom.lab` returns `200 OK`.
- Direct fallback publishes also work:
  - `http://langfuse.hom.lab:30000/` returns `200 OK`
  - `http://litellm.hom.lab:30400/health/readiness` returns `405` to `HEAD`, which is expected for that GET-only endpoint
- K3s-side objects are healthy:
  - Langfuse web and worker are running
  - LiteLLM is running with live endpoints
  - vLLM is running
  - both Traefik ingresses exist and passed the route role backend checks

## Residual

- One old failed pod remains from an earlier bad attempt: `litellm-migrations-4vdmd`.
- The current `litellm-migrations` job completed and the live LiteLLM service is healthy.
- No one-off remote cleanup was performed for the leftover pod because it is not required for service health.

## Sources Checked For This Stability Receipt

- Repo files:
  - [playbooks/access.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/access.yaml)
  - [playbooks/deploy_gpu_infrastructure.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/deploy_gpu_infrastructure.yaml)
  - [inventory/host_vars/hom-lab-ctl-k3s-02.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-ctl-k3s-02.yaml)
  - [inventory/host_vars/hom-lab-hvh-02.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-hvh-02.yaml)
  - [roles/k3s_mac_client/tasks/present_cluster.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_mac_client/tasks/present_cluster.yml)
  - [roles/k3s_langfuse_platform/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/tasks/present.yml)
  - [roles/k3s_litellm_gateway/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_litellm_gateway/tasks/present.yml)
  - [roles/k3s_vllm_runtime/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_vllm_runtime/tasks/present.yml)
  - [roles/hyperv_networking/tasks/routed_private_subnet.yml](/Users/joshc/develop/dotfile-vnext/roles/hyperv_networking/tasks/routed_private_subnet.yml)
  - [docs/reference/naming-standards/live-object-registry.yml](/Users/joshc/develop/dotfile-vnext/docs/reference/naming-standards/live-object-registry.yml)
- Live apply and verify:
  - `ansible-playbook playbooks/deploy_langfuse_platform.yaml -e k3s_langfuse_platform_fresh_install=true`
  - `ansible-playbook playbooks/deploy_litellm_gateway.yaml`
  - `ansible-playbook playbooks/deploy_vllm_runtime.yaml`
  - `ansible-playbook playbooks/k3s_traefik_routes.yaml`
  - `ansible-playbook playbooks/k3s_mac_client.yaml`
  - `ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml --limit HOM-LAB-HVH-02`
- Live probes:
  - `kubectl --context hom-lab-ctl-k3s-02 get pods -A`
  - `curl -I http://langfuse.hom.lab`
  - `curl -I http://litellm.hom.lab`
  - `curl -I http://langfuse.hom.lab:30000/`
  - `curl -I http://litellm.hom.lab:30400/health/readiness`
  - `netsh interface portproxy show v4tov4`
  - `Test-NetConnection 192.168.137.11 -Port 30189`

# Fixes

## Purpose

- This file is the detailed fix plan and execution-oriented lane map for the `2026-07-09--homelab-lan-edge-drift-remediation-incomplete` packet.
- `README.md` remains the canonical plan entrypoint; this file carries the more granular remediation slices, sequencing, and remaining blockers.

## Naming Baseline

- Use `HOM-LAB-HVH-01` as the canonical host/project name for the former `HOM-LAB-HVH-01` surface.
- Use `HOM-LAB-HVH-02` as the canonical host/project name for the GPU-lane Hyper-V host.
- Keep lowercase spellings only where they are literal filesystem paths, inventory aliases, or other repo identifiers that have not been renamed on disk.
- Keep guest inventory aliases such as `hom-lab-ctl-dkr-02`, `hom-lab-ctl-k3s-02`, `hom-lab-ctl-dkr-01`, and `hom-lab-ctl-k3s-01` until a separate approved rename packet says otherwise.

## Fix Lanes

### Slice A — authority cleanup and packet hygiene

| Change area | Planned / landed fix |
|---|---|
| Reusable defaults | Remove host-specific hard-coded `.158` fallbacks from `roles/k3s_traefik_routes`, `roles/mcp_servers/netbox`, and `roles/homelab_hosts_file_mac` where inventory already owns the value |
| Naming registry | Correct `hvh-02` stale `os_hostname` in `live-object-registry.yml` |
| Consumer drift | Replace safe hard-coded consumer literals with inventory-derived values where practical |
| Packet naming | Update packet prose to `HOM-LAB-HVH-01` / `HOM-LAB-HVH-02` current truth without inventing filesystem renames |

### Slice B — `HOM-LAB-HVH-02` LAN-edge convergence

| Step | Status | Notes |
|---|---|---|
| Add Hyper-V preview receipt | landed | New preview path in `playbooks/configure_hyperv_windows_hosts.yaml` plus `roles/hyperv_networking/tasks/preview.yml` |
| Add publish-surface probe | landed | New `published_port_surface_probe.yml` gathers interface IPs, listeners, and portproxy rows |
| Guard portproxy convergence | landed | Role now asserts declared listen addresses exist before portproxy apply |
| Recover live `.158` management edge | landed | Recovery completed using the documented IPv6 fallback to `HOM-LAB-HVH-02` |
| Remaining verify gate | blocked | `.158` service ports are still closed from `mac-dev` even though host-side `.158` and portproxy state reconverged |

### Slice C — `HOM-LAB-HVH-01` storage-lane recovery

| Step | Status | Notes |
|---|---|---|
| Reconfirm `.234` authority | landed | No repo renumber required |
| Reapply Hyper-V networking owner | landed | Play completed and published storage ports reopened |
| Recover storage dependency ports | landed | `5432`, `6379`, `8123`, `9000`, `9001` answered from `mac-dev` after apply |
| Remaining verify gate | blocked | Direct `192.168.138.x` guest reachability from `mac-dev` still fails |

### Slice D — Langfuse / LiteLLM publication repair

| Step | Status | Notes |
|---|---|---|
| Strengthen route verification | landed | `roles/k3s_traefik_routes` now checks ingress, endpoints, endpoint slices, and host-header probes |
| Reconcile app deploy order | pending live apply | Intended order remains Langfuse → LiteLLM → Traefik |
| Execute playbooks against K3s host | blocked | Proxied Ansible runs failed with `A worker was found in a dead state` before task execution |
| Confirm live failure mode | landed | Remaining block narrowed to K3s node egress / image-pull failure plus absent Langfuse ingress |

### Slice E — controller / NetBox consumers

| Step | Status | Notes |
|---|---|---|
| Re-render local hosts bridge | landed | `playbooks/homelab_hosts_file_mac.yaml` executed successfully |
| Re-render local NetBox MCP owner | landed | `playbooks/mac/mcp_servers.yaml --tags netbox` executed successfully |
| NetBox seed/reconcile apply | blocked | Deferred until service publication and verify gates are trustworthy |
| NetBox live verification | blocked | Static gate passed, but full consistency and live service verification remain incomplete |

## Remaining Work Plan

### 1. Recover direct guest-route verification from `mac-dev`

- Investigate why `mac-dev` still cannot reach `192.168.137.x` and `192.168.138.x` directly even though:
  - Hyper-V guest gateways exist on `192.168.137.1` and `192.168.138.1`
  - guest VMs are reachable through SSH proxy from their Hyper-V hosts
  - the storage publish edge on `.234` recovered
- Focus the next read-only checks on:
  - `mac-dev` route entries for both guest subnets
  - router static route / reservation state on the GT6
  - Windows forwarding and firewall state on both Hyper-V hosts after convergence

### 2. Recover K3s node egress

- Prove why `hom-lab-ctl-k3s-02` cannot egress to public registries.
- Gather next evidence on:
  - guest default route and gateway reachability to `192.168.137.1`
  - DNS resolution from inside the guest for `docker.litellm.ai` and Docker Hub endpoints
  - outbound firewall / NAT / upstream route expectations for the routed-private-subnet model
- Do not call Langfuse or LiteLLM repaired until image pulls and pod startup succeed.

### 3. Re-run K3s owners once host egress is healthy

- Re-run, in order:
  - `playbooks/deploy_langfuse_platform.yaml`
  - `playbooks/deploy_litellm_gateway.yaml`
  - `playbooks/k3s_traefik_routes.yaml`
- Verification target:
  - both ingress objects present
  - backend endpoints populated
  - NodePorts live
  - Traefik host-header probes succeed
  - LAN-published names on `.158` succeed from `mac-dev`

### 4. Close NetBox and publication verification

- Re-run `playbooks/deploy_ipam_netbox.yaml` and `playbooks/reconcile_netbox.yaml` after service publication stabilizes.
- Re-run:
  - `scripts/validate_netbox_repo_consistency.sh`
  - `bin/netbox-authority-gate.sh --static-only`
- Treat pre-existing `nsrv-*` naming debt as separate cleanup scope unless this packet is explicitly widened to absorb it.

## Apply / Verify / Undo / Change Class

| | |
|---|---|
| **Apply** | Existing owners only: `configure_hyperv_windows_hosts.yaml`, `deploy_langfuse_platform.yaml`, `deploy_litellm_gateway.yaml`, `k3s_traefik_routes.yaml`, `homelab_hosts_file_mac.yaml`, `playbooks/mac/mcp_servers.yaml`, `deploy_ipam_netbox.yaml`, `reconcile_netbox.yaml` |
| **Verify** | Hyper-V preview receipts, `mac-dev` route and port probes, proxied SSH into guests when direct routes fail, `kubectl get/describe/logs/events`, NetBox consistency gates |
| **Undo** | Revert packet/authority edits, rerender owner-managed generated surfaces, and reapply previous Hyper-V/K3s state through the same playbooks |
| **Change class** | Mixed: repo authority cleanup, idempotent convergence, and live recovery of networking / publication paths |

## Execution Notes

- The packet now intentionally separates findings from fixes so future runs can update the evidence trail without rewriting the main plan narrative.
- The rename to `HOM-LAB-HVH-01`, alongside `HOM-LAB-HVH-02`, is already part of active packet truth and should be preserved in any follow-on plan or receipt updates.

## Stability-Focused Landed Fixes — 2026-07-09

- `playbooks/access.yaml` now chains into the mac hosts and kube client surfaces so controller access repair carries through to local operator access.
- `playbooks/deploy_gpu_infrastructure.yaml` now continues through the dependent application order:
  - `vllm`
  - `langfuse`
  - `litellm`
  - `traefik`
  - `k3s_mac_client`
- `roles/k3s_mac_client` now detects stale SSH tunnels, verifies the tunneled K3s API health, removes stale local kubeconfig artifacts when the remote source is absent, and recreates stale listeners instead of failing with a misleading local success surface.
- `roles/k3s_langfuse_platform` now supports a true fresh-install reset of the external Postgres database, uses lower resource requests for the single-node lane, disables ClickHouse cluster mode for the single-node external ClickHouse path, and adds retries around Helm operations.
- `roles/k3s_litellm_gateway` now creates the namespace before secret and Helm work, with stronger convergence around Helm ordering and retries.
- `roles/k3s_vllm_runtime` now supports a `Recreate` rollout bridge so request changes can converge on a one-GPU node without deadlocking on single-node scheduling.
- `roles/hyperv_networking` and the `HOM-LAB-HVH-02` owner data were corrected so `192.168.50.158:80` no longer points at retired Traefik NodePort `31461`; it now points at the live `30189`, which restored the bare `langfuse.hom.lab` and `litellm.hom.lab` URLs from `mac-dev`.

# Published endpoints — repo catalog index

Quick index of declared surfaces. Always re-read SSOT files for current values.

## Web catalog (`homelab_hosts_file_web_catalog`)

| catalog_key | hostname | typical verify_url | source |
|---|---|---|---|
| langfuse-web | langfuse.hom.lab | :30000 | k3s_traefik_routes_entries |
| litellm-gateway | litellm.hom.lab | :30400 | k3s_traefik_routes_entries |
| jupyter-workbench | jupyter.hom.lab | :8888/lab | guest_direct (k3s-02) |
| netbox-web | netbox.hom.lab | :8000 | guest_published_tcp_ports |
| semaphore-web | semaphore.hom.lab | :3001 | guest_published_tcp_ports |
| loki-http | loki.hom.lab | :3100/ready | guest_published_tcp_ports |
| grafana-web | grafana.hom.lab | :3000 | guest_direct (dkr-02) |

SSOT: `inventory/group_vars/all/homelab_hosts_file.yml`

## Portproxy item shape (one declared endpoint)

Parent skill documents full per-lane lists in [lane-inventory-truth-example.md](../../../examples/lane-inventory-truth-example.md). Each `guest_published_tcp_ports` entry:

```yaml
    - name: "loki"
      listen_address: "192.168.50.158"
      listen_port: 3100
      connect_address: "192.168.137.10"
      connect_port: 3100
```

## VM identity on hypervisor (links portproxy backend to inventory)

```yaml
hyperv_ubuntu_docker_vm_hostname: "hom-lab-ctl-dkr-02"
hyperv_ubuntu_docker_vm_inventory_host: "hom-lab-ctl-dkr-02"
```

LAN IP sweep (all hosts): [inventory-lan-ip-sources.md](../../../references/inventory-lan-ip-sources.md)

## Portproxy — hvh-02 (`192.168.50.158`)

| name | listen | → guest |
|---|---|---|
| loki | :3100 | 137.10:3100 |
| netbox | :8000 | 137.10:8000 |
| semaphore | :3001 | 137.10:3001 |
| k3s-traefik-http | :80 | 137.11:31461 |
| langfuse-k3s | :30000 | 137.11:30000 |
| litellm-k3s | :30400 | 137.11:30400 |

SSOT: `inventory/host_vars/HOM-LAB-HVH-02.yaml`

## Portproxy — hvh-01 (`192.168.50.234`)

| name | listen | → guest |
|---|---|---|
| postgres-fuzlang | :5432 | 138.10:5432 |
| redis-fuzlang | :6379 | 138.10:6379 |
| clickhouse-http | :8123 | 138.10:8123 |
| clickhouse-native | :9004 | 138.10:9004 |
| minio-api | :9000 | 138.10:9000 |
| minio-console | :9001 | 138.10:9001 |

SSOT: `inventory/host_vars/HOM-LAB-HVH-01.yaml`

## AI API surfaces

| Surface | URL |
|---|---|
| LiteLLM OpenAI-compatible | `http://litellm.hom.lab/v1` |
| Langfuse UI | `http://langfuse.hom.lab/` |

SSOT: `docs/reference/service-entrypoints-and-ai-surfaces.md`

## Kubernetes collection targets

When contexts are up, collect per cluster:

- `kubectl get ingress -A -o wide`
- `kubectl get svc -A` (filter NodePort, LoadBalancer, ClusterIP with external intent)
- `kubectl get endpoints -A` or `kubectl get endpointslices -A`

Typical namespaces: `litellm`, `langfuse`, `vllm-runtime`, `kube-system` (traefik).

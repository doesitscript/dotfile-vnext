# Report output example — homelab-published-endpoints

Example `published-endpoints.md` merged into the parent DNS investigation report.

---

# Published Endpoints Report

**Artifact dir:** `artifacts/troubleshooting/dns-investigation/20260709-100000/`  
**Subskill:** homelab-published-endpoints

## Declared (repo)

| catalog_key | hostname | verify_url | source | hosts_ip | lane |
|---|---|---|---|---|---|
| langfuse-web | langfuse.hom.lab | `:30000/` | k3s_traefik / portproxy | 50.158 | hvh-02 |
| litellm-gateway | litellm.hom.lab | `:30400/` | k3s_traefik / portproxy | 50.158 | hvh-02 |
| netbox-web | netbox.hom.lab | `:8000/` | guest_published_tcp_ports | 50.158 | hvh-02 |
| grafana-web | grafana.hom.lab | `:3000/` | guest_direct | 137.10 | hvh-02 |
| jupyter-workbench | jupyter.hom.lab | `:8888/lab` | guest_direct | 137.11 | hvh-02 |

hvh-01 lane (postgres, redis, minio on `50.234` → `138.10`): declared in inventory but **BLOCKED_UPSTREAM** when gateway down.

## Live (Kubernetes)

### hom-lab-ctl-k3s-02

```text
NAMESPACE   NAME              TYPE       PORT(S)
litellm     litellm-lan       NodePort   30400:30400/TCP
langfuse    langfuse-web      NodePort   30000:30000/TCP
```

Raw: `k8s-endpoints.txt`

### hom-lab-ctl-k3s-01

**blocked** — API `192.168.138.11:6443` unreachable; parent report shows gateway `192.168.50.234` down.

## Probed (mac-dev)

| target | probe | result | notes |
|---|---|---|---|
| `http://litellm.hom.lab:30400/health` | curl | `200` or unreachable | resolves to `50.158` via hosts |
| `http://langfuse.hom.lab:30000/` | curl | varies | same hosts path |
| `192.168.50.158:30400` | nc | OK if portproxy up | bypasses DNS |
| `http://litellm.hom.lab:30400/` via k3s-01 catalog | curl | BLOCKED_UPSTREAM | needs `138.x` lane |

Raw: `endpoint-probes.txt`

## Drift and gaps

| finding | evidence |
|---|---|
| Router GT6 has langfuse/litellm rows as `pending_add` | `homelab_router_gt6.yml` — Mac uses `/etc/hosts` only |
| Service names have no router DNS today | `dig @192.168.50.1` returns empty for `litellm.hom.lab` |
| k3s-01 declared services unreachable | gateway down — not missing from catalog |

## Lane blockers

| lane | blocker | affected endpoints |
|---|---|---|
| hvh-01 / k3s-01 | `192.168.50.234` down | minio, postgres, redis, clickhouse portproxies; k3s-01 ingress |
| hvh-02 / k3s-02 | none (this run) | litellm, langfuse, netbox, grafana, jupyter — probe individually |

## Assessment

Declared hvh-02 service hostnames resolve via `/etc/hosts` to the LAN publish IP (`50.158`) or guest IPs (`137.10`/`137.11`). Reachability depends on portproxy and guest health, not DNS zone gaps. k3s-01 endpoint rows remain catalog-valid but operationally blocked until hvh-01 returns.

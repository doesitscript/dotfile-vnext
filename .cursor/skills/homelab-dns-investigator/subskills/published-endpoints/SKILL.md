---
name: homelab-published-endpoints
description: Discover and report homelab published endpoints from repo catalogs (homelab_hosts_file, guest_published_tcp_ports, service entrypoints) and live Kubernetes ingress/services. Use when auditing what URLs and ports are declared vs reachable, or when invoked by homelab-dns-investigator during a connectivity report.
parent_skill: homelab-dns-investigator
---

# Published Endpoints (subskill)

Inventory declared endpoints from repo SSOT, compare to live Kubernetes, probe reachability, write `published-endpoints.md`.

**Invoke from:** `homelab-dns-investigator` step 5. Accepts the parent artifact directory as `ARTIFACT_DIR`.

## Repo sources (read, do not invent)

| Source | What it declares |
|---|---|
| `inventory/group_vars/all/homelab_hosts_file.yml` | `homelab_hosts_file_web_catalog` — hostname, `verify_url`, `hosts_ip` |
| `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | `hyperv_config.guest_published_tcp_ports` (storage lane) |
| `inventory/host_vars/hom-lab-ctl-hvh-02.yaml` | `hyperv_config.guest_published_tcp_ports` (GPU lane + K3s NodePorts) |
| `docs/reference/service-entrypoints-and-ai-surfaces.md` | Browser URLs and AI API surfaces |
| `roles/common/endpoint_verify/tasks/main.yml` | mac-dev probe URLs (may lag inventory — flag drift) |
| `roles/k3s_litellm_gateway/defaults/main.yml` | LiteLLM routes and NodePort contract |
| `roles/k3s_langfuse_platform/defaults/main.yml` | Langfuse hostname contract |

## Workflow

```text
[ ] 1. Extract repo catalog table
[ ] 2. Collect Kubernetes surfaces (per reachable context)
[ ] 3. Probe verify_url / listen endpoints from mac-dev
[ ] 4. Write published-endpoints.md
```

### Step 1 — Repo catalog

Build a table:

| catalog_key | hostname | verify_url | source | listen (portproxy) | declared hosts_ip |
|---|---|---|---|---|---|

Include every `homelab_hosts_file_web_catalog` row and every `guest_published_tcp_ports` entry from both hvh host_vars.

Run helper (optional):

```bash
ARTIFACT_DIR=artifacts/troubleshooting/dns-investigation/<timestamp> \
  .cursor/skills/homelab-dns-investigator/subskills/published-endpoints/scripts/collect_repo_endpoints.sh
```

### Step 2 — Kubernetes (when context reachable)

For each working context (`hom-lab-ctl-k3s-01`, `hom-lab-ctl-k3s-02`):

```bash
ARTIFACT_DIR=<dir> CONTEXT=hom-lab-ctl-k3s-02 \
  .cursor/skills/homelab-dns-investigator/subskills/published-endpoints/scripts/collect_k8s_endpoints.sh
```

Captures: `ingress`, `services` (NodePort/LoadBalancer), `endpoints` — saved to `k8s-endpoints.txt`.

If API unreachable, record **blocked — gateway down** with connection evidence from parent skill; do not skip the row.

### Step 3 — Reachability probes

For each `verify_url` and portproxy `listen_address:listen_port`:

```bash
curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 <url>
nc -z -G 3 <host> <port>
```

Save to `endpoint-probes.txt`. Status: `REACHABLE`, `UNREACHABLE`, `DNS_FAIL`, `BLOCKED_UPSTREAM`.

### Step 4 — Write `published-endpoints.md`

Use [references/output-template.md](references/output-template.md) in `ARTIFACT_DIR`.

Include:

- **Declared (repo)** — full catalog table
- **Live (Kubernetes)** — ingress/host, NodePort, cluster
- **Probed (mac-dev)** — HTTP code or TCP result
- **Drift** — repo declares but K8s missing, or K8s exposes undeclared port
- **Lane dependency** — mark k3s-01 / hvh-01 endpoints blocked when `50.234` down

## Boundaries

- Does not fix Ansible or deploy services
- Does not replace `roles/common/endpoint_verify` playbooks — complements with broader catalog + K8s dump
- Parent skill owns DNS/route evidence; this subskill owns URL/port inventory

## References

- [references/repo-catalog-index.md](references/repo-catalog-index.md)
- [references/output-template.md](references/output-template.md)
- [scripts/collect_repo_endpoints.sh](scripts/collect_repo_endpoints.sh)
- [scripts/collect_k8s_endpoints.sh](scripts/collect_k8s_endpoints.sh)

## Examples

- [examples/what-to-collect.md](examples/what-to-collect.md) — `*.hom.lab` service matrix, repo catalog rows, portproxy probes
- [examples/report-output-example.md](examples/report-output-example.md) — filled `published-endpoints.md` with drift and lane blockers

# What to collect — homelab-published-endpoints

Concrete example of endpoint inventory evidence. Parent skill owns hypervisor/guest DNS; this subskill owns **service names and URLs**.

## Service names (`*.hom.lab`)

| Name | Router DNS | Mac resolver | `.local` | `.lab` |
|---|---|---|---|---|
| `litellm` / `litellm.hom.lab` | none | `192.168.50.158` via hosts | none | none |
| `langfuse` / `langfuse.hom.lab` | none | `192.168.50.158` via hosts | none | none |
| `netbox`, `semaphore`, `loki` | none | `192.168.50.158` via hosts | none | none |
| `grafana` / `grafana.hom.lab` | none | `192.168.137.10` via hosts | none | none |
| `jupyter` / `jupyter.hom.lab` | none | `192.168.137.11` via hosts | none | none |

Key finding to record:

```text
Router has GT6 rows for langfuse/litellm → 50.158 but they're pending_add, not live DNS.
Mac gets these from /etc/hosts only.
Nothing resolves under .lab for any name tested.
```

## Repo catalog rows to extract

From `homelab_hosts_file_web_catalog` — match hostname to `verify_url`:

| catalog_key | hostname | verify_url | declared hosts_ip |
|---|---|---|---|
| langfuse-web | langfuse.hom.lab | `http://langfuse.hom.lab:30000/` | `192.168.50.158` |
| litellm-gateway | litellm.hom.lab | `http://litellm.hom.lab:30400/` | `192.168.50.158` |
| netbox-web | netbox.hom.lab | `http://netbox.hom.lab:8000/` | `192.168.50.158` |
| grafana-web | grafana.hom.lab | `http://grafana.hom.lab:3000/` | `192.168.137.10` |
| jupyter-workbench | jupyter.hom.lab | `http://jupyter.hom.lab:8888/lab` | `192.168.137.11` |

## Portproxy listen endpoints (hvh-02)

From `inventory/host_vars/hom-lab-ctl-hvh-02.yaml` — probe `listen_address:listen_port`:

| name | listen | backend |
|---|---|---|
| litellm-k3s | `192.168.50.158:30400` | `192.168.137.11:30400` |
| langfuse-k3s | `192.168.50.158:30000` | `192.168.137.11:30000` |
| netbox | `192.168.50.158:8000` | `192.168.137.10:8000` |

## Kubernetes (when context up)

```bash
ARTIFACT_DIR=<dir> CONTEXT=hom-lab-ctl-k3s-02 \
  .cursor/skills/homelab-dns-investigator/subskills/published-endpoints/scripts/collect_k8s_endpoints.sh
```

Look for: Traefik ingress hosts, NodePort `30000`/`30400`, `litellm`/`langfuse` namespaces.

When `hom-lab-ctl-k3s-01` API blocked: record **blocked — hvh-01 gateway down**; do not omit catalog rows.

## HTTP/TCP probes

```bash
curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 http://litellm.hom.lab:30400/health
nc -z -G 3 192.168.50.158 30400
```

Save to `endpoint-probes.txt`. Classify: `REACHABLE`, `UNREACHABLE`, `DNS_FAIL`, `BLOCKED_UPSTREAM`.

## Artifact files this subskill produces

```text
artifacts/troubleshooting/dns-investigation/<timestamp>/
├── repo-endpoints.txt
├── k8s-endpoints.txt
├── endpoint-probes.txt
└── published-endpoints.md
```

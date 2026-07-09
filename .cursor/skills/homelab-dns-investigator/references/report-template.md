# DNS and Connection Investigation Report

**Generated:** {{timestamp}}
**Investigator:** homelab-dns-investigator
**Artifact dir:** {{artifact_dir}}

## Executive summary

{{one_paragraph_assessment}}

## Scope

- Hosts/names checked: {{host_list}}
- Lanes: hvh-01 (`192.168.138.0/24`), hvh-02 (`192.168.137.0/24`)
- Suffixes: bare, `.hom.lab`, `.local`, `.lab`

## Lane inventory truth

Per-lane declared map (repo) + live verification. Example: [examples/lane-inventory-truth-example.md](../examples/lane-inventory-truth-example.md).

### hvh-01 (storage / control)

| Name | IP | Role |
|---|---|---|
| {{declared rows from inventory}} |

**Port proxies:** {{from guest_published_tcp_ports}}

### Reconciliation

| Name | Declared | Verified | Status | Evidence |
|---|---|---|---|---|
| {{rows}} |

Raw: `lane-inventory-truth-hvh-01.txt`

### hvh-02 (GPU)

{{same pattern or link}}

## DNS resolution matrix

{{dns_matrix_table_or_link}}

Raw output: `dns-matrix.txt`

## Connection evidence

### Routes and gateways

| Target IP | Gateway | Interface | Status |
|---|---|---|---|
| {{rows}} |

### Ping / SSH / API

| Target | Ping | SSH | Port 6443 (if K3s) | Notes |
|---|---|---|---|---|
| {{rows}} |

Raw output: `connection-probes.txt`

## Hosts file vs router DNS vs mDNS

| Name | Router DNS | Mac resolver | `/etc/hosts` | Mismatch |
|---|---|---|---|---|
| {{rows}} |

## Published endpoints (subskill)

Invoked: `homelab-dns-investigator/subskills/published-endpoints`

{{endpoints_summary_or_link}}

Detail: `published-endpoints.md`

## Assessment

{{evidence_based_findings}}

## Next required step

{{single_action_from_evidence_only}}

## Sources checked

- `inventory/host_vars/`
- `inventory/group_vars/all/homelab_hosts_file.yml`
- `inventory/group_vars/all/homelab_router_gt6.yml`
- `/etc/hosts` (mac-dev)
- `~/.ssh/config`
- Kubernetes (when contexts reachable): ingress, services, endpoints

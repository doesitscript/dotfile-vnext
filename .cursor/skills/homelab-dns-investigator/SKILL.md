---
name: homelab-dns-investigator
description: Investigate homelab DNS name resolution and connection reachability from mac-dev — router DNS, /etc/hosts, mDNS, guest subnet routes, gateway health, and evidence reports. Use when names fail to resolve, hom.lab or .local lookups disagree, guest subnets time out, or connectivity needs a structured audit. Invokes published-endpoints subskill for service URL inventory.
---

# Homelab DNS and Connection Investigator

Evidence-first DNS and connection audit from `mac-dev`. Always ends with a saved report.

## When to use

- Name does not resolve (`hom.lab`, `.local`, `.lab`, bare)
- Resolved IP disagrees across router DNS, `/etc/hosts`, and mDNS
- Guest subnet `192.168.138.x` or `192.168.137.x` unreachable
- Service hostname works but HTTP/API fails — invoke published-endpoints subskill
- User asks for DNS audit, connectivity investigation, or name/connection report

Not for: k9s UI (`homelab-k9s`), Ansible changes (`ansible-knowledge-gate`).

## Authority

| Topic | SSOT |
|---|---|
| Hosts / IPs | `inventory/host_vars/`, `inventory/hosts_mapping.yaml` |
| `/etc/hosts` catalog | `inventory/group_vars/all/homelab_hosts_file.yml` |
| Router DNS | `inventory/group_vars/all/homelab_router_gt6.yml` |
| SSH aliases | `~/.ssh/config` |
| Service URL catalog | `docs/reference/service-entrypoints-and-ai-surfaces.md` |
| Connection paths | [references/connection-paths.md](references/connection-paths.md) |

## Investigation workflow

Copy and track:

```text
[ ] 1. Open artifact directory
[ ] 2. Collect DNS matrix
[ ] 3. Collect connection probes
[ ] 4. Compare hosts vs DNS layers
[ ] 5. Invoke published-endpoints subskill
[ ] 6. Write report from template
```

### Step 1 — Artifact directory

```text
artifacts/troubleshooting/dns-investigation/<YYYYMMDD-HHMMSS>/
```

Create the directory at investigation start. All raw output lands here.

### Step 2 — DNS matrix

Run (pass artifact dir as first argument to capture output):

```bash
.cursor/skills/homelab-dns-investigator/scripts/probe_name_resolution.sh \
  artifacts/troubleshooting/dns-investigation/<timestamp>/
```

Cross-check against [references/dns-and-hosts.md](references/dns-and-hosts.md) and inventory `host_ip` / `ansible_host`.

### Step 3 — Connection probes

For each relevant IP (hypervisor LAN, guest, service):

- `route -n get <ip>`
- `ping -c 2 -W 2000 <ip>`
- `nc -z -G 3 <ip> <port>` for K3s `6443` or catalog ports
- SSH probe via repo alias when applicable

Save combined stdout to `connection-probes.txt`. Do not assume cause — paste raw output.

Known patterns: [references/dns-and-hosts.md](references/dns-and-hosts.md), [references/connection-paths.md](references/connection-paths.md).

### Step 4 — Hosts vs DNS layers

For each name in scope, record:

| Layer | Command / source |
|---|---|
| Router DNS | `dig +short <fqdn> @192.168.50.1` |
| Mac resolver | `dscacheutil -q host -a name <fqdn>` |
| `/etc/hosts` | `grep <name> /etc/hosts` |
| Inventory | `inventory/host_vars/<host>.yaml` |

Flag mismatches (e.g. hvh-02 `.158` inventory vs `.159` mDNS).

### Step 5 — Published endpoints subskill

Read and execute:

```text
.cursor/skills/homelab-dns-investigator/subskills/published-endpoints/SKILL.md
```

Pass the same artifact directory. Merge `published-endpoints.md` into the final report.

### Step 6 — Write report (required)

1. Copy [references/report-template.md](references/report-template.md) → `report.md` in the artifact dir.
2. Fill every section from collected evidence only — no inference without pasted output.
3. Link raw files: `dns-matrix.txt`, `connection-probes.txt`, `published-endpoints.md`, `k8s-endpoints.txt` (if collected).
4. End with one evidence-based assessment and one next required step.

Optionally mirror summary to `docs/lessons-learned/` when the user wants durable notes.

## Output rules

- Paste raw command output in the report or reference artifact files by path.
- Do not guess reboot, firewall, or DNS typo without evidence.
- If a layer was not checked, list it under **Missing evidence**.

## Subskills

| Subskill | Path | Purpose |
|---|---|---|
| published-endpoints | [subskills/published-endpoints/SKILL.md](subskills/published-endpoints/SKILL.md) | Repo catalog + live Kubernetes services/ingress |

## References

- [references/dns-and-hosts.md](references/dns-and-hosts.md)
- [references/connection-paths.md](references/connection-paths.md)
- [references/report-template.md](references/report-template.md)
- [scripts/probe_name_resolution.sh](scripts/probe_name_resolution.sh)

## Examples

- [examples/what-to-collect.md](examples/what-to-collect.md) — Mac resolver, hypervisor/guest suffix matrices, connection probes, legacy names
- [examples/report-output-example.md](examples/report-output-example.md) — filled `report.md` from a real investigation run

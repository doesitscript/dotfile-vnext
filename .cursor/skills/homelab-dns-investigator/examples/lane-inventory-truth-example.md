# Lane inventory truth — example output

**Skill:** `homelab-dns-investigator`  
**Report section:** `## Lane inventory truth` (before DNS matrix)  
**Purpose:** Declare what the repo says the lane *should* be, then validate against live deployment.

---

## hvh-01 lane — inventory truth (example)

| Name | IP | Role |
|---|---|---|
| `hom-lab-ctl-hvh-01` | `192.168.50.234` | Hyper-V host (primary) |
| `hom-lab-ctl-hvh-01` | `192.168.50.233` | Secondary Wi‑Fi adapter (inventory: temporarily down) |
| `hom-lab-ctl-dkr-01` / `nsrv-dkr-01` | `192.168.138.10` | Docker VM |
| `hom-lab-ctl-k3s-01` / `nsrv-k3s-01` | `192.168.138.11` | K3s control plane |
| Guest subnet | `192.168.138.0/24` | Gateway `192.168.138.1` on hvh-01 |

**Port proxies** on `192.168.50.234` → `192.168.138.10`:

| listen | → backend | service |
|---|---|---|
| `:5432` | `138.10:5432` | postgres-fuzlang |
| `:6379` | `138.10:6379` | redis-fuzlang |
| `:8123` | `138.10:8123` | clickhouse-http |
| `:9004` | `138.10:9004` | clickhouse-native |
| `:9000` | `138.10:9000` | minio-api |
| `:9001` | `138.10:9001` | minio-console |

---

## Validation sources

Every row must cite **Declared (repo)** and **Verified (live)**. Do not mark verified without probe output.

### Declared — dotfile-vnext (read before probing)

| Row / concept | Repo source | Field or section |
|---|---|---|
| hvh-01 primary LAN IP | `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | `host_ip`, `ansible_host` |
| hvh-01 secondary adapter | `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | header comments (`192.168.50.233`, temporarily down) |
| hvh-01 naming layers | `inventory/hosts_mapping.yaml` | `physical_nodes.hom-lab-ctl-hvh-01` |
| Registry canonical row | `docs/reference/naming-standards/live-object-registry.yml` | `live_hosts.hom-lab-ctl-hvh-01`, `hom-lab-ctl-dkr-01`, `hom-lab-ctl-k3s-01` |
| Guest subnet + gateway | `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | `hyperv_config.guest_subnet_ipv4`, `guest_gateway_ipv4` |
| dkr-01 / k3s-01 guest IPs | `inventory/host_vars/hom-lab-ctl-dkr-01.yaml`, `hom-lab-ctl-k3s-01.yaml` | `ansible_host` |
| Guest OS hostnames | `live-object-registry.yml` | `os_hostname`, `hyperv_vm_name` (`nsrv-dkr-01`, `nsrv-k3s-01`) |
| Portproxy catalog | `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | `hyperv_config.guest_published_tcp_ports` |
| mac-dev route to guest subnet | `inventory/host_vars/mac-dev.yaml` | `hyperv_guest_route_mac_routes` → `138.0/24` via `50.234` |
| SSH jump path to guests | `inventory/hosts_mapping.yaml` | `ssh_proxy_jump_host: hom-lab-ctl-hvh-01` |

### Verified — live deployment (collect during investigation)

| Row / concept | Live probe | Pass criteria |
|---|---|---|
| Primary hvh-01 reachable | `ping 192.168.50.234`, SSH `hom-lab-ctl-hvh-01` | reply / shell |
| Secondary adapter | `ping 192.168.50.233` | OK or documented down |
| Guest subnet route (mac-dev) | `route -n get 192.168.138.11` | gateway `192.168.50.234` |
| dkr-01 guest | `ping 192.168.138.10`, SSH via jump | reply / shell |
| k3s-01 guest + API | `ping 192.168.138.11`, `nc -z -G 3 192.168.138.11 6443` | open when lane up |
| Guest gateway on host | SSH PowerShell on hvh-01: guest switch / `192.168.138.1` interface | matches declared gateway |
| Portproxy rules | SSH PowerShell: `netsh interface portproxy show all` | rows match `guest_published_tcp_ports` |
| Hyper-V VMs running | SSH PowerShell: `Get-VM nsrv-dkr-01, nsrv-k3s-01` | State Running (when lane up) |
| DNS for hvh host | `dig +short hom-lab-ctl-hvh-01.hom.lab @192.168.50.1` | `192.168.50.234` |

Save raw output to `lane-inventory-truth-hvh-01.txt`.

### Reconciliation row (required in report)

| Name | Declared IP | Verified | Status |
|---|---|---|---|
| `hom-lab-ctl-hvh-01` | `192.168.50.234` | ping fail / SSH timeout | **DOWN** — blocks entire lane |
| `hom-lab-ctl-k3s-01` | `192.168.138.11` | route via `50.234`, guest timeout | **BLOCKED_UPSTREAM** |
| postgres portproxy | `50.234:5432` → `138.10:5432` | not probed (gateway down) | **BLOCKED_UPSTREAM** |

Status values: `MATCH`, `MISMATCH`, `DOWN`, `BLOCKED_UPSTREAM`, `NOT_PROBED`.

---

## hvh-02 lane

Same pattern — see [lane-inventory-truth-hvh-02.md](../references/lane-inventory-truth-hvh-02.md). Investigator runs both lanes when scope is full homelab audit.

---

## How this fits the report

```markdown
## Lane inventory truth

### hvh-01 (storage / control)
<table from Declared section>

### Validation
<reconciliation table with evidence paths>

### hvh-02 (GPU)
<abbreviated or link to second lane file>
```

Then continue to DNS matrix (suffix resolution) and published-endpoints subskill (service URLs on top of this map).

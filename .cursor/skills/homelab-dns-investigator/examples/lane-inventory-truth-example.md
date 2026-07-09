# Lane inventory truth — example output

**Skill:** `homelab-dns-investigator`  
**Report section:** `## Lane inventory truth` (before DNS matrix)  
**Purpose:** Declare what the repo says the lane *should* be, then validate against live deployment.

LAN IP and portproxy rules: [inventory-lan-ip-sources.md](../references/inventory-lan-ip-sources.md)

---

## hvh-01 lane — inventory truth (example)

### Hypervisor and guests

| inventory_hostname | hyperv_vm_hostname | IP | Role |
|---|---|---|---|
| `HOM-LAB-HVH-01` | — | `192.168.50.234` | Hyper-V host (primary LAN) |
| `HOM-LAB-HVH-01` | — | `192.168.50.233` | Secondary Wi‑Fi (inventory: temporarily down) |
| `hom-lab-ctl-dkr-01` | `nsrv-dkr-01` | `192.168.138.10` | Docker VM |
| `hom-lab-ctl-k3s-01` | `nsrv-k3s-01` | `192.168.138.11` | K3s control plane |
| Guest subnet | — | `192.168.138.0/24` | Gateway `192.168.138.1` on hvh-01 |

**VM identity (declared on hypervisor host_vars):**

```yaml
# inventory/host_vars/HOM-LAB-HVH-01.yaml
hyperv_ubuntu_docker_vm_hostname: "nsrv-dkr-01"
hyperv_ubuntu_docker_vm_inventory_host: "hom-lab-ctl-dkr-01"
hyperv_ubuntu_k3s_vm_hostname: "nsrv-k3s-01"
hyperv_ubuntu_k3s_vm_inventory_host: "hom-lab-ctl-k3s-01"
```

### Port proxies — each list item (`guest_published_tcp_ports`)

Source: `inventory/host_vars/HOM-LAB-HVH-01.yaml` → `hyperv_config.guest_published_tcp_ports`

```yaml
    - name: "postgres-fuzlang"
      listen_address: "192.168.50.234"
      listen_port: 5432
      connect_address: "192.168.138.10"
      connect_port: 5432
    - name: "redis-fuzlang"
      listen_address: "192.168.50.234"
      listen_port: 6379
      connect_address: "192.168.138.10"
      connect_port: 6379
    - name: "clickhouse-http"
      listen_address: "192.168.50.234"
      listen_port: 8123
      connect_address: "192.168.138.10"
      connect_port: 8123
    - name: "clickhouse-native"
      listen_address: "192.168.50.234"
      listen_port: 9004
      connect_address: "192.168.138.10"
      connect_port: 9004
    - name: "minio-api"
      listen_address: "192.168.50.234"
      listen_port: 9000
      connect_address: "192.168.138.10"
      connect_port: 9000
    - name: "minio-console"
      listen_address: "192.168.50.234"
      listen_port: 9001
      connect_address: "192.168.138.10"
      connect_port: 9001
```

---

## hvh-02 lane — inventory truth (example)

### Hypervisor and guests

| inventory_hostname | hyperv_vm_hostname | IP | Role |
|---|---|---|---|
| `HOM-LAB-HVH-02` | — | `192.168.50.158` | Hyper-V host (primary LAN) |
| `HOM-LAB-HVH-02-ipv6` | — | `fdfa:7038:521c:...` | IPv6 SSH surface |
| `hom-lab-ctl-dkr-02` | `hom-lab-ctl-dkr-02` | `192.168.137.10` | Docker VM |
| `hom-lab-ctl-k3s-02` | `hom-lab-ctl-k3s-02` | `192.168.137.11` | K3s GPU runtime |
| Guest subnet | — | `192.168.137.0/24` | Gateway `192.168.137.1` on hvh-02 |

**VM identity (declared on hypervisor host_vars):**

```yaml
# inventory/host_vars/HOM-LAB-HVH-02.yaml
hyperv_ubuntu_docker_vm_hostname: "hom-lab-ctl-dkr-02"
hyperv_ubuntu_docker_vm_inventory_host: "hom-lab-ctl-dkr-02"
hyperv_ubuntu_k3s_vm_hostname: "hom-lab-ctl-k3s-02"
hyperv_ubuntu_k3s_vm_inventory_host: "hom-lab-ctl-k3s-02"
```

Note: hvh-02 uses **aligned** inventory and Hyper-V names; hvh-01 still uses legacy guest OS names (`nsrv-*`) with compact inventory aliases (`hom-lab-ctl-*`).

### Port proxies — each list item

Source: `inventory/host_vars/HOM-LAB-HVH-02.yaml` → `hyperv_config.guest_published_tcp_ports`

```yaml
    - name: "loki"
      listen_address: "192.168.50.158"
      listen_port: 3100
      connect_address: "192.168.137.10"
      connect_port: 3100
    - name: "netbox"
      listen_address: "192.168.50.158"
      listen_port: 8000
      connect_address: "192.168.137.10"
      connect_port: 8000
    - name: "semaphore"
      listen_address: "192.168.50.158"
      listen_port: 3001
      connect_address: "192.168.137.10"
      connect_port: 3001
    - name: "k3s-traefik-http"
      listen_address: "192.168.50.158"
      listen_port: 80
      connect_address: "192.168.137.11"
      connect_port: 31461
    - name: "langfuse-k3s"
      listen_address: "192.168.50.158"
      listen_port: 30000
      connect_address: "192.168.137.11"
      connect_port: 30000
    - name: "litellm-k3s"
      listen_address: "192.168.50.158"
      listen_port: 30400
      connect_address: "192.168.137.11"
      connect_port: 30400
```

---

## Validation sources

Every row must cite **Declared (repo)** and **Verified (live)**. Do not mark verified without probe output.

### Declared — dotfile-vnext (full LAN sweep, not one file)

| Row / concept | Repo source | Field or section |
|---|---|---|
| **All LAN IPs** | [inventory-lan-ip-sources.md](../references/inventory-lan-ip-sources.md) | sweep `host_vars/*`, `hosts_mapping.yaml`, `live-object-registry.yml` |
| Hypervisor primary/alt LAN | `hosts_mapping.yaml` `physical_nodes`, each hvh `host_vars` | `host_ip`, `ansible_host`, comments, `ip_address_original` |
| IPv6 management surface | `HOM-LAB-HVH-02.yaml`, `HOM-LAB-HVH-02-ipv6.yaml` | `host_ipv6`, `ansible_host` |
| Guest VM IPs | guest `host_vars` + hypervisor `hyperv_ubuntu_*_vm_autoinstall_network_ipv4` | `ansible_host`, `host_ip` |
| Guest VM identity triple | hypervisor `host_vars` | `hyperv_ubuntu_docker_vm_*`, `hyperv_ubuntu_k3s_vm_*` |
| Guest subnet + gateway | hypervisor `hyperv_config` | `guest_subnet_ipv4`, `guest_gateway_ipv4` |
| **Each portproxy** | hypervisor `hyperv_config.guest_published_tcp_ports[]` | `name`, `listen_address`, `listen_port`, `connect_address`, `connect_port` |
| mac-dev guest routes | `inventory/host_vars/mac-dev.yaml` | `hyperv_guest_route_mac_routes` |
| Service hosts IPs (DNS layer) | `homelab_hosts_file.yml` | `hosts_ip` on web catalog rows — used in DNS step, not host management |
| Registry canonical | `live-object-registry.yml` | `live_hosts.*` |

### Verified — live deployment

| Row / concept | Live probe | Pass criteria |
|---|---|---|
| Each declared LAN IP | `ping`, SSH per `~/.ssh/config` alias | reply / shell |
| Hypervisor all adapters | PowerShell `Get-NetIPAddress -AddressFamily IPv4` | includes declared primary; note undeclared (e.g. `.159`) |
| Guest subnet route (mac-dev) | `route -n get <guest-ip>` | gateway = hypervisor `host_ip` |
| Guest VM | `ping` / SSH jump to `inventory_hostname` | matches `ansible_host` |
| K3s API | `nc -z -G 3 <guest-ip> 6443` | open when lane up |
| **Each portproxy item** | `netsh interface portproxy show all` + `nc` on `listen_address:listen_port` | row matches YAML; TCP open when backend healthy |
| Hyper-V VM name | `Get-VM <hyperv_ubuntu_*_vm_hostname>` | State Running |
| Router DNS for hvh | `dig +short <name>.hom.lab @192.168.50.1` | matches primary LAN when seeded |

Save raw output to `lane-inventory-truth-hvh-01.txt` / `lane-inventory-truth-hvh-02.txt`.

### Reconciliation (required) — per portproxy item example

| name | declared listen → connect | verified | status |
|---|---|---|---|
| `loki` | `50.158:3100` → `137.10:3100` | nc OK on listen; backend OK | MATCH |
| `postgres-fuzlang` | `50.234:5432` → `138.10:5432` | not probed (hvh-01 down) | BLOCKED_UPSTREAM |
| `HOM-LAB-HVH-01` | `192.168.50.234` | ping/SSH fail | DOWN |

Status: `MATCH`, `MISMATCH`, `DOWN`, `BLOCKED_UPSTREAM`, `NOT_PROBED`.

---

## How this fits the report

```markdown
## Lane inventory truth

### LAN IP sweep
<link to inventory matrix + reconciliation>

### hvh-01 — guests + portproxy items
<full tables + YAML-level portproxy list>

### hvh-02 — guests + portproxy items
<full tables + YAML-level portproxy list>

### Validation
<per-item reconciliation>
```

Then DNS matrix and `homelab-published-endpoints` subskill (HTTP `verify_url` on top of portproxy listen rows).

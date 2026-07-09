# Inventory LAN IP sources — validation sweep

Use when building **lane inventory truth**. LAN IPs are scattered across inventory — never read only one `host_vars` file.

## Sweep order (declared)

1. **`inventory/hosts_mapping.yaml`**
   - `physical_nodes.*.ip_address`, `ip_address_original`, `ipv6_address`
   - `ansible_surfaces.*.host_ip`, `ansible_connect_target`, `connect_target_kind`
2. **`inventory/host_vars/*.yaml`** — per host:
   - `host_ip`, `ansible_host`, `host_ipv6`
   - `hyperv_config.guest_published_tcp_ports[].listen_address` / `connect_address`
   - `hyperv_ubuntu_*_vm_autoinstall_network_ipv4` (guest static IP on hypervisor host_vars)
3. **`docs/reference/naming-standards/live-object-registry.yml`**
   - `live_hosts.*.primary_lan_ip`, `guest_ip`, `ansible_connect_target`
4. **`inventory/group_vars/all/homelab_hosts_file.yml`**
   - `homelab_hosts_file_lan_publish_ip`, `homelab_hosts_file_dkr_guest_ip`
   - `homelab_hosts_file_web_catalog[].hosts_ip` (service resolution IPs — not host management)
5. **`inventory/host_vars/mac-dev.yaml`**
   - `hyperv_guest_route_mac_routes[].gateway` (which LAN IP is the guest-subnet next hop)

## Homelab LAN IP matrix (current inventory)

| inventory_hostname | IP / target | kind | primary host_vars |
|---|---|---|---|
| `hom-lab-ctl-hvh-01` | `192.168.50.234` | primary LAN | `hom-lab-ctl-hvh-01.yaml` |
| `hom-lab-ctl-hvh-01` | `192.168.50.233` | secondary adapter (comment: down) | header comments + `hosts_mapping` `ip_address_original` |
| `hom-lab-ctl-hvh-02` | `192.168.50.158` | primary LAN | `hom-lab-ctl-hvh-02.yaml` |
| `hom-lab-ctl-hvh-02` | `fdfa:7038:521c:a5fa:7c9:f4a1:90b8:1b1e` | IPv6 SSH surface | `hom-lab-ctl-hvh-02.yaml` `host_ipv6`, `hom-lab-ctl-hvh-02-ipv6.yaml` |
| `hom-lab-ctl-dkr-01` | `192.168.138.10` | guest | `hom-lab-ctl-dkr-01.yaml` |
| `hom-lab-ctl-k3s-01` | `192.168.138.11` | guest | `hom-lab-ctl-k3s-01.yaml` |
| `hom-lab-ctl-dkr-02` | `192.168.137.10` | guest | `hom-lab-ctl-dkr-02.yaml` |
| `hom-lab-ctl-k3s-02` | `192.168.137.11` | guest | `hom-lab-ctl-k3s-02.yaml` |
| `mac-dev` | controller LAN | operator | `mac-dev.yaml` |
| `dev-workstation-win` | `192.168.50.132` | deferred | `dev-workstation-win.yaml` |

**Not inventory LAN rows:** mDNS discoveries (e.g. `192.168.50.159` for `.local`) — live-only; compare to declared, do not treat as SSOT.

## Guest VM identity (three names)

Each Hyper-V guest has three names in inventory. Read from **hypervisor** `host_vars`:

| field | meaning | hvh-01 example | hvh-02 example |
|---|---|---|---|
| `hyperv_ubuntu_docker_vm_inventory_host` | Ansible inventory hostname | `hom-lab-ctl-dkr-01` | `hom-lab-ctl-dkr-02` |
| `hyperv_ubuntu_docker_vm_hostname` | Hyper-V VM / guest OS name | `nsrv-dkr-01` | `hom-lab-ctl-dkr-02` |
| `hyperv_ubuntu_vm_autoinstall_network_ipv4` | guest IP | `192.168.138.10` | `192.168.137.10` |

K3s VM uses parallel fields: `hyperv_ubuntu_k3s_vm_inventory_host`, `hyperv_ubuntu_k3s_vm_hostname`, `hyperv_ubuntu_k3s_vm_autoinstall_network_ipv4`.

**Live validation:** `Get-VM <hyperv_ubuntu_*_vm_hostname>` on hypervisor; SSH uses `inventory_host` from guest `host_vars`.

## Portproxy items — one row per list entry

Do not summarize portproxy as a compressed table only. Each `guest_published_tcp_ports` list item is one declared endpoint at this YAML level:

```yaml
    - name: "loki"
      listen_address: "192.168.50.158"
      listen_port: 3100
      connect_address: "192.168.137.10"
      connect_port: 3100
```

**Source file:** `inventory/host_vars/<hypervisor>.yaml` → `hyperv_config.guest_published_tcp_ports`

**Live validation:** `netsh interface portproxy show all` on that hypervisor — match `listen_address:listen_port` → `connect_address:connect_port` per item.

## Live sweep (mac-dev + hypervisor SSH)

| declared row | probe |
|---|---|
| each `host_ip` / `ansible_host` | `ping`, SSH alias from `~/.ssh/config` |
| each `listen_address:listen_port` | `nc -z -G 3 <listen_address> <listen_port>` |
| each `connect_address:connect_port` | only when hypervisor up and guest route works |
| guest subnet | `route -n get <guest ansible_host>` |
| all LAN IPs on one host | PowerShell `Get-NetIPAddress -AddressFamily IPv4` on hypervisor |

Save combined output to `lane-inventory-truth-<lane>.txt`.

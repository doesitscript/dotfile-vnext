# What to collect — homelab-dns-investigator

Concrete example of evidence the investigator gathers before writing `report.md`.

## Mac resolver baseline

Record once per investigation:

```text
Search domain: hom.lab (bare names often become name.hom.lab)
Router DNS: 192.168.50.1
/etc/hosts: only hvh-02 lane + *.hom.lab services (no hvh-01 entries)
```

Sources: `scutil --dns`, `grep hom.lab /etc/hosts`, `inventory/group_vars/all/homelab_hosts_file.yml`

## Hyper-V hosts — suffix matrix

| Name | `.hom.lab` (router) | bare (search → `.hom.lab`) | `.local` (mDNS) | `.lab` |
|---|---|---|---|---|
| `HOM-LAB-HVH-01` | `192.168.50.234` | `192.168.50.234` | none | none |
| `HOM-LAB-HVH-02` | `192.168.50.158` | `192.168.50.158` | `192.168.50.159` | none |

Commands per cell: `dig +short <fqdn> @192.168.50.1`, `dscacheutil -q host -a name <fqdn>`, `dns-sd -G v4 <name>.local`

## Connection probes — hypervisor mismatch example

When DNS layers disagree, probe **both** IPs:

```text
Important mismatch: HOM-LAB-HVH-02.local → 192.168.50.159, not inventory 192.168.50.158.

Evidence:
- 192.168.50.159 — ping OK, SSH port 22 open, hostname HOM-LAB-HVH-02
- 192.168.50.158 — ping OK, but SSH connection refused on IPv4
```

Assessment: `.local` is a working alternate path to hvh-02 (likely second adapter). Inventory/SSH config still target `.158`.

```text
HOM-LAB-HVH-01 has no .local record — only .hom.lab via router DNS. Host is still down at 50.234.
```

Save raw ping/SSH/nc output to `connection-probes.txt`.

## Guest VMs — inventory names

| Name | router DNS | `/etc/hosts` | `.hom.lab` | `.local` | `.lab` |
|---|---|---|---|---|---|
| `hom-lab-ctl-k3s-01` | none | missing | none | none | none |
| `hom-lab-ctl-k3s-02` | none | `192.168.137.11` | none | none | none |
| `hom-lab-ctl-dkr-01` | none | missing | none | none | none |
| `hom-lab-ctl-dkr-02` | none | `192.168.137.10` | none | none | none |
| `nsrv-k3s-01` / `nsrv-dkr-01` | none | none | none | none | none |

Note: guest names resolve only when `/etc/hosts` has them (k3s-02/dkr-02 only) or via IP. No DNS for any suffix on k3s-01/dkr-01.

Also collect routes:

```text
route -n get 192.168.138.11   # expect gateway 192.168.50.234
route -n get 192.168.137.11   # expect gateway 192.168.50.158
nc -z -G 3 192.168.138.11 6443
nc -z -G 3 192.168.137.11 6443
```

## Legacy names — expected dead

| Name | all suffixes |
|---|---|
| `network-server` | no resolution |
| `ai-net-server-mgmt` | no resolution |

Retired per inventory — record as **confirmed dead**, not missing DNS bug.

## Artifact files this step produces

```text
artifacts/troubleshooting/dns-investigation/<timestamp>/
├── dns-matrix.txt              # probe_name_resolution.sh
├── connection-probes.txt       # ping, ssh, nc, route
└── hosts-dns-comparison.txt    # dig + dscacheutil + grep /etc/hosts
```

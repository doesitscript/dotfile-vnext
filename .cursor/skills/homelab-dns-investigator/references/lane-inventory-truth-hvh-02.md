# Lane inventory truth — hvh-02 (reference)

Full dual-lane example: [lane-inventory-truth-example.md](../examples/lane-inventory-truth-example.md)  
LAN IP sweep: [inventory-lan-ip-sources.md](inventory-lan-ip-sources.md)

hvh-02 portproxy and VM identity blocks are canonical in the main example file. This page is a short index for the GPU lane only.

## Quick declared rows

| inventory_hostname | hyperv_vm_hostname | IP |
|---|---|---|
| `hom-lab-ctl-hvh-02` | — | `192.168.50.158` |
| `hom-lab-ctl-dkr-02` | `hom-lab-ctl-dkr-02` | `192.168.137.10` |
| `hom-lab-ctl-k3s-02` | `hom-lab-ctl-k3s-02` | `192.168.137.11` |

## Live validation checklist

- `route -n get 192.168.137.11` → gateway `192.168.50.158`
- Each `guest_published_tcp_ports` item: `nc` on listen, `netsh interface portproxy show all`
- `Get-VM hom-lab-ctl-dkr-02`, `Get-VM hom-lab-ctl-k3s-02`
- mDNS `.159` vs inventory `.158` — live-only comparison

**HTTP/catalog layer:** `homelab-published-endpoints` subskill.

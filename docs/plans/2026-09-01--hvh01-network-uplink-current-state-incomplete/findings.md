# Findings — HVH-01 network uplink

## Purpose

Evidence for [README.md](README.md): adapter history, repo intent, and live
probes. Sources: inventory, router GT6 table, Jul/Aug 2026 plan packets,
brainstorm routing packet, live probes **2026-09-01** from `mac-dev`.

---

## Update note — 2026-09-01 (hardware / storage / memory facts)

**Details updated:** Removed comparative or assumed capacity claims (for example
that HVH-01 has “more storage and RAM” than the 5090 host). This packet now
states only **recorded facts** and **inventory role**.

| Topic | Correct statement |
| --- | --- |
| Role | **Storage lane** Hyper-V control host (`hyperv_lane_storage` / `HOM-LAB-HVH-01`) |
| vs HVH-02 | Do **not** assert more RAM, more storage, or “identical but bigger” without a dated probe |
| System RAM (total) | **Not recorded in repo** — requires live `Win32_ComputerSystem` / `Get-Volume` probe when the host is online |
| Host reachability | **Offline now** (2026-09-01 later in day) — ping/SSH probe not possible; § Live probe receipt below is **historical** from earlier the same day |

Re-probe storage and memory when the host is back and append a dated row to
§ Physical host — storage and memory.

---

## Physical host — storage and memory (factual SSOT)

Role only: **storage lane** host — SMB model/artifact roots, Hyper-V guests
`hom-lab-ctl-dkr-01` and `hom-lab-ctl-k3s-01`, storage-adjacent publish
(portproxy / Path A). Not the primary GPU / vLLM lane (that is `HOM-LAB-HVH-02`).

| Fact | Recorded value | Source | As-of |
| --- | --- | --- | --- |
| GPU | NVIDIA GeForce GTX 1060 6 GB | `inventory/host_vars/hom-lab-hvh-01.yaml`, WMI probe | 2026-07-09 |
| System RAM (total installed) | **Not recorded** | — | pending live probe |
| Hyper-V guest RAM (static) | `hom-lab-ctl-dkr-01` **8 GB**; `hom-lab-ctl-k3s-01` **8 GB** | `hom-lab-hvh-01.yaml` | inventory |
| `C:` volume | **476.15 GB** total; **279.60 GB** free | Get-Volume probe | 2026-07-29 |
| `D:` volume | **952.92 GB** total; **842.49 GB** free | Get-Volume probe | 2026-07-29 |
| `F:` volume (`data` label) | **~487 GB** free (total size not captured in same probe row) | Get-Volume probe | 2026-07-29 |
| Managed data / share roots | `F:\ProgramData\Ansible`, `F:\shares\public\...` | `hyperv_lane_storage`, host_vars | inventory |
| Canonical HF weights path | `F:\shares\public\models\huggingface` | D-4 / host_vars | inventory |
| Backup target disk | `E:` (`windows_server_backup_target_drive`) | `hyperv_lane_storage` | inventory |

**Prohibited in new prose:** “more RAM than HVH-02”, “more storage than the
5090 server”, “high_capacity vs the GPU host”, or any capacity comparison unless
a dated probe table for **both** hosts is attached.

---

## TP-Link Wi-Fi 6 driver — 2026-09-01 probe

| Check | Result |
| --- | --- |
| OS | Windows Server 2025 Standard Evaluation, build **26100** |
| Manual folder | `C:\Temp\Windows_11_64bit` — **complete** (inf, sys, dll, dat, cat) |
| Ansible staging | `F:\shares\public\driver-staging\tplink-wifi6-mediatek` — same five files |
| Admin share | `\\HOM-LAB-HVH-01\C$\Temp\Windows_11_64bit` (Windows LAN); macOS needs SMB mount or use SSH |
| Driver store | Signed **oem2.inf** / mtkwl6ex **0.34.2.886** (WHCP) — installs without Server INF patch |
| `pnputil /add-driver` | **Success** — bound to both PCI 7922 instances |
| PCIe present | **No** — both `VEN_14C3&DEV_7922` report `IsPresent=false`, PnP problem **45** |
| Live LAN | **Broadcom 802.11ac** (`Wi-Fi 2`, `.234`) — not TP-Link |
| Hyper-V External | Switch name still targets **TP-Link Wi-Fi 6 PCIe Adapter** while hardware absent |

**Conclusion:** Win11 driver package is fine on Server 2025 when complete and signed.
Device Manager error code 10/45 here is **PCIe hardware not detected** (phantom /
stale slot entries at bus 6 and bus 7), not “wrong OS folder”. Operator: reseat
card, reboot, remove ghost `#2`/`#3` adapters if needed, then
`pnputil /scan-devices`. Rebind Hyper-V External after a working TP-Link MAC appears.

**Operator decision (2026-09-01):** Defer TP-Link PCIe. Commission **onboard
Broadcom** (`Wi-Fi 2`, `B8:86:87:F7:C8:6F`) as HVH-01 `hyperv_config` External
switch uplink via inventory — same `configure_hyperv_windows_hosts.yaml` as
HVH-02, `--limit HOM-LAB-HVH-01` only. HVH-02 unchanged.

**VM naming cleanup (2026-09-01):** Retired duplicate Hyper-V VM `nsrv-k3s-01`
(Off; superseded by `hom-lab-ctl-k3s-01`) removed one-off from HVH-01. Live
guests now: `nsrv-dkr-01` (Docker, legacy Hyper-V name) + `hom-lab-ctl-k3s-01`
(K3s). **Follow-up:** rename Docker VM `nsrv-dkr-01` → `hom-lab-ctl-dkr-01` via
`align_legacy_vm_identity` (see `hom-lab-hvh-01.yaml` TODO).

---

| Item | Detail | Source |
| --- | --- | --- |
| Motherboard | ASUS ROG STRIX X570-E GAMING WIFI II | `docs/lessons-learned/hyper-v-ubuntu-gpu/E19182_ROG_STRIX_X570-E_GAMING_WIFI_II_V2_UM_WEB.md` |
| Onboard wireless | Wi‑Fi 6E module (board spec); live OS names it **Broadcom 802.11ac** | Board manual + live probe |
| Wired LAN | Realtek 2.5Gb + Intel 1Gb (board spec) | Board manual |
| Added NIC (commissioned) | **TP-Link Wi-Fi 6 PCIe Adapter** | `inventory/host_vars/hom-lab-hvh-01.yaml` `hyperv_config` |

**Ethernet:** Present on the board but **never selected** in `hyperv_config` or
inventory as the Hyper-V External uplink for HVH-01.

---

## Adapter timeline (repo + router)

| MAC | IP (modeled) | Role | Status |
| --- | --- | --- | --- |
| `9C:C7:D3:10:68:5A` | `192.168.50.233` | Legacy onboard / `AI-NET-SERVER` | Stale GT6 row — delete per Flint/static-IP plan |
| `B8:86:87:F7:C8:6F` | `192.168.50.234` | **Current router reservation** `HOM-LAB-HVH-01` | Live on **Broadcom `Wi-Fi 2`** (2026-09-01) |
| TP-Link PCIe (vendor ID in PnP) | — (bound to External switch) | Intended Hyper-V uplink | PnP **Unknown**; no NetAdapter (2026-09-01) |

### Inventory comment ambiguity (documented)

`hom-lab-hvh-01.yaml` header says:

- `.234` = “secondary Wi-Fi, currently active”
- `.233` = “original Wi-Fi” with onboard MAC

Repo naming treats **TP-Link PCIe as the commissioned External uplink** and
**onboard as the radio to disable** (static-IP plan Phase 0). The `.234` MAC
`B8:86:87:…` uses an **ASUS OUI**, which matches **onboard Broadcom** in
today's live probe — consistent with “TP-Link missing, onboard took the
router reservation.”

### When TP-Link was last evidenced working in repo

| Date | Evidence |
| --- | --- |
| 2026-06 (inventory-ai run) | Hyper-V preview listed `adapter_description: TP-Link Wi-Fi 6 PCIe Adapter` for HVH-01 |
| 2026-07-09 (lan-edge remediation) | After `configure_hyperv_windows_hosts`, `.234` SSH and published storage ports **recovered** — implies TP-Link + portproxy path was functional that slice |
| 2026-08 (incident packet) | Path A guest IP worked; Path B `.234` portproxy **failed** for DB — uplink IP still `.234` but publish path broken |

**Conclusion:** TP-Link **was** installed and modeled; it was the intended
Hyper-V bridge when the storage lane was commissioned. **Ethernet was not the
production uplink.** Current outage is **TP-Link absent/failed + stale External
binding + onboard carrying management**, not “wrong IP on the LAN.”

---

## Live probe receipt — 2026-09-01 (historical)

**Status later 2026-09-01:** Host **offline** — controller SSH to
`192.168.50.234` times out; do not treat this section as current reachability.
Re-run probes when power/network are restored.

### Host reachability (earlier same day)

```
HOM-LAB-HVH-01 SSH: OK (hostname HOM-LAB-HVH-01)
HOM-LAB-HVH-02 SSH: OK
ping 192.168.50.234 / .158 / .1: OK
```

### HVH-01 adapters (Ansible `win_powershell`)

| Name | Description | Status | MAC | IPv4 |
| --- | --- | --- | --- | --- |
| Wi-Fi 2 | Broadcom 802.11ac Network Adapter | Up | B8-86-87-F7-C8-6F | 192.168.50.234/24 Dhcp |
| vEthernet (External) | Hyper-V Virtual Ethernet Adapter | Up | 9C-C7-D3-10-68-5A | (none) |
| vEthernet (Guest) | Hyper-V Virtual Ethernet Adapter #2 | Up | 00-15-5D-32-E9-00 | 192.168.138.1/24 Manual |

### PnP network devices

| FriendlyName | Status |
| --- | --- |
| Broadcom 802.11ac Network Adapter | OK |
| TP-Link Wi-Fi 6 PCIe Adapter | **Unknown** |

### Hyper-V switches

| Switch | Bound physical NIC |
| --- | --- |
| External | **TP-Link Wi-Fi 6 PCIe Adapter** (not present in NetAdapter) |
| Guest | (internal) |

`bound_physical_adapter_present: false`

### Portproxy on HVH-01 (configured)

`netsh` shows rows `192.168.50.234:* → 192.168.138.10:*` for 5432, 6379,
8123, 9000, 9001, 9004. **No TCP listeners** on `.234` for those ports from
`mac-dev` (slow fail / hang on nc).

### Service matrix from `mac-dev`

**HVH-02 @ `.158` — TCP**

| Port | Service | TCP |
| ---: | --- | --- |
| 3100 | Loki | OK |
| 8000 | NetBox | OK |
| 3001 | Semaphore | OK |
| 80 | Traefik | OK |
| 30000 | Langfuse | OK |
| 30400 | LiteLLM | OK |
| 3080 | Open WebUI | OK |
| 30188 | ComfyUI | OK |

**HVH-02 HTTP smoke:** NetBox/Semaphore/Open WebUI/Loki **200**; Langfuse/LiteLLM/ComfyUI **000** (apps unhealthy).

**HVH-01 @ `.234` — TCP**

| Port | Service | TCP from mac-dev |
| ---: | --- | --- |
| 22 | SSH | OK |
| 5432–9004 | portproxy publish | **FAIL** |

**Path A:** `192.168.138.10:5432` **OK**

**Guests SSH:** `192.168.137.10`, `192.168.137.11`, `192.168.138.10`, `192.168.138.11` **OK**

### Probe commands (repeatable)

```bash
# Full port matrix (slow on failing .234 portproxy)
# See conversation 2026-09-01 probe script

bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/run_remote_command.py \
  --host HOM-LAB-HVH-01 --shell powershell --stdin-file \
  .cursor/skills/homelab-ssh-alias-connect/scripts/probe_hyperv_network_adapters.ps1
```

---

## Sources checked

| Source | Label |
| --- | --- |
| `inventory/host_vars/hom-lab-hvh-01.yaml` | hyperv_config + dual-Wi-Fi comments |
| `inventory/hosts_mapping.yaml` | `.233` original IP |
| `inventory/group_vars/all/homelab_router_gt6.yml` | DHCP rows |
| `docs/plans/2026-07-09--homelab-lan-edge-drift-remediation-incomplete/findings.md` | Jul recovery on `.234` |
| `docs/brainstorming_designs/2026-09-01--homelab-routing-layer-flint-openwrt/ansible-repo-actions-now.md` | Path A/B Aug incident |
| Live probes 2026-09-01 | This receipt |

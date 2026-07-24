# Windows desktop Wi-Fi first-hop loss vs GitHub large downloads

**Date:** 2026-07-24  
**Host:** `dev-workstation-win` (`192.168.50.133`)  
**Context:** Continue-edit lane needs host-local Ollama (`OllamaSetup.exe` ~1.46 GB from GitHub). Download appeared “hung / very slow”; investigation separated **local Wi-Fi loss**, **ASUS→AT&T gateway path**, and **GitHub CDN path**.  
**Status:** OllamaSetup download **paused** with resumeable partial kept; wait for network remediation before resume.

## Problem

A multi-GB `curl` of `OllamaSetup.exe` from GitHub to the AMD Windows desktop:

- Ran for a long time at ~100–200 KB/s
- Sometimes **stalled** (no byte growth)
- Sometimes **lost resume progress** (partial size dropped after retries)
- Low curl CPU usage looked like a hang but was mostly **network wait**

This blocked finishing `windows_ollama_runtime` install + `qwen3-coder:30b` + LiteLLM `continue-edit` E2E.

## What is *not* broken

| Claim | Evidence |
| --- | --- |
| “All HTTPS on this PC is broken” | Cloudflare 5–10 MB test on same host ~**2 MB/s** |
| “Ansible curl flags are the root cause” | Same flags work; resume/`--speed-limit` are stall detectors, not throttles |
| “`192.168.0.254` is the Hyper-V gateway” | **Operator misspeak, then corrected by probe** — HTTP UI is AT&T/ARRIS (`att_logo.png`, `ATTV6527Ys`, `/cgi-bin/index.ha`, `lighttpd`). Not present in NetBox. |
| “Packet loss is caused by the Hyper-V gateway hop” | Pathping attributes loss to **Wi-Fi link to ASUS**, not ASUS→`0.254` |

## Topology (corrected)

```text
dev-workstation-win
  NIC: Wi-Fi 2 — TP-Link Wi-Fi 6 PCIe (MediaTek)
  SSID: ASUS_5G-1  (802.11ax, ch 161, signal ~87%, PHY Tx/Rx 1201 Mbps)
  IP:   192.168.50.133/24
        │
        ▼  FIRST HOP — Wi-Fi airtime (loss measured here)
ASUS LAN gateway
  192.168.50.1
        │
        ▼  NEXT HOP — AT&T residential gateway (WAN side of ASUS)
AT&T / ARRIS gateway
  192.168.0.254
        │
        ▼  ISP upstream
AT&T  162.195… / 64.148…
        │
        ▼
Internet / GitHub release CDN (release-assets.githubusercontent.com)
```

**Ethernet** on the same PC (`Intel I219-V`) was **Disconnected** with APIPA `169.254.175.222` — not on the LAN. Prefer wiring this host for large downloads.

### Role clarification (important)

| Address | Role |
| --- | --- |
| `192.168.50.133` | Windows **desktop** `dev-workstation-win` / **DESKTOP-C1ACPUM** (RX 9060 XT **16 GB**) |
| `192.168.50.1` | **ASUS** LAN router/AP |
| `192.168.0.254` | **AT&T residential gateway (ARRIS)** — proven by management UI fingerprint; **not** Hyper-V |
| `192.168.50.234` | **HOM-LAB-HVH-01** (ASUS LAN) |
| `192.168.50.158` | **HOM-LAB-HVH-02** (ASUS LAN) |
| `192.168.137.1` | HVH-02 **guest-switch** gateway surface |
| `162.195…` etc. | **AT&T / ISP** path beyond the CPE |

Identity evidence for `192.168.0.254` (2026-07-24):

- Reachable only **via** ASUS (`tracert`: `50.1` then `0.254`); no ARP on the desktop → not L2-adjacent on `192.168.50.0/24`
- TCP **80/443/53** open
- `http://192.168.0.254/` → `302` → `/cgi-bin/index.ha`, `Server: lighttpd/1.4.69`
- UI contains `att_logo.png`, SSIDs `ATTV6527Ys`, links to `myhomenetwork.att.com`, copyright **AT&T** / **ARRIS**
- NetBox: **no** IP/prefix object for `192.168.0.254` / `192.168.0.0/24`

So the desktop path is classic **ASUS behind AT&T gateway** (double NAT / cascaded routers). A brief operator guess that `0.254` was “Hyper-V gateway” was incorrect.

## Evidence — first hop (fix this first)

Collected 2026-07-24 on `dev-workstation-win`:

| Test | Result |
| --- | --- |
| `ping -n 100 192.168.50.1` | **11% loss** (89/100); RTT 1–34 ms (avg ~5 ms); multiple timeouts |
| `pathping` → `192.168.50.1` | **14% loss on link** PC→ASUS; **0%** at ASUS node |
| Wi-Fi PHY / signal | Looks “healthy” (1201 Mbps / ~87%) — **PHY rate ≠ lossless delivery** |

**Lesson:** High Wi-Fi negotiated rate does not rule out loss. Always measure loss to the **LAN gateway**, not only signal bars or LinkSpeed.

## Evidence — hop toward AT&T gateway (`0.254`)

| Test | Result |
| --- | --- |
| `pathping` → `192.168.0.254` | ~12% loss still attributed to **first Wi-Fi link**; **0% additional** ASUS→`0.254` in that sample |
| Trace to `8.8.8.8` | `50.1` → **`0.254` (AT&T CPE)** → `162.195…` (AT&T) → … |
| Intermittent | `github.com:443` **connect timeouts** before CDN redirect (seen in curl verbose logs) |

**Lesson:** `0.254` *is* the AT&T CPE on the ASUS WAN/upstream LAN. First kill Wi-Fi loss to ASUS. Separately, optional topology cleanup is **AT&T IP passthrough / bridge** or ASUS as AP — now correctly aimed at this device, not Hyper-V.

## Evidence — destination-specific slowness

On the **same** desktop, same session:

| Destination | Approx speed |
| --- | --- |
| Cloudflare speed test | ~2 MB/s |
| GitHub `OllamaSetup` 1 MB ranged sample | ~120–280 KB/s |

**Lesson:** “Slow download” can be **path + CDN specific**. Prove with a second HTTPS origin before blaming the OS or the installer role.

## Operational pitfalls discovered while downloading

1. **Low curl CPU ≠ hung** — check whether the `.partial` file size is growing.
2. **Windows OpenSSH session teardown can kill “detached” curl** started over that SSH session — use Ansible async / true breakaway for long transfers.
3. **Stalls + `--retry` can appear to wipe progress** when resume interacts badly with redirects/timeouts — keep partials, log with `curl --stderr`, monitor size.
4. **Chocolatey for this multi-GB Setup.exe** was deprecated in-role after checksum/hang issues; durable path is `windows_artifact_download` + `win_package` (paused pending network).

## Remediation checklist

### A. First hop (desktop ↔ ASUS `192.168.50.1`) — do now

1. Plug **Ethernet** into ASUS LAN; confirm DHCP `192.168.50.x` (not `169.254`).
2. Retest: `ping -n 100 192.168.50.1` → target **~0% loss**.
3. If staying on Wi-Fi: reduce interference / distance / try another SSID; re-run ping + pathping to `192.168.50.1`.

### B. Path after ASUS (AT&T gateway at `192.168.0.254`)

1. Treat `192.168.0.254` as the **AT&T/ARRIS residential gateway** (proven by UI fingerprint).
2. Optional topology cleanup (after first-hop Wi-Fi/Ethernet is healthy):
   - AT&T gateway **IP passthrough / bridge**, ASUS sole NAT router  
   - or ASUS in **AP mode** behind the AT&T gateway  
3. Re-test `github.com:443` connect reliability and a 1 MB GitHub ranged curl.

### C. Resume Ollama work

1. Resume paused partial:  
   `C:\ProgramData\Ansible\artifacts\ollama\OllamaSetup-0.32.3.exe.partial`
2. Finish `windows_artifact_download` verify/publish → `win_package` → model pull → LiteLLM `continue-edit` verify.

## Artifacts

| Artifact | Path |
| --- | --- |
| This lesson | `docs/lessons-learned/windows-desktop-wifi-github-download/README.md` |
| Operator summary | `docs/diagnostics/dev-workstation-win--wifi-firsthop--SUMMARY.md` |
| Full Wi-Fi/net dump (host) | `C:\ProgramData\Ansible\diagnostics\wifi-firsthop\wifi-network-report-20260724-053533.txt` |
| Full dump (repo copy; large / trailing binary noise) | `docs/diagnostics/dev-workstation-win--wifi-firsthop--2026-07-24.txt` |
| Curl verbose log (host, if present) | `C:\ProgramData\Ansible\artifacts\ollama\curl-OllamaSetup-0.32.3.log` |
| Related roles | `roles/windows_artifact_download/`, `roles/windows_ollama_runtime/` |

## Correction log

- **2026-07-24 (a):** Initial notes labeled `192.168.0.254` as likely AT&T/ISP modem.
- **2026-07-24 (b):** Operator guessed Hyper-V gateway; docs temporarily followed that.
- **2026-07-24 (c):** Live probe: management UI is **AT&T/ARRIS** (`att_logo.png`, `ATTV6527Ys`, `/cgi-bin/home.ha`). Hyper-V guess withdrawn; AT&T CPE identity restored with evidence. HVH hosts remain `192.168.50.234` / `.158`.
- **Inventory:** `DESKTOP-C1ACPUM` is already online as `dev-workstation-win` in `windows_hosts` + `windows_amd_gpu_hosts` (not in `windows_hosts_offline`). NetBox has **no** device/IP object for the desktop or for `192.168.0.254` yet.

## Related skills / entry doors

- Interactive SSH: `homelab-ssh-alias-connect` (`ssh dev-workstation-win`)
- Install/mutate entry: `homelab-ansible-first-entry`
- Playbook when network is healthy: `playbooks/deploy_dev_workstation_ollama_runtime.yaml`

# Wi-Fi / first-hop diagnostics — dev-workstation-win

Collected 2026-07-24. Canonical write-up:
`docs/lessons-learned/windows-desktop-wifi-github-download/README.md`

## Desktop with 16 GB GPU

| Field | Value |
| --- | --- |
| Inventory hostname | `dev-workstation-win` |
| Windows NetBIOS | **DESKTOP-C1ACPUM** |
| IP | `192.168.50.133` |
| GPU | AMD Radeon **RX 9060 XT 16 GB** |
| Groups | `windows_hosts` + `windows_amd_gpu_hosts` (not offline, not NVIDIA) |
| Reachability | SSH alias `dev-workstation-win` works |

## What is `192.168.0.254`?

**AT&T residential gateway** (ARRIS). Live check: `http://192.168.0.254/` → `/cgi-bin/home.ha` with AT&T logo / `ATTV6527Ys` SSIDs.

It is **not** Hyper-V. Lab Hyper-V IPs: HVH-01 `192.168.50.234`, HVH-02 `192.168.50.158`.

## Topology

```text
DESKTOP-C1ACPUM (Wi-Fi) 192.168.50.133
        → ASUS 192.168.50.1
        → AT&T gateway 192.168.0.254
        → Internet / GitHub
```

First-hop Wi-Fi loss to ASUS remains the measured stall cause (~11–14%).

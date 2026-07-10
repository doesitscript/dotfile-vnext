Check desktop reachability

**Canonical troubleshooting packet:** [DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md](./DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md)

**On/off toggles and evidence tables:** [on-offs/DESKTOP-C1ACPUM-gpu-fps.md](./on-offs/DESKTOP-C1ACPUM-gpu-fps.md) — in those tables, **What we got** means the concrete probe/export output listed in that cell (same facts as in the agent’s pulse), not a separate data source. See [on-offs/README.md](./on-offs/README.md).

1
1 task in progress


can you see if the one desktop that is partly setup (and ocassionly i've had to temporarily ofline it in our repo, is up / the urfaes for communicating are working?
12:52 AM


Worked for 2m 34s
Evidence:
Troubleshooting mode: on. dev-workstation-win is up, but only the WinRM surface is currently working, and only when using the live IP 192.168.50.133.

Key output seen:

smbutil lookup DESKTOP-C1ACPUM
Got response from 192.168.50.133
IP address of DESKTOP-C1ACPUM: 192.168.50.133
ping DESKTOP-C1ACPUM.local
2 packets transmitted, 2 packets received, 0.0% packet loss
nc 192.168.50.133 5985
Connection to 192.168.50.133 port 5985 [tcp/wsman] succeeded!
dev-workstation-win | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
SSH is still not available:

nc: connectx to 192.168.50.133 port 22 (tcp) failed: Operation timed out
sshd_service=absent
tcp_22_listener=absent
192.168.50.133
The repo/default route is still stale/broken: inventory has ansible_host: DESKTOP-C1ACPUM and host_ip: 192.168.50.70, while DNS/cache currently maps DESKTOP-C1ACPUM to .70; default win_ping failed as unreachable against desktop-c1acpum:5985. So: machine up, WinRM good by live IP override, SSH absent, repo default addressing not reliable yet.

No files changed.

Sources checked:

inventory/inventory.yaml (line 24)
inventory/host_vars/dev-workstation-win.yaml (line 1)
docs/one_off_tasks/dev-workstation-win-intermittent-download-slowdown.md (line 17)
AGENTS.md, .codex/config.toml, Codex framework docs/rules for runtime and troubleshooting guidance
3 memory citations

dev-workstation-win-intermittent-download-slowdown.md
Document · MD
Open in




12:55 AM
'The repo/default route is still stale/broken: inventory has ansible_host: DESKTOP-C1ACPUM and host_ip: 192.168.50.70, while DNS/cache currently maps DESKTOP-C1ACPUM to .70; <-- you ean that its mapping to an incomplete ip address: .70?


 default win_ping failed as unreachable against desktop-c1acpum:5985. So: machine up, <-- what? you just said win_ping fails? and winrm on the 'desktop-c1acpum:5985' isn't working??? i mean i do believe at minimum the hostname applied is not clearl to my memory or as defining in this project is definitevely able to be upprcased vs lower cased

' So: machine up, WinRM good by live IP' so you can conenct to the system, can you clarify the previous doubts i had

 WinRM good by live IP override, SSH absent, repo default addressing not reliable yet.'

Show more
1:10 AM

You’re right to challenge that wording. I compressed three different “names” into one sentence and made it muddy.

.70 was shorthand for the full IP 192.168.50.70, not an incomplete IP. The problem is that 192.168.50.70 appears stale/unreachable.

The clearer version is:

DESKTOP-C1ACPUM.local resolved by mDNS to 192.168.50.133
NetBIOS lookup also found DESKTOP-C1ACPUM at 192.168.50.133
192.168.50.133:5985 is reachable
win_ping works when I override Ansible to use 192.168.50.133
the repo/default path uses ansible_host: DESKTOP-C1ACPUM
that default name path resolved/canonicalized to desktop-c1acpum / 192.168.50.70
192.168.50.70:5985 failed, so default win_ping failed
So there is no contradiction in the WinRM result:

WinRM via live IP 192.168.50.133:5985 = works
WinRM via repo/default hostname path = fails because it lands on stale/unreachable .70
Hostname case is not the meaningful issue here. DESKTOP-C1ACPUM, desktop-c1acpum, and desktop-c1acpum.hom.lab should be treated as case-insensitive DNS/Windows names. The important issue is that different resolution paths disagree about the address.

Best current truth: the desktop is up at 192.168.50.133, WinRM works there, SSH is absent, and the repo/router/DNS inventory path still needs reconciliation before default Ansible targeting is reliable.





1:10 AM
connect to the host, the host is currently havign fps issues sometimes he's getting 1 to 5 fps. determine wha thte issue may be
1:30 AM


Worked for 3m 55s
Evidence:
Troubleshooting mode: on. I connected to dev-workstation-win over WinRM at 192.168.50.133 and collected read-only performance state while DeadByDaylight-Win64-Shipping was running.

Most likely issue: the machine is resource-constrained during the game, especially GPU memory and overlays/background GPU users. The AMD card reports about 4 GB VRAM, and the snapshot showed dedicated GPU memory already heavily consumed:

dwm                           2223.9 MB
DeadByDaylight-Win64-Shipping 1896.8 MB
Wallpaper Engine ui32          307.4 MB
steamwebhelper                 212.7 MB
Discord                        170.3 MB
Discord                        166.5 MB
That puts the system in a very plausible VRAM pressure / compositor contention situation. At 2560x1440, 180 Hz, a 4 GB GPU can get ugly fast when DWM, Wallpaper Engine, Discord, Steam overlay, and the game are all active.

Current CPU was also high:

DeadByDaylight-Win64-Shipping 49.9%
steamwebhelper                 9.2%
steam                          7.9%
Discord                        6.6%
Wallpaper Engine ui32          6.4%
GPU load was real but not obviously pegged at 100%:

DeadByDaylight 3D: 78.6%, 75.8%, 43.3%
Steam video codec: ~14%
Discord video codec: ~6%
DWM 3D: ~3%
Wallpaper Engine ui32 3D: 2.5%
Other findings:

Display adapter is healthy: AMD Radeon RX 9060 XT, status OK, driver 32.0.31007.5012, driver date 2026-05-11.
Active plan is High performance.
Disk did not look busy in the sample.
RAM had about 6.2 GB free.
Game DVR is enabled: GameDVR_Enabled : 1.
Steam overlay and Discord overlay processes are present.
There was a critical unclean reboot event at 2026-05-29 12:30:13 AM, but I did not see fresh display-driver crash events in this snapshot.
My read: start by killing/suspending Wallpaper Engine while gaming, then disable Steam overlay, Discord overlay, and Game DVR/capture for this machine. If the 1-5 FPS problem disappears, we’ve got the culprit class. If it persists with those off, the next suspect is driver/game-specific behavior or thermal/power throttling that this basic WMI pass could not fully measure.

Missing this run: actual FPS telemetry, AMD Adrenalin metrics, GPU temperature/hotspot, and an event sample exactly during a 1-5 FPS drop.

Sources checked:

dev-workstation-win live WinRM output via bin/codex-env ansible ... -e ansible_host=192.168.50.133
docs/one_off_tasks/dev-workstation-win-intermittent-download-slowdown.md (line 17)

dev-workstation-win-intermittent-download-slowdown.md
Document · MD
Open in




1:34 AM
can you kill the processes  you can. and can you verify the gpu memory, it is not 4gb . also expand troubleshooting into eindows events and logging and other logs that might hlpe
1:37 AM


Worked for 5m 3s
Evidence:
I connected over WinRM and killed the safe/user-space suspects I could without killing the game itself.

Killed:

Wallpaper Engine ui32: 5 processes
Steam gameoverlayui64: killed twice, but it respawned
Discord: 6 processes
Microsoft Edge: 12 processes
PhoneExperienceHost: 1 process
steamwebhelper: 7 processes
SystemSettings: 1 process
Steam overlay and Steam webhelpers respawned because Steam/game is still running:

gameoverlayui64               11104
steamwebhelper                 3700
steamwebhelper                 3844
steamwebhelper                 4076
...
You were right about GPU memory. The 4 GB number was bogus WMI output from Win32_VideoController.AdapterRAM. Better registry evidence says:

HardwareInformation.qwMemorySize = 17095983104
That is about 15.9 GiB, so this is effectively a 16 GB GPU.

The strongest cause evidence is from Windows Diagnostics-Performance:

The Desktop Window Manager is experiencing heavy resource contention.
Scenario: Video memory resources are over-utilized and there is thrashing happening as a result.
That event appeared twice:

5/29/2026 12:38:15 AM
5/28/2026 12:14:33 PM
After cleanup, adapter-level GPU memory dropped:

Before-ish: total committed 3727.5 MB, dedicated usage 3185 MB
After cleanup: total committed 2670.6 MB, dedicated usage 2282.2 MB
Other log findings:

Unexpected shutdown: 5/29/2026 12:30:13 AM, Kernel-Power 41.
AMD components were removed/installed around 5/29/2026 12:19 AM.
MSI Afterburner kernel driver RTCore64.sys installed at 5/29/2026 1:36:11 AM.
Steam Client Service had timeout/start failures around 5/28/2026 11:42 PM.
Current Dead by Daylight log exists: C:\Users\ericc\AppData\Local\DeadByDaylight\Saved\Logs\DeadByDaylight.log.
Old crash dumps exist for Razer Central, cefprocess, Helldivers 2, Hitman, but no fresh DBD crash in this check.
My read now: this is not “GPU only has 4 GB.” It is more likely DWM/video-memory thrashing caused by the running 3440x1440@180Hz desktop/game path plus overlays/browser/Wallpaper Engine/Discord/Steam web UI, possibly made worse by recent AMD driver/software churn. The Windows event log directly confirms video-memory thrashing.

I could not get dxdiag to produce output over WinRM; one attempt hit access denied and the direct attempt produced no file. No repo files changed.

Sources checked:

live WinRM process/event/counter output from dev-workstation-win
Windows System, Application, Diagnostics-Performance, Reliability records, Steam/DBD/log candidate paths
docs/one_off_tasks/dev-workstation-win-intermittent-download-slowdown.md (line 17)

dev-workstation-win-intermittent-download-slowdown.md
Document · MD
Open in




1:42 AM
he jsut restared and logged back in. Can you doa check again and get a pulse on how his system is now?

also:'rivera statistics server is also setup on the computer, if you can utilie this for troubleshooting, pleas do this too.'
1:45 AM

I’ll assume “rivera statistics server” means RivaTuner Statistics Server / RTSS. I’ll reconnect after the restart, collect a fresh pulse, then specifically look for RTSS/MSI Afterburner processes, services, profiles, logs, and any hooks that can explain FPS/overlay behavior.


Ran 2 commands

---

## Session continuation (2026-05-29) — ingested + post-restart pulse

### Context ingested

| Topic | Standing truth |
|---|---|
| Host | `dev-workstation-win` / `DESKTOP-C1ACPUM` |
| Live IP | `192.168.50.133` (inventory `host_vars` now aligned) |
| WinRM | Works on default inventory path (no override needed) |
| SSH | `sshd` running, TCP/22 listening; controller SSH auth still fails (`Permission denied`) |
| FPS issue class | Windows Diagnostics-Performance: DWM video-memory thrashing (pre-reboot 12:38 AM) |
| GPU size | ~16 GB (not 4 GB WMI `AdapterRAM`); registry `qwMemorySize` needs elevated read |
| RTSS | User meant **RivaTuner Statistics Server** (with MSI Afterburner) |

### Post-restart pulse (WinRM, ~0.98 h uptime after boot 2026-05-29 01:43:43)

**Connectivity**

```text
dev-workstation-win | SUCCESS => { "ping": "pong" }
nc 192.168.50.133 22 -> succeeded
ssh joshc@192.168.50.133 hostname -> Permission denied (publickey,password,keyboard-interactive)
```

**Shutdown/reboot (clean this time)**

```text
5/29/2026 1:43:23 AM  Kernel-Power 109  shutdown transition (Kernel API)
5/29/2026 1:43:43 AM  LastBootUpTime
5/29/2026 1:43:45 AM  Kernel-Power 172  NIC compliance standby
```

No new unclean reboot 41 since the earlier 12:30 AM event.

**GPU / display**

- Adapter: AMD Radeon RX 9060 XT, driver 32.0.31007.5012, Status OK
- WMI `AdapterRAM` still bogus (~4 GB); treat as unreliable
- Top **dedicated GPU memory** consumers (counters): `pid_1708` (dwm) **3387.7 MB**, then Discord/steam PIDs in hundreds of MB
- **Dead by Daylight not running** at check time

**RTSS / MSI Afterburner (running since ~1:51 AM)**

```text
RTSS              15740  C:\Program Files (x86)\RivaTuner Statistics Server\RTSS.exe
RTSSHooksLoader64  2052
EncoderServer      8436
MSIAfterburner     9364
```

- Profile `Config` last written 5/29/2026 1:51:33 AM
- Settings: `EnableEncoderServer=1`, `Enable64Bit=1`, Present-hook offsets cached for DXGI/D3D9/D3D12
- RTSS is an active graphics hook layer — relevant for overlay/FPS troubleshooting, not just passive monitoring

**Background load (idle desktop, no game)**

- CPU leaders: `steam`, `Discord`, `MsMpEng`, `dwm`
- Wallpaper Engine (`wallpaper64`) already back after reboot
- RAM: ~9.8 GB free / 16.3 GB total

**Events**

- Last DWM video-memory thrashing warning still **5/29/2026 12:38:15 AM** (pre-reboot); none newer in last 6 h at check time

### Assessment after restart

Cleaner boot than the unclean 12:30 AM cycle. System is reachable and stable on WinRM. DWM still holds ~3.4 GB dedicated GPU memory without DBD running — desktop compositor + ultrawide/high refresh + Discord/Steam/Wallpaper/RTSS hook stack is enough to keep VRAM pressure high. RTSS/Afterburner are confirmed running and hooking Present; worth testing with RTSS overlay/encoder disabled during gaming if FPS drops return.

**Missing this run:** in-game FPS sample during a drop, AMD Adrenalin metrics, elevated registry VRAM read, RTSS OSD log during gameplay.

### OpenSSH re-check (2026-05-29 ~2:45 AM)

SSH is working from `mac-dev` with the repo controller key (not password/TTY):

```text
ssh -i ~/.ssh/id_ed25519_ansible joshc@192.168.50.133 "hostname; whoami"
DESKTOP-C1ACPUM
desktop-c1acpum\joshc
```

Earlier failure was **wrong auth path** (default `~/.ssh/id_ed25519` + non-interactive password), not “SSH down.”

```text
OpenSSH/Operational: Accepted publickey for joshc from 192.168.50.33 ... ED25519 SHA256:sabol8zXq07Rm0MVH/GL+eAuXZSTRhIsncq+Uv/lGow
administrators_authorized_keys exists: True
user authorized_keys exists: True
sshd: Running, StartType Automatic
```

`inventory/host_vars/dev-workstation-win.yaml` updated to **SSH primary** (same shape as `HOM-LAB-HVH-02`); WinRM commented as fallback.

Ansible ad-hoc over SSH:

```text
bin/codex-env ansible ... dev-workstation-win -m ansible.windows.win_shell -a "hostname; Get-Service sshd ..."
DESKTOP-C1ACPUM / sshd Running
```

Full GPU/RTSS pulse re-run via `scp` + `ssh` + PowerShell script — same findings as WinRM pulse (~1 h uptime, DWM ~3.4 GB dedicated VRAM, RTSS hook stack running).

### Full troubleshooting pass (2026-05-29 ~2:51 AM, OpenSSH)

**Previously failed — now succeeded over SSH:**

| Item | Result |
|------|--------|
| dxdiag | OK → `artifacts/troubleshooting/dev-workstation-dxdiag-20260529.txt` (79 KB) |
| GPU VRAM registry | `HardwareInformation.qwMemorySize=0x3fb000000` (~15.9 GiB) |
| AMD Adrenalin registry | HKCU `AMD\DVR`, `AMD\CN\Performance` read OK |

**Display / GPU (dxdiag):** 3440×1440 @ **180 Hz**; Dedicated Memory **16253 MB**; RX 9060 XT driver 32.0.31007.5012 (installed 5/29 ~12:19 AM). **Hardware Scheduling: Supported=False** (cannot enable). CPU i7-6700K, 16 GB RAM.

**Out-of-game AMD Adrenalin / capture settings (registry):**

- `DvrEnabled=1` — AMD ReLive DVR **on**
- `GameDVR_Enabled=1` — Windows Game Bar capture **on**
- `MetricsOverlayState=0` — AMD metrics overlay **off** (limits FPS telemetry today)
- `MetricsProfile=1`, log path `C:\Users\joshc\AppData\Local\AMD\CN`
- Radeon Software UI not running (only `atieclxx`/`etiesrxx`); driver stack active

**RTSS:** `RTSS`, `RTSSHooksLoader64`, `EncoderServer`, `MSIAfterburner` running; Present-hook offsets cached; profile dir only `Config` (no `Global` file).

**FPS evidence still missing:** sample during 1–5 FPS drop; GPU hotspot temp; in-game frametime (PresentMon not installed).

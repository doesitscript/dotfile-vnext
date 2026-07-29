# macOS XProtect / Gatekeeper Friction — Investigation Capture

**Captured:** 2026-07-29  
**Host context:** mac-dev controller (macOS, APFS Data volume UUID `3EBC4833-9845-35B8-BF02-15BDE0E25A05`)  
**Status:** brainstorm / evidence archive — not approved work  
**Origin:** live conversation investigation of “what is XProtect doing / how do I stop it checking stuff I consider safe”

---

## Goal (operator intent)

Understand what the XProtect-related processes are doing so known-safe developer
tooling can avoid repeated security checks / CPU or launch friction — without
blindly disabling macOS malware defenses.

---

## Verdict (short)

Two different systems were in play:

1. **XProtect Remediator** — scheduled background malware remediator scans
   (timer-driven; not a user-facing AV UI).
2. **Gatekeeper / `syspolicyd`** — the noisy path: evaluating unsigned /
   unquarantined / freshly launched binaries as they run.

You generally **cannot** turn XProtect Remediator / `XprotectService` off in a
supported way without weakening SIP. The practical lever for “stop re-checking
tools I trust” is almost always **quarantine + signing / Gatekeeper policy**,
not killing XProtect.

---

## Processes observed (live)

| Process | Example PID (at capture) | Role |
|---------|--------------------------|------|
| `XprotectService` | 471 (root) | Always-on XProtect XPC service (signature / YARA path) |
| `XProtect` (daemon) | 7429 (root) | Remediator scan launcher |
| `XProtect` (agent) | 7434 (user) | User-session Remediator launcher |
| `XProtectPluginService` | 75930 (user) | Plugin runner used during Remediator scans |
| `syspolicyd` | 173 (root) | Gatekeeper policy / scan orchestration — **primary noise source** |

Launchd labels of interest:

- `com.apple.XProtect.agent.scan`
- `com.apple.XProtect.agent.scan.startup`
- `com.apple.XProtect.daemon.scan`
- `com.apple.XprotectFramework.PluginService`
- `com.apple.MRTa` (MRT companion; present in `launchctl list`)

Binary / definition roots:

- `/Library/Apple/System/Library/CoreServices/XProtect.app`
- `/Library/Apple/System/Library/CoreServices/XProtect.bundle` (CFBundleShortVersionString **5329** at capture)
- Resources included `XProtect.yara`, `XProtect.plist`, `gk.db`, `XPScripts.yr`

Gatekeeper status at capture: `spctl --status` → **assessments enabled**.

---

## Remediator schedule (from launchd plists)

User agent and system daemon both register repeating XPC activities:

| Activity class | Interval | Notes |
|----------------|----------|-------|
| `*.fast.scan` | **21600 s (6 h)** | `AllowBattery: true`, CPU/Disk intensive, PowerNap |
| `*.scan` | **86400 s (24 h)** | `AllowBattery: false` |
| `*.slow.scan` | **604800 s (7 d)** | `AllowBattery: false` |
| startup | login / RunAtLoad | `LOGIN=1` on agent startup plist |

Evidence from logs (~2026-07-28 22:30):

- Activity `com.apple.XProtect.PluginService.daemon.fast.scan` ran.
- Duet briefly suspended it (`thermalLevel > 1`).
- Scan completed: `Finished system scan, ran as 0`.
- Plugin service received SIGTERM after timer / activity end.

Interpretation: Remediator is Apple hunting known malware families already on
disk on a timer. It is not the same as “Gatekeeper blocked my CLI.”

---

## Gatekeeper / `syspolicyd` evidence (the friction path)

Recent log pattern (subsystem `com.apple.syspolicy.exec`):

- High volume of `GK evaluateScanResult` against objects on the Data volume
  (`vuid: 3EBC4833-…`).
- Occasional `GK performScan` for binaries not yet in an allowed policy.
- Named examples at capture time:
  - `terraform-ls` — Team ID `D38WU7D763` (HashiCorp), `bundle_id: NOT_A_BUNDLE`
  - `libsqlite3.3.53.4`
  - many entries with `team: (null)` / null id (typical Homebrew, local builds,
    script wrappers, ad-hoc tools)
- Example failure text:
  - `GatekeeperPolicyScanError Code=-67018 "Code did not match any currently allowed policy"`
- Related noise: notarization daemon errors (`Error checking with notarization daemon: 3`),
  then continued evaluation.

Apple’s high-level model (from support docs consulted during the thread):

- XProtect YARA / signature checks on **first launch**, **binary change**, and
  **definition update**.
- Remediator adds **periodic background remediation**.
- Gatekeeper + notarization are a separate, busier trust path for untrusted /
  newly introduced code.

---

## What “prevent it from being called” can mean

### Not supported / high cost

- Unloading Apple XProtect launch agents/daemons under SIP.
- Disabling SIP to kill XProtect (possible but leaves remediator/signature
  defense off — not recommended as a standing state).

### Practical levers (Gatekeeper friction)

1. **Strip quarantine** on known-good downloads (often the biggest CLI win):

   ```bash
   xattr -d com.apple.quarantine /path/to/binary
   xattr -dr com.apple.quarantine /opt/homebrew/Cellar/some-formula
   ```

2. Prefer **signed / notarized** installs (official vendor or Homebrew bottles)
   so `syspolicyd` caches a good assessment.

3. **Ad-hoc codesign** local builds so assessments are consistent:

   ```bash
   codesign -s - --force /path/to/your-binary
   ```

4. Nuclear **Gatekeeper-only** (does not stop Remediator timers):

   ```bash
   sudo spctl --master-disable
   ```

   Reversible with `sudo spctl --master-enable`. Treat as temporary operator
   choice, not default automation.

There is **no supported “whitelist this path so Remediator never scans it”**
API. Reducing pain is fewer quarantine bits, fewer unsigned first launches,
and fewer freshly written executables under develop trees / Homebrew.

---

## Watch / evidence commands (for later sessions)

```bash
# Gatekeeper (usually the noisy path)
log stream --predicate 'subsystem == "com.apple.syspolicy.exec"' --style compact

# Remediator / XProtect processes
log stream --predicate 'process CONTAINS "XProtect"' --style compact

# One-shot recent Gatekeeper evaluations
log show --predicate 'subsystem == "com.apple.syspolicy.exec"' --last 30m --style compact

# Launchd Remediator agent state (user domain)
launchctl print gui/$(id -u)/com.apple.XProtect.agent.scan
```

Diagnostic split for future triage:

- **CPU spikes on a timer (~6h / daily)** → Remediator schedule.
- **Lag when launching CLIs/apps** → Gatekeeper / quarantine / signing.

---

## Candidate later implementation ideas (not decided)

These are brainstorm-only until promoted:

1. **Operator runbook** under `docs/` (steady-state): how to distinguish
   Remediator vs Gatekeeper, quarantine strip checklist for known tools.
2. **macOS controller playbook / role slice** (optional): after trusted tool
   installs, clear quarantine on declared paths; never disable SIP/XProtect.
3. **Inventory of high-friction binaries** on mac-dev (terraform-ls, local
   Python/Node helpers, Homebrew Cellar trees) with per-path mitigation.
4. **Observability snippet**: small script or note capturing `GK performScan`
   / `-67018` rates over a work session.
5. Explicit **non-goals**: do not automate `spctl --master-disable`; do not
   ship SIP-off guidance as default.

### Open questions before any plan packet

- Is the pain primarily Remediator CPU or Gatekeeper launch latency?
- Which tool trees are in scope (Homebrew only? `~/develop` builds? Cursor
  helpers?).
- Should any mitigation be Ansible-managed on mac-dev, or stay a manual
  operator checklist?
- Acceptable security tradeoff: quarantine strip vs Gatekeeper disable vs
  leave defaults and only document?

---

## Sources checked (conversation)

- Live host: `ps`, `launchctl`, XProtect launch plists under
  `/Library/Apple/System/Library/Launch{Agents,Daemons}/`
- Live logs: `log show` / `syspolicyd` / `XProtect*` (~2026-07-28 evening through
  2026-07-29)
- `spctl --status`; XProtect.bundle Info.plist version 5329
- Apple Support: [Protecting against malware in macOS](https://support.apple.com/guide/security/protecting-against-malware-sec469d47bd8/web)
- Secondary explainers used for orientation only (not authority for disable
  procedures): Moonlock XProtect overview; Trio XProtect deployment notes;
  NetVigilance XprotectService CPU notes

---

## Promotion path

1. If operator confirms pain class → shape a short runbook or intake item.
2. If Ansible-managed quarantine hygiene is wanted → `docs/intake/` then
   `docs/plans/YYYY-MM-DD--…` with Apply/Verify/Undo.
3. Keep SIP/XProtect disable out of default project automation.

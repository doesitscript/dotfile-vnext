# GPU Performance Tuning Plan

> Plan-like brainstorm - not an approved `docs/plans/` packet or repo authority.
> Parent packet: [README.md](./README.md)

---

## Purpose

Define a practical and safe tuning pattern for a desktop GPU where performance
changes are made in user-space tooling (for example MSI Afterburner), then
validated for:

- performance uplift
- stability
- thermal and acoustic impact
- startup persistence behavior

---

## Scope Boundary

In scope:

- clock offsets and power/temperature limits
- fan strategy and thermal guardrails
- startup persistence checks after reboot
- lightweight benchmark and stress loops

Out of scope:

- BIOS flashing or hardware firmware modification
- unattended overvolting experiments
- production automation decisions

---

## Baseline Capture

Collect and keep a baseline before changes:

- idle telemetry (clocks, temperature, fan, board power draw)
- load telemetry during one known benchmark
- benchmark score and frame-time behavior
- ambient room temperature (if available)

Example telemetry probe:

```powershell
nvidia-smi --query-gpu=name,pstate,clocks.current.graphics,clocks.current.memory,power.draw,power.limit,temperature.gpu,fan.speed --format=csv
```

---

## Candidate Tuning Flow

1. Start from stock profile and confirm stable baseline.
2. Increase power limit in small steps (if desired).
3. Apply small core clock offset, test, and log behavior.
4. Apply small memory clock offset, test, and log behavior.
5. Rebalance fan curve for thermal target and noise tolerance.
6. Repeat until the first instability signal appears, then back off one step.

Suggested step sizes:

- core offset: +15 to +30 MHz per iteration
- memory offset: +100 to +250 MHz per iteration
- power limit: +2% to +5% per iteration

---

## Validation Gate

A tuning profile is considered viable only when all checks pass:

- no benchmark crash, driver reset, or artifacting
- no WHEA/system instability events during test window
- thermals remain below chosen cap under sustained load
- fan behavior remains acceptable for expected usage
- repeat benchmark variation stays within normal run-to-run drift

---

## Startup Persistence Question

Most user-space tuning tools require startup re-apply after boot. For MSI
Afterburner specifically, persistence usually depends on:

- `Start with Windows`
- `Apply overclocking at system startup`

Validation loop:

1. Reboot with both options disabled and capture telemetry.
2. Start Afterburner, apply profile, and capture telemetry.
3. Reboot with both options enabled and capture telemetry immediately after logon.
4. Compare values across all three checkpoints.

If only post-launch telemetry reflects the tuned profile, startup re-apply is
required for desired behavior.

---

## Rollback Pattern

- Save known-good profile before experimentation.
- Keep one explicit "stock-safe" profile.
- On instability, revert to stock-safe profile and retest baseline benchmark.
- If instability persists after revert, reset tool-level overrides and reboot.

---

## Apply / Verify / Undo / Change Class

| | |
|--|--|
| **Apply** | Interactive profile tuning in user-space tooling with stepwise changes |
| **Verify** | Compare pre/post telemetry, benchmark outcomes, and reboot persistence checks |
| **Undo** | Reapply stock-safe profile, disable startup apply, then reboot |
| **Change class** | Brainstorm and operator runbook draft (not active automation) |

---

## Risks and Notes

- High offsets can trigger driver resets or silent data errors.
- Different workloads can expose instability that synthetic tests miss.
- Seasonal ambient temperature changes can invalidate prior "stable" settings.
- Driver updates may alter behavior and require revalidation.

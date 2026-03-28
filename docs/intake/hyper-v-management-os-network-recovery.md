# Hyper-V Management OS Network Recovery

Intake note for the Windows host control-plane outage that can happen after
Hyper-V enablement or External switch creation on `server-225-win`.

## Problem Summary

The Windows host can lose its expected control-plane IP after Hyper-V changes
the management OS networking shape.

Observed scenario:

1. The host starts with the expected reserved DHCP address.
2. Hyper-V feature and/or External switch work adds new host-visible network
   adapters such as `vEthernet (External)`.
3. After reboot or network re-plumb, the host can come back on the wrong DHCP
   address even though the router reservation is still based on the expected
   MAC address.
4. WinRM and OpenSSH both become unreachable from the controller until someone
   walks to the machine and repairs networking locally.

The user manually recovered the host with:

```powershell
Clear-DnsClientCache
ipconfig /flushdns
ipconfig /release
ipconfig /renew
```

That soft DHCP refresh restored the expected IP and brought back both WinRM and
SSH.

## Main Design Requirement

The important requirement is not only "verify the host came back."

The real requirement is:

- pre-seed a recovery path on the Windows host before the risky Hyper-V change
- so the host can recover itself locally if controller connectivity is lost

This is a control-plane survival problem, not just a post-change verification
problem.

## Considered Options

### 1. Static management IP

Pros:

- deterministic
- avoids depending on DHCP reservation behavior

Cons:

- more invasive than needed for a first try
- user explicitly preferred a softer first implementation

Decision:

- not the first implementation
- keep as a stronger fallback if DHCP recovery proves unreliable

### 2. DHCP refresh after reconnect only

Pros:

- simple
- low risk

Cons:

- does not solve the actual failure window
- controller may already be disconnected before it can issue the repair

Decision:

- insufficient by itself

### 3. Temporary host-local scheduled task running on next boot

Pros:

- simple
- local to the host
- survives the connection-loss window
- uses the exact recovery commands that already worked in real life
- good fit for Ansible because the task can be staged before the risky change

Cons:

- still DHCP-based
- recovery is reactive after boot, not a fully deterministic networking design

Decision:

- chosen first implementation

## Metric / Adapter Preference Discussion

We also considered adapter metric and prioritization policy.

Goal:

- prefer the intended management path
- deprioritize virtual adapters or other interfaces that could compete with the
  control-plane path

Important limitation:

- the final Hyper-V management adapter that matters most, such as
  `vEthernet (External)`, does not exist until Hyper-V creates it
- therefore the final metric policy cannot be fully applied before the risky
  change happens

What can be done before the change:

- set policy on existing physical adapters
- record the intended primary adapter
- pre-stage logic to apply or verify metrics after the new adapters exist

Conclusion:

- metric-based policy may still be worthwhile later
- but it is not the best first recovery implementation for this outage
- the scheduled-task approach is the better first step because it addresses the
  real connection-loss window with less complexity

## Ansible-Centric First Implementation

Preferred first path:

1. Before Hyper-V feature or External switch work, stage a local PowerShell
   recovery script on the Windows host.
2. Register a temporary boot-triggered scheduled task.
3. On next boot, if the host is not on the expected control-plane IP, run:
   - `Clear-DnsClientCache`
   - `ipconfig /flushdns`
   - `ipconfig /release`
   - `ipconfig /renew`
4. Let the task unregister itself after running.
5. After the controller reconnects, remove any remaining helper artifacts.

This is the minimal viable preemptive design because the repair path already
exists on the host before the outage window begins.

## Current Repo Direction

The Hyper-V networking role now follows this first-pass direction:

- boot recovery is staged before risky Hyper-V work
- recovery is based on the proven DHCP refresh sequence
- the host's expected control-plane IP remains the verification target
- static management IP is deferred
- interface metric policy is deferred as a follow-up design if still needed

## Follow-Up Questions

1. Does the one-time boot recovery remove the need for manual local recovery in
   repeated Hyper-V runs?
2. If DHCP-based recovery is still unreliable, should the next step be:
   - adapter metric policy
   - or static management IP
3. If metric policy is added later, should it be implemented via:
   - DSC (`NetworkingDsc` / `NetIPInterface`)
   - or a narrower repo role with PowerShell only where necessary

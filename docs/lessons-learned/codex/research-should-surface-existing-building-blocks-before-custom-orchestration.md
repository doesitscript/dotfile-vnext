# Research Should Surface Existing Building Blocks Before Custom Orchestration

This note exists because some Windows and Hyper-V work accumulated more custom
PowerShell orchestration than it should have before the research pass clearly
identified which cleaner building blocks were already available.

The point is not "never orchestrate." The point is:

- do the explicit resource sweep first
- identify which parts already have a clean module/resource
- reserve custom orchestration for the gaps that are truly still gaps

## What should have been surfaced earlier

For the recent Windows/Hyper-V work, the Researcher should have explicitly
called out at least these building blocks earlier:

- `community.windows.win_scheduled_task`
  - clean resource for boot-triggered recovery tasks
- `ansible.windows.win_dsc`
  - Ansible bridge for DSC resources when a native Ansible module is missing
- `NetworkingDsc`
  - useful for interface/IP/route/network policy work such as `NetIPInterface`
- `HyperVDsc`
  - existing Hyper-V DSC resource family worth evaluating before assuming every
    Hyper-V operation must be hand-orchestrated

## What this means in practice

Before writing or extending multi-step Windows PowerShell orchestration, the
research pass should answer:

1. is there a native Ansible module?
2. if not, is there a good `community.windows` resource?
3. if not, is there an appropriate DSC resource reachable through
   `ansible.windows.win_dsc`?
4. only after those checks fail should the plan settle on custom orchestration

## Where custom orchestration is still legitimate

Even after that sweep, some work still belongs in repo logic.

Examples from the Hyper-V Ubuntu path:

- download Canonical image artifacts
- extract archives
- normalize sparse/compressed disk artifacts
- sequence conversion, probe, and VM realization
- survive controller disconnects during host network changes

Those are orchestration problems, not just single-resource declarations.

## Framework improvement

The Researcher should not stop at:

- "there is no single perfect community role"

The Researcher should also say:

- "these sub-parts already have cleaner building blocks"
- "these sub-parts still require repo orchestration"

That produces a much better plan:

- use the cleaner resource where it exists
- keep custom logic only for the irreducible workflow glue

## Pinned examples

- the Hyper-V management OS recovery task should use
  `community.windows.win_scheduled_task`
- interface metric or network-policy work should at least consider
  `ansible.windows.win_dsc` plus `NetworkingDsc`
- Hyper-V VM lifecycle work should at least evaluate `HyperVDsc` before
  assuming native PowerShell is the only maintainable path

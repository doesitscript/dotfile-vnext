# Intake: Hyper-V Ubuntu Image Targets — For Comparison

**Date:** 2026-03-28  
**Status:** comparison note across the main guest-image targets considered for
`server-225-ubuntu`

## Purpose

This note keeps the guest-image choices separate from the networking choices.
The project has learned that a workable Hyper-V network layout does not
automatically mean the chosen Ubuntu image has a good local-Hyper-V bootstrap
path.

## Quick Comparison

| Image target | Good fit for Hyper-V | Good fit for SSH/Docker host | Local automation story | Current judgment |
|---|---|---|---|---|
| Azure cloud-image VHD tarball | medium after normalization | good on paper | weak in practice for this local Hyper-V path | preserved as research, no longer active target |
| Canonical Hyper-V Quick Create VHDX | high | medium | strong Hyper-V viability target, but lands in desktop first-run setup | validated fallback / comparison target |
| Ubuntu Server ISO | high | high | strongest long-term server install path, but needs installer/autoinstall handoff | current next target |

## Option 1: Azure Cloud-Image VHD

### Why it was attractive

- close to cloud-init workflows already familiar in the repo
- easy to imagine as an SSH-first server target
- Canonical publishes an Azure VHD directly

### What actually happened

- source normalization and `Convert-VHD` worked
- the disk became a viable Hyper-V-native VHDX
- repeated local boots still behaved like an Azure-datasource guest
- local provisioning media was not consumed the way we intended

### Current judgment

- keep as durable research and evidence
- stop using it as the active next implementation target

## Option 2: Canonical Hyper-V Quick Create VHDX

### Why it was a good next checkpoint

- Canonical documents Quick Create as the recommended Hyper-V path for the
  curated Ubuntu image
- the partner image is already packaged as a Hyper-V VHDX zip
- this removes the Azure-datasource mismatch from the first boot target
- it gave us a Hyper-V-native image that boots cleanly and exposes a usable
  console

### Tradeoffs

- Canonical frames this as a desktop-style Hyper-V experience
- it is not as naturally aligned with unattended SSH/server bootstrap as a
  server installer path

### What the latest run proved

- the image is healthy enough to boot into a real Ubuntu desktop first-run
  configuration flow inside VMConnect
- that is valuable evidence: Hyper-V bootability and console visibility are no
  longer the blocker on this path
- it is also the stopping point for this path as the active target, because the
  image lands in an interactive desktop setup rather than a server-oriented
  unattended bootstrap

### Current judgment

- keep Quick Create as a validated Hyper-V-native fallback/checkpoint
- stop treating it as the active target for `server-225-ubuntu`

## Option 3: Ubuntu Server ISO

### Why it is now the active next target

- Canonical also documents the ISO-on-Hyper-V path directly
- it is a much better conceptual match for an SSH/Docker server target
- it is the cleaner place to introduce installer/autoinstall behavior later

### Tradeoffs

- requires installer/autoinstall orchestration instead of direct-disk boot
- the autoinstall handoff is more explicit than the Quick Create VHDX path

### Current judgment

- make this the active next target
- keep the first implementation honest as an installer lifecycle checkpoint if
  full autoinstall is not yet wired
- first live result:
  - the ISO downloaded, verified, attached, and booted successfully on
    `server-225-win`
  - this gives us a cleaner server-aligned console target than the desktop
    Quick Create image

## Current Working Judgment

- Networking: the private-subnet Hyper-V network design looked workable
- Guest image/bootstrap: the Azure cloud-image path remained the blocker
- Quick Create is now a validated Hyper-V bootability fallback/checkpoint
- Next active image target: official Ubuntu Server ISO on Hyper-V

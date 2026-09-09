---
name: work-laptop-recorded-facts
description: "Use when asked for the work laptop model, specs, chip, macOS version, hostname, or username. Read host_vars/work-laptop.yaml first (work_laptop_model, work_laptop_chip, work_laptop_macos_version), then README Current target facts. Do not search the repo or guess."
---

# Skill: Work-laptop recorded facts

Answer hardware and identity questions from recorded files. Do not search
first.

## Read first

1. Packet or sibling `host_vars/work-laptop.yaml`:
   - `work_laptop_model`
   - `work_laptop_chip`
   - `work_laptop_macos_version`
2. README section `Current target facts` (short hostname, username)
3. `deviations/register.yaml` only if the question is a home-Mac vs work-laptop
   difference

## Do not

- Grep the whole workspace before those files
- Invent specs from memory
- Treat sibling-only edits as authority — design lives in
  `dotfile-vnext/exports/work-laptop-ai-tools/`

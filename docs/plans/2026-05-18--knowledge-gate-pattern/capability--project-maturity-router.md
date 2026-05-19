# Capability: Project Maturity Router

## Purpose

Route broad project-improvement requests to the correct knowledge gates without
turning Ansible and NetBox into one combined capability.

## Triggers

- "improve the project"
- "mature this repo"
- "align with best practices"
- "make the architecture better"
- "raise standards"
- requests that mention both infrastructure modeling and automation quality

## Routing Rules

- If the task is about automation implementation or validation, invoke the
  Ansible knowledge gate.
- If the task is about infrastructure identity, hierarchy, naming, IPAM, or
  source-of-truth modeling, invoke the NetBox knowledge gate.
- If both domains are materially involved, invoke both gates and keep their
  receipts separate.

## Non-Goals

- Do not duplicate Ansible or NetBox domain rules.
- Do not decide final architecture without the domain gates.
- Do not turn "project maturity" into a generic catch-all that bypasses
  source-backed research.

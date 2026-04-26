# Ansible Capability Maturity Report Card

> Status: living document
>
> This document is a continuously updated report card for how we want Ansible
> capabilities in this project to behave as they mature. It is not a one-time
> design note. It is a durable grading surface for humans and AIs.

## Purpose

This document exists to do three things:

1. State the most mature targeting, lifecycle, and safety patterns we want in
   this project.
2. Provide a lightweight current maturity snapshot of the project.
3. Give an AI or human reviewer a repeatable way to grade a playbook, role, or
   capability against the project standard.

This document should be updated whenever we:

- improve a capability pattern
- discover a gap in how a playbook behaves
- replace an early safety rail with a more mature scalable design
- promote a previously experimental practice into a project standard

## How To Read This

Use this document at two levels:

- `Target standard`
  The mature shape we want capabilities to move toward.
- `Current maturity`
  Where the project stands right now. This is intentionally lightweight and
  should be updated often.

## Current Project Maturity Level

Current overall maturity level:

- `Level 2.5 / 5`

Meaning:

- we have several strong patterns already in place
- we are no longer improvising capability design from scratch
- we still have important places where mature intent exists but implementation
  is only partial or transitional

Current project strengths:

- metadata-based host classification is real and already in use
- capability-oriented playbooks are becoming the preferred direction over
  server-named playbooks
- `present|absent` lifecycle design is established
- preview-first validation exists for sensitive capabilities
- resource-level safety checks are real for high-risk work like storage and
  backup operations
- operator-facing summaries are improving and are no longer treated as
  optional polish

Current project gaps:

- some playbook names and examples still imply one-server-at-a-time operation
  even when the implementation should scale across all opted-in hosts
- some playbooks still rely too much on narrow inventory groups or transitional
  enrollment gates
- some runtime targeting is still represented as hand-maintained groups instead
  of derived groups from host intent
- lifecycle state sometimes still doubles as enrollment instead of being pure
  intent
- not every capability yet uses the same maturity model consistently
- some early implementations still need refactoring to fully match the mature
  targeting design

## Mature Capability Model

The mature model we want is:

### 1. Phase/capability-oriented playbooks

Playbooks should describe a phase or capability, not the special server that
first needed it.

Good:

- `provision_hyperv_guests.yml`
- `configure_linux_runtimes.yml`
- `deploy_container_workloads.yml`
- `deploy_k3s.yml`
- `deploy_observability.yml`

Less mature:

- playbooks named after a single server when the capability applies to more
  than one host
- playbooks whose primary selection mechanism is a static hostname
- examples that make `--limit one-host` look like the normal path when the
  playbook is designed to apply to all declared targets

Server-specific wrappers can exist as temporary bootstrap or recovery surfaces,
but they should not become the mature steady-state shape for a reusable
capability.

### 2. Broad execution surface

Target a broad, meaningful execution surface such as a Windows or Linux control
plane set, not just “the two hosts we currently care about.”

Good:

- `hosts: windows_hosts`
- `hosts: linux_vm_hosts`
- another durable capability surface with clear operational meaning

Less mature:

- host-specific targeting baked into the playbook
- playbooks that only make sense because the inventory group is currently tiny

### 3. Host intent is source of truth; derived groups are execution detail

Static runtime groups should not be the durable source of truth for capability
placement.

Preferred source of truth:

- `host_vars` or inventory data declares intent
- examples: `runtime_planes`, `node_classes`, `workloads`, and policy classes
- NetBox can later own durable facts such as device, VM, site, platform, role,
  tags, parent host, and IP addresses

Preferred execution bridge:

- playbooks use `group_by` or constructed inventory to derive runtime groups
- derived groups are named for execution convenience, not hand-maintained as
  primary data

Example source intent:

```yaml
runtime_planes:
  docker_engine:
    enabled: true
    purpose: storage_observability

node_classes:
  - storage_observability
  - docker_runtime

policy_classes:
  - authoritative_data
```

Example derived group:

```yaml
- name: Group Docker Engine hosts from declared runtime intent
  ansible.builtin.group_by:
    key: runtime_docker_engine
  when: runtime_planes.docker_engine.enabled | default(false) | bool
```

What to avoid:

- treating `runtime_docker_engine` as a manually maintained inventory group
- putting server identity into the playbook name when host intent can declare
  the same thing
- using static groups as a stand-in for missing host intent

### 4. Metadata describes the host; derived policy decides eligibility

Host metadata should describe what the host is.
A derived capability policy should decide whether a capability applies.

Terminology note:

- in this project, say `host categories`
- in Ansible terms, this usually maps to inventory groups or metadata-derived
  host classification
- do not describe these as OOP-style “classes”

NetBox-aligned metadata examples:

- device role
- platform
- status
- site
- location
- tenant
- tags
- custom fields

Project note:

- transport metadata such as `surface_type` can still be useful operationally,
  but it is not a strong primary business-policy signal for deciding whether a
  host should receive a capability
- a single weak cue such as `interaction_model == unattended` is not a mature
  eligibility rule by itself

Desired outcome:

- service and infrastructure machines are eligible
- family, interactive, recreational, or special-project machines are excluded
- the exclusion logic is understandable by reading inventory metadata, not by
  reverse-engineering a narrow host list

Preferred shape:

- metadata describes the host
- derived policy decides whether the capability manages that host category
- dynamic grouping or equivalent targets only the managed hosts
- lifecycle state is used only within that managed set

Derived policy pattern:

- `capability_should_manage: true|false`

Meaning:

- this is a derived policy result, not a hand-set per-host enrollment flag
- it answers: "Should this capability even consider this host?"
- it should come from metadata and policy logic, not from explicit host naming

Examples:

- `windows_server_backup_should_manage`
- `windows_driver_backup_should_manage`
- `windows_managed_service_data_backup_disk_should_manage`

NetBox-aligned example logic:

- device role indicates a service/server category
- platform indicates the operating-system family the capability is built for
- status indicates the host is in the operational state required by the policy
- site, location, or tenant constrain where that policy should apply
- tags and/or custom fields express repo-specific automation intent where the
  core NetBox model is not sufficient

What to avoid:

- using `present|absent` or variable existence as hidden enrollment
- static host-name allowlists as the real targeting model
- capability eligibility inferred primarily from transport details

### 5. Lifecycle state decides intent

Lifecycle state is the desired outcome for an eligible host.

Preferred pattern:

- `role_name_state: present|absent`

Mature meaning:

- `present` means the capability should exist
- `absent` means the capability should be removed
- lifecycle state is not a hidden enrollment hack
- lifecycle state answers: "For a host already in scope, do we want the
  capability installed or removed?"

Less mature meaning:

- “if the variable exists, the host is enrolled”
- “if the variable is missing, skip the host and hope that is good enough”

### 6. Resource-level checks prevent bad mutation

High-risk capabilities must have resource-level safety checks.

Examples:

- storage:
  - non-OS disk only
  - candidate count checks
  - device identity checks
  - existing-layout classification
- backup:
  - target drive validation
  - backup job state checks
  - manifest/native-state reconciliation
  - scheduled-task validation

The playbook should not rely only on broad targeting to stay safe.

### 7. Preview-first validation for new or risky targeting logic

When we first introduce or significantly change targeting or exclusion logic,
the capability should have a read-only preview path.

The preview should show:

- which hosts are in scope
- which hosts are excluded
- why each host is included or excluded
- what apply would do next

This is different from generic Ansible check mode.

### 8. Apply is normal; reruns are expected

A mature playbook must assume reruns are normal.

That means:

- healthy state should no-op
- drifted or missing managed state should reconcile predictably
- in-progress work should be recognized and reported clearly
- the playbook should not feel fragile or “one-shot”

### 9. Operator output should explain decisions

Status lines should not be black boxes.

Parent lines should report the conclusion.
Child lines should show:

- what was checked
- what value was found

This is especially important for:

- eligibility
- reconcile decisions
- backup health
- storage candidate selection

### 10. Transitional safety rails are acceptable, but must be labeled as such

Sometimes we use temporary constraints during early rollout:

- `--limit first-target`
- extra playbook `when:` checks
- temporary host allowlists

These are acceptable only when:

- they are clearly recognized as transitional
- they are not mistaken for the mature end-state design
- they are later replaced with metadata-driven targeting and durable lifecycle
  intent

### 11. Improve the current milestone incrementally

Maturity work should happen where the project is already touching a capability.
The expected pattern is not to stop all work for a giant taxonomy rewrite.

When a milestone focuses on a concrete outcome, such as bringing
`network-server` up to the current `server-225` standard:

- improve the resources that are directly involved in that milestone
- rename or reshape playbooks only when the current capability needs it
- move static or server-specific patterns toward host intent and derived groups
- leave unrelated playbooks for later passes unless they block the milestone
- make the improved pattern easy to copy during the next milestone

This keeps the work within reach while still moving away from early static and
server-specific implementation patterns.

## Maturity Scale

Use this five-level scale when grading a capability:

### Level 0: Ad hoc

- one-off commands or scripts
- no lifecycle model
- no real preview
- no durable targeting logic

### Level 1: Early scaffold

- a playbook or role exists
- some desired-state modeling exists
- still heavily dependent on narrow host targeting or temporary safety rails

### Level 2: Functional but transitional

- useful and repeatable
- has lifecycle state
- has some metadata or safety checks
- still has obvious maturity gaps or inconsistent design

### Level 3: Mature project-standard capability

- broad execution surface
- phase/capability-oriented playbook shape
- metadata-driven eligibility
- host intent drives derived execution groups
- lifecycle state is intent, not enrollment
- resource-level safety checks are strong
- reruns are normal and understandable

### Level 4: Strongly mature and portable

- consistent with other capabilities
- excellent operator output
- low ambiguity in decisions
- easy to reuse across multiple similar capabilities

### Level 5: Reference implementation

- should be copied as the model for future capabilities
- strong enough to anchor project standards directly

## AI Evaluation Contract

An AI evaluating a playbook or role against this document should answer these
questions explicitly:

1. What is the execution surface?
2. Is the playbook phase/capability-oriented or server-named?
3. What host intent is the source of truth?
4. Which execution groups are derived from host intent?
5. What inventory metadata determines eligibility?
6. What derived policy decides whether the capability should manage the host?
7. What lifecycle variable expresses intent?
8. Is lifecycle state being used as intent or as hidden enrollment?
9. What resource-level safety checks exist?
10. Is there a preview-first validation path?
11. Are reruns safe and understandable?
12. Does the operator output explain decisions with checked values?
13. Which safety rails are transitional versus durable?
14. What maturity level from 0 to 5 best fits this capability?

## AI Output Template

When grading a capability, prefer this output shape:

### Capability

- name
- playbook
- primary role

### Maturity Grade

- level: `N / 5`
- confidence: `high | medium | low`

### Strong Areas

- flat list of concrete strengths

### Gaps

- flat list of concrete maturity gaps

### Transitional Safety Rails

- flat list of things that are acceptable now but should be replaced later

### Recommended Next Maturity Step

- one small next step
- one medium structural next step

## Lightweight Capability Checklist

Use this as a fast pass before deeper grading:

- broad execution surface exists
- playbook is phase/capability-oriented rather than server-named
- host intent is declared in host_vars or inventory data
- execution groups are derived with `group_by` or equivalent
- eligibility is metadata-driven
- derived capability policy exists
- lifecycle state exists
- lifecycle state is not being used as hidden enrollment
- preview exists for risky targeting logic
- resource-level safety checks exist
- reruns are designed as normal
- operator output explains why decisions were made
- temporary safety rails are labeled as temporary

## Current Project Direction

These are the main project-standard patterns currently being pushed forward:

- broad capability surfaces such as `windows_hosts`
- phase/capability-oriented playbooks instead of server-named playbooks
- host intent in `host_vars`, such as `runtime_planes`, `node_classes`,
  `workloads`, and policy classes
- derived execution groups using `group_by` as the bridge toward NetBox or
  constructed inventory
- metadata-based host classification
- derived capability policy such as `*_should_manage`
- `present|absent` lifecycle state
- read-only preview before first or risky mutation
- resource-level safety checks for storage and backup
- operator-readable summaries with explicit checked values

These are the main refactors still expected:

- reduce dependence on narrow inventory groups as the real targeting model
- stop hand-maintaining runtime groups that can be derived from host intent
- rename server-specific playbooks when the touched capability already applies
  to more than one host
- stop using lifecycle-state existence as a hidden enrollment switch
- derive capability-targeting policy from mature metadata rather than transport
  cues or host-name-specific enrollment
- align newer and older capabilities to the same maturity standard
- make incremental improvements inside the current milestone rather than
  forcing an unrelated whole-project rewrite

## Update Rule

Whenever we learn something better than what is written here:

- update this document
- treat the update as the new report-card standard
- use future capability work to move closer to the updated standard

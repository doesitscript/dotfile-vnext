# Architecture Rules and Governance

## Core Principles

1. **Legacy Contract Is Scaffold, Not Live Authority**
   - `contracts/fuzlang.contract.yaml` is retained as early-project scaffold
     context, not as the live authoritative runtime source
   - Current decisions should be traceable to active inventory, promoted docs,
     and current playbooks/roles
   - No services, ports, or secrets should be added from stale scaffold notes
     without promoting current truth into the active repo surfaces

2. **Dual Surface Model**
   - Every Windows host has a `-win` surface managed by WinRM
   - Every Docker-in-WSL host has a `-wsl` surface managed by SSH (or wsl-command wrapper)
   - Windows roles must never run docker compose
   - WSL roles must never install Windows features or touch firewall/scheduler

3. **No Architectural Guessing**
   - If a step violates any checkpoint rule, agents must stop and report
   - Contract may be refined, but not re-imagined
   - Each checkpoint must satisfy:
     - Clear start state
     - Clear stop state
     - Limited file surface area
     - No architectural guessing

4. **Surface Boundary Enforcement**
   - Windows roles: WinRM + PowerShell only
   - WSL roles: SSH + Bash only
   - No mixing of Windows modules into Linux tasks or vice versa
   - New variables always come from contract or group_vars, not hardcoded

5. **Authority Boundaries**
   - Only network_node is authoritative for state
   - Only Ansible modifies server configuration
   - mac_dev_node is disposable and non-authoritative
   - No cross-node authority drift

## Checkpoint Rules

### Checkpoint 1: Canonical Contract Consolidation
- **DO**: Merge, normalize, deduplicate contract information
- **DO NOT**: Re-imagine the contract or add new services

### Checkpoint 2: Repo Skeleton + Governance Rails
- **DO**: Create full directory tree, empty placeholder files, architecture rules
- **DO NOT**: Implement roles, write playbook logic, or add variables beyond placeholders

### Checkpoint 3: Inventory & Node Surfaces
- **DO**: Implement dual-surface model (`-win` and `-wsl` hosts)
- **DO NOT**: Add role logic or hardcoded secrets

### Checkpoint 4: Playbook Wiring
- **DO**: Define execution flow with correct hosts/groups and role ordering
- **DO NOT**: Add task logic, shell commands, or modules yet

### Checkpoint 5: Common Baseline + Verification
- **DO**: Create lowest-risk shared automation (timezone, host identity, node facts)
- **DO NOT**: Install services or touch complex systems

### Checkpoint 6: Windows Host Bootstrap
- **DO**: Make Windows hosts structurally ready (WSL, SSH, firewall skeletons)
- **DO NOT**: Add docker compose or Linux logic

### Checkpoint 7: Linux / WSL Runtime Layer
- **DO**: Establish steady-state runtime environment (docker engine in WSL, compose support)
- **DO NOT**: Change Windows features or guess ports

### Checkpoint 8: Stack Deployment Per Role
- **DO**: Bring up only declared services from contract
- **DO NOT**: Add cross-node drift, new services, or port guessing

### Checkpoint 9: Secrets & Rendering Pipeline
- **DO**: Eliminate manual configuration (rendered .env files, vault separation)
- **DO NOT**: Print secrets or duplicate across scopes

## Node Classification Pattern

Playbooks that deploy tooling to a subset of nodes use `node_purpose` + Ansible's
`group_by` module for runtime host classification. This avoids static host lists in
inventory and avoids `hosts: all` with runtime pre_task filters.

### How it works

1. A "classify" play runs against `hosts: all` with `gather_facts: false`. It calls
   `group_by` to create a dynamic group from each host's `node_purpose` variable:
   ```yaml
   - ansible.builtin.group_by:
       key: "node_purpose_{{ node_purpose | default('unclassified') }}"
   ```
2. A "deploy" play targets `hosts: node_purpose_<value>` — populated by step 1.
3. `node_purpose` is declared in the physical node's `group_vars/<node>.yaml` and
   applies to all surfaces (-win and -wsl) of that node.

### Adding a new node to a purpose group

Set `node_purpose: development` (or the appropriate value) in the node's
`group_vars` file. No changes to playbooks or inventory groups are required.

### Rules

- `node_purpose` drives playbook targeting. `node_role` is a descriptive label only.
- Do NOT use tags (e.g. `--tags dev`) for node classification. Tags are for role
  tasks and specific purposes within a role, not for selecting which hosts to target.
- Do NOT use `hosts: all` with a pre_task runtime filter as a substitute for this
  pattern. That is an anti-pattern — the filter belongs in inventory, not in tasks.
- The schema for all valid `node_purpose` values is documented in
  `inventory/group_vars/all.yaml`.

## Capability Targeting Policy Pattern

For capability-specific targeting, use a two-layer model:

1. host metadata describes what the host is
2. derived capability policy decides whether that capability should manage the host

The preferred mental model is:

- metadata answers: "What kind of host is this?"
- derived policy answers: "Should this capability even consider this host?"
- lifecycle state answers: "If the capability manages this host, should it be
  present or absent?"

### Preferred shape

- metadata describes the host category
- dynamic grouping or equivalent derives capability-specific target groups
- only then does lifecycle state control `present|absent`

### NetBox-aligned metadata model

Prefer host-description attributes that map cleanly to NetBox concepts:

- device role
- platform
- status
- site
- location
- tenant
- tags
- custom fields

Repo-local inventory may use its own variable names, but the design should stay
close to this model so later NetBox adoption does not require rethinking how
capability targeting works.

### Derived capability policy

Prefer a derived policy variable or dynamic-group concept such as:

- `<capability>_should_manage: true|false`

Examples:

- `windows_server_backup_should_manage`
- `windows_driver_backup_should_manage`
- `windows_managed_service_data_backup_disk_should_manage`

These are derived policy results, not hand-set per-host enrollment flags. They
should come from metadata and policy logic, not from explicit host naming.

### Anti-patterns

Do not:

- use `present|absent` or variable existence as the hidden enrollment switch
- treat transport details like WinRM/SSH or OS-family-only markers as the main
  business-policy signal
- rely on static host-name allowlists as the real targeting model
- use one weak cue like "unattended" as the primary eligibility rule

## Failure Signals

If any of these occur, stop and report:
- Cursor adds Docker Desktop, Kubernetes, or random services
- Cursor opens ports broadly without contract authorization
- Cursor mixes WinRM modules into Linux tasks or vice versa
- Cursor adds variables not from contract or group_vars
- Cursor creates services not declared in contract
- Cursor guesses values instead of using placeholders

## Success Criteria

- A human can answer "what runs where, how, and why" by reading only the YAML contract
- No contradictory statements remain across docs
- Each physical node is reachable in the correct way
- No ambiguity about which surface runs which tasks
- A reader can understand lifecycle: bootstrap → deploy → verify
- Nothing can accidentally run on the wrong surface


# Architecture Rules and Governance

## Core Principles

1. **Contract is Authoritative**
   - All decisions must be traceable to `contracts/fuzlang.contract.yaml`
   - No services, ports, or secrets may be added without contract update
   - Any ambiguity must be left as a placeholder in the contract, not guessed

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




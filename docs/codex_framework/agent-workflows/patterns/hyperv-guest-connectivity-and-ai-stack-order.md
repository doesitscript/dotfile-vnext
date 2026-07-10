---
status: trial
owner: codex-framework
applies_to:
  - Hyper-V guest connectivity continuity
  - routed guest subnet reproduction
  - AI stack dependency sequencing
---

# Hyper-V Guest Connectivity And AI Stack Order

## Purpose

Give the AI a durable, repo-native order of operations for reproducing routed
Hyper-V guest connectivity and then layering the AI stack on top without
guessing which playbooks to run next.

## Triggers

Use this pattern when:

- the task is to restore or reproduce access to Hyper-V Ubuntu guests on
  `192.168.137.0/24` or `192.168.138.0/24`;
- the user asks how connectivity currently works across the Windows host,
  guest subnet, Mac controller, and LAN;
- the AI is about to run AI-stack playbooks that assume the guest networking
  foundation already exists;
- the repo needs a repeatable order rather than one-off chat instructions.

## Roles

### Researcher

- Confirms current host vars, router SSOT, and connectivity posture before
  apply.
- Reads diagnostics docs and verifies whether each lane is NAT-enabled or
  routed-only.
- Must not invent router or subnet state from memory.

Handoff artifact: concise evidence summary with the current lane posture.

### Executor

- Applies the ordered connectivity chain or the downstream AI stack chain.
- Uses the narrow connectivity entrypoint before higher-layer AI services when
  guest reachability is part of the objective.
- Preserves state-based lifecycle variables and avoids ad hoc host surgery.

Handoff artifact: ordered apply/verify notes plus changed-file list when repo
surfaces are updated.

### Validator

- Confirms the playbook order was followed and that prerequisite gates were not
  skipped.
- Checks that external router dependencies are called out when required.
- Sends work back if the AI jumps straight to LiteLLM/Langfuse/K3s service
  playbooks while guest connectivity is still unverified.

Handoff artifact: signed or unsigned validation note.

## Parallel Work

These can run in parallel:

- read-only repo searches over host vars, router SSOT, and diagnostics docs;
- live SSH probes against guest VMs;
- read-only target previews for Windows hosts and guest VM wrappers;
- review of existing umbrella playbooks such as `site.yaml` and
  `deploy_ai_inference_stack.yaml`.

## Serialized Work

The dependency order must stay explicit.

### Connectivity foundation order

Use this chain when reproducing or repairing guest reachability:

1. `playbooks/access_hyperv_foundation.yaml`
2. `playbooks/configure_hyperv_windows_hosts.yaml`
3. `playbooks/hyperv_ubuntu_docker_vm.yaml`
4. `playbooks/hyperv_ubuntu_k3s_vm.yaml`
5. `playbooks/hyperv_guest_route_mac.yaml`
6. `playbooks/homelab_hosts_file_mac.yaml`
7. `playbooks/homelab_hosts_file_linux.yaml`

Prefer the executable chain:

- `playbooks/hyperv_guest_connectivity_foundation.yaml`

Interpretation of each step:

- `access_hyperv_foundation.yaml` ensures controller keys, Windows OpenSSH, and
  generated SSH config surfaces exist before later steps depend on them,
  without prematurely refreshing mac guest routes or K3s client state.
- `configure_hyperv_windows_hosts.yaml` is the Windows host owner for routed
  guest subnet forwarding, guest gateway behavior, and `guest_published_tcp_ports`.
- `hyperv_ubuntu_docker_vm.yaml` and `hyperv_ubuntu_k3s_vm.yaml` ensure the
  intended guest VMs and their static guest-subnet identities are present.
- `hyperv_guest_route_mac.yaml` makes `mac-dev` reach the guest subnets through
  the owning Windows hosts.
- `homelab_hosts_file_mac.yaml` and `homelab_hosts_file_linux.yaml` publish the
  current name bridge on the operator and guest Linux surfaces after IP-level
  connectivity is in place, without pulling in optional Windows desktop hosts.

### Continuity Rules

Keep the sequence reproducible when future playbooks change:

- Prefer `playbooks/hyperv_guest_connectivity_foundation.yaml` as the operator
  and AI entrypoint instead of manually reassembling the order in chat.
- Keep controller and Windows access prerequisites in
  `playbooks/access_hyperv_foundation.yaml`; do not swap it back to
  `playbooks/access.yaml` unless early mac hosts-file refresh and K3s client
  work are intentionally part of the dependency chain.
- Keep Windows host networking ownership ahead of guest VM lifecycle wrappers,
  and keep controller routes plus hosts-file publication after the guest/network
  state they depend on.
- When adding a new prerequisite or validation step, insert it before the first
  consumer playbook, update both the executable chain and this workflow
  document, and rerun a read-only preview before the next mutating apply.

### Downstream AI stack order

Only after the connectivity foundation verifies cleanly, use the existing AI
stack entrypoint:

1. `playbooks/deploy_ai_inference_stack.yaml`

That entrypoint already preserves this service order:

1. `playbooks/windows_file_shares.yml`
2. `playbooks/deploy_gpu_infrastructure.yaml`
3. `playbooks/deploy_vllm_runtime.yaml`
4. `playbooks/deploy_litellm_gateway.yaml`
5. `playbooks/deploy_langfuse_platform.yaml`
6. `playbooks/validate_ai_agent_client_profiles.yaml`
7. `playbooks/validate_ai_inference_stack_contracts.yaml`

Use `site.yaml` only when the goal is broad active-lab convergence rather than
the narrower guest-connectivity reproduction path.

## Gates

### Lane Posture Gate

Required input: current host vars and router SSOT.

Required evidence:

- `guest_subnet_ipv4`
- `guest_gateway_ipv4`
- `guest_outbound_nat_enabled`
- router static-route rows when the lane is NAT-disabled

Pass condition: the AI can state whether each lane is routed-only or routed +
host-NAT.

Send-back condition: the AI describes both lanes as identical when current repo
truth differs.

Fallback: if live router state cannot be checked, rely on
`inventory/group_vars/all/homelab_router_gt6.yml` and say router mutation is
operator-owned.

### Connectivity Preview Gate

Required input: intended connectivity playbook chain.

Required evidence:

- `configure_hyperv_windows_hosts.yaml --tags hyperv_windows_host_preview`
- guest VM preview tags when guest lifecycle is in scope

Pass condition: selected hosts, guest subnets, and listen-address surfaces are
previewed before the first mutating run.

Send-back condition: the AI jumps directly to mutating apply after changing or
depending on host targeting or publication surfaces.

Fallback: if a preview tool fails, capture the failure and continue with the
best direct repo audit; do not silently skip the gate.

### External Router Dependency Gate

Required input: lane NAT posture.

Required evidence:

- router static-route SSOT row for NAT-disabled lanes
- explicit note that the repo does not currently manage the router

Pass condition: the AI calls out the router as an external prerequisite when
guest egress or whole-LAN reachability depends on it.

Send-back condition: the AI claims reproducible whole-LAN routed behavior from
repo playbooks alone when the router change is still operator-owned.

Fallback: where router state is unknown, downgrade the claim to
controller-reachable only.

### Downstream AI Stack Gate

Required input: successful connectivity foundation.

Required evidence:

- guest IP reachability from `mac-dev`
- Windows LAN publish surfaces or guest-hostname publication where relevant
- no unresolved guest-network prerequisite failure blocking K3s or service
  entrypoints

Pass condition: only then run `deploy_ai_inference_stack.yaml` or narrower AI
service playbooks.

Send-back condition: LiteLLM, Langfuse, Traefik, or client-profile playbooks
run before the guest-network foundation is verified.

Fallback: if the user explicitly scopes the work to a narrower playbook, state
which prerequisites are assumed rather than claiming end-to-end reproducibility.

## Artifacts

- `playbooks/hyperv_guest_connectivity_foundation.yaml`
- `playbooks/hyperv_guest_route_mac.yaml`
- `playbooks/access_hyperv_foundation.yaml`
- connectivity preview output
- router static-route SSOT rows in `inventory/group_vars/all/homelab_router_gt6.yml`
- downstream AI-stack validation outputs when the higher layer is in scope

## Completion Rule

The AI may report the connectivity path reproducible only when:

- the connectivity foundation order is followed or intentionally narrowed with
  assumptions stated;
- lane NAT posture and router dependency are stated accurately;
- previews or equivalent read-only evidence ran for changed targeting or
  publication logic;
- downstream AI services are reported only after the guest-connectivity
  foundation is verified or explicitly assumed.

## Failure Rule

It is not complete if:

- the AI skips the Windows host networking owner playbook and patches around it
  with one-off commands;
- the AI relies on `site.yaml` or service playbooks alone without showing how
  guest routing continuity is preserved;
- the router dependency for NAT-disabled lanes is omitted;
- the AI reports end-to-end AI stack reproducibility while guest connectivity
  or LAN publication is still unverified.

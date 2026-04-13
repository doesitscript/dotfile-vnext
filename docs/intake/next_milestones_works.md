# Next Milestones From Current Hyper-V Ubuntu Checkpoint

This note converts the earlier scratch planning into a durable milestone list
based on the current repo state.

It is intentionally practical:

- what is already fixed now
- what the next concrete milestones are
- what should be committed/tagged as capability checkpoints
- what still needs design clarification later

Companion current-state note:

- [hyperv-ubuntu-current-implementation-slice.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-current-implementation-slice.md)
  captures the current real working slice and its source-of-truth files.

## Current Stable-ish Checkpoint

Current repo checkpoint:

- canonical site entrypoint exists:
  - [site.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/site.yaml)
- fast VM-only loop exists:
  - [server_225_hyperv_ubuntu_vm_lifecycle_only.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm_lifecycle_only.yaml)
- active Linux companion surface exists:
  - `server-225-ubuntu`
- routed private subnet model is active
- Windows-side outbound NAT for the guest subnet is active
- guest address is currently:
  - `192.168.137.10/24`
- SSH reachability to the guest is working
- outbound internet from the guest is working
- `apt update` is working
- Docker Engine on the guest is working
- the Mac Docker client can reach the remote engine

Current stable checkpoint commit:

- `7fe9d39` `feat(orchestration): add canonical site entrypoint`

This is the current rollback target if later milestones break the VM path.

## What Is Fixed Now

- Multipass is no longer the active implementation path.
- Active WSL surfaces have been removed from the main runtime path.
- `server-225-win` is the Windows control surface.
- `server-225-ubuntu` is the active Linux companion surface.
- Ubuntu Server ISO + autoinstall is the working bootstrap path.
- The site-level orchestration path now exists.
- Specialized playbooks remain available for narrower loops.
- The guest can be redeployed through a focused VM lifecycle entrypoint.

## Current Constraints

These are the important limits of the current checkpoint:

- current working guest access now includes direct routed reachability from
  `mac-dev` to `192.168.137.10`
- generated SSH with `ProxyJump` via `server-225-win` remains available as a
  fallback
- the first direct-network target is now achieved as Mac-only routing to
  `192.168.137.0/24` through `192.168.50.158`
- whole-LAN routing remains the later milestone after the Mac-only route is
  proven
- some identity/bootstrap semantics should still be clarified more cleanly
- logging and other higher-level service consumers should be validated against
  the realized Ubuntu guest surface

## Immediate Next Milestones

### 1. Treat the current state as a capability checkpoint

For each meaningful improvement from here, create a new commit checkpoint with:

- a stability/capability-oriented message
- a clear description of what became newly true
- a short verification record in the relevant docs

This does not require Git tags immediately, but the commit history should make
rollback targets obvious.

### 2. Preserve the fast VM redeploy loop

This is already mostly in place and should remain the operator loop for guest
reinstall work:

- use [server_225_hyperv_ubuntu_vm_lifecycle_only.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm_lifecycle_only.yaml)
  for a fresh VM rebuild
- let the wider site playbook re-converge the rest of the stack idempotently

This means:

- VM rebuilds stay cheap
- the broader stack still has one desired-state entrypoint

### 3. Record the guest internet and package milestone as complete

This is now proven:

- DNS resolution works
- the guest can reach Ubuntu mirrors
- `apt update` works
- practical troubleshooting tools can be installed

Verification set already used:

```bash
getent hosts archive.ubuntu.com
curl -4 -I https://archive.ubuntu.com/
sudo apt update -o Acquire::ForceIPv4=true
```

### 4. Preserve dual access capability while keeping direct routed access primary

The current repo now has both:

- direct routed SSH to `192.168.137.10`
- generated SSH using `ProxyJump` through `server-225-win`

The current intended steady-state should stay:

- primary:
  - direct routed guest-IP access
- secondary/fallback:
  - generated SSH through `server-225-win`

### 5. Clarify bootstrap user vs runtime user

The project should keep the desired steady-state runtime user aligned with the
repo pattern:

- runtime user:
  - `joshc`

The bootstrap/install identity may still need its own clearer variable surface
if the implementation needs to preserve distro/default user behavior separately.

Current implementation already has a bootstrap-oriented variable:

- `hyperv_ubuntu_vm_bootstrap_user`

But this should be reviewed and made explicit if we need a clean separation
between:

- bootstrap/install identity
- fallback distro user
- steady-state runtime SSH user

### 6. Record Docker milestone as complete

This is now proven:

- Docker Engine installs on `server-225-ubuntu`
- the Mac Docker client can create and use the SSH-backed remote context
- Docker client verification reaches the guest engine successfully

Current proof point:

```bash
docker --context mac-dev info
```

### 7. Move on to higher-level services

The next real capability work is now above the VM/bootstrap layer:

- validate logging/Loki and other service consumers against
  `server-225-ubuntu`
- keep replacing old companion assumptions with the realized Ubuntu guest
  surface
- continue converging everything behind the canonical site playbook

## Documentation / Checkpoint Discipline

For each milestone from this point:

1. implement the capability
2. verify it with a small command set
3. update the relevant plan/diagnostics/readme notes
4. commit it as a clear capability checkpoint

Suggested milestone sequence from here:

1. current routed guest + remote Docker checkpoint
2. whole-LAN route milestone: router static route for `192.168.137.0/24`
   through `192.168.50.158`
3. validate higher-level service consumers against `server-225-ubuntu`
4. tighten bootstrap/runtime identity and companion-role ownership

## Notes For Future Cleanup

These are not blockers for the next milestone, but they should not be lost:

- make bootstrap identity vs runtime identity more explicit
- keep service ownership aligned with the real node role, not old legacy names
- continue moving toward one canonical site playbook with narrower operator
  entrypoints as helper surfaces only

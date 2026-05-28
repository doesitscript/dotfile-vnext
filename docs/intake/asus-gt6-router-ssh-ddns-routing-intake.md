# Intake: ASUS GT6 SSH, DDNS, and Routing Automation

**Status:** provisional intake - validate stock-firmware lane before scripting  
**Target device:** ASUS ROG Rapture GT6  
**Direction:** prefer stock ASUS features first; use Entware only if the stock
feature set cannot meet the automation goal

**Apply:** verify SSH, DDNS, routing, and script-hook support on the live GT6  
**Verify:** confirm which automation surfaces are real on stock firmware  
**Undo:** disable SSH, remove scripts, remove attached USB/Entware if used  
**Change class:** research and possible bootstrap follow-up, not yet steady-state automation

---

## Summary

The working idea is to avoid chasing unsupported custom firmware and instead
test whether the GT6 stock firmware already provides enough control for:

- SSH access
- dynamic DNS updates
- route or policy-routing changes

The current best-fit path is:

1. stock firmware only
2. stock firmware plus built-in hooks, if they exist
3. Entware only if the first two paths are insufficient

This note is intentionally plan-like, but it remains intake until the GT6
behavior is verified against the real device or official documentation.

## Current Repo Checkpoint

The upstream GT6 route layer is now operator-applied for both Hyper-V guest
subnets:

- `192.168.137.0/24 -> 192.168.50.158`
- `192.168.138.0/24 -> 192.168.50.234`

That means the router-side prerequisite for symmetric routed-subnet design is
now in place.

Repo-side behavior verification has already proven the GPU lane path:

- guest outbound internet works again from `hom-lab-ctl-dkr-02`
- `HyperVGuestNat` is absent on `hom-lab-ctl-hvh-02`
- direct access to `192.168.137.10` still works
- `hom-lab-ctl-k3s-02` is reachable on `192.168.137.11`

The remaining network convergence question is now host-side, not router-side:

- whether `hom-lab-ctl-hvh-01` is fully converged to routed private subnet with
  `guest_outbound_nat_enabled: false`
- whether active `192.168.138.x` guests behave symmetrically with the proven
  `192.168.137.x` lane

Current detailed state note:

- [asus-gt6-gpu-lane-router-current-state.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/asus-gt6-gpu-lane-router-current-state.md)

This means the router route milestone is no longer theoretical, and the next
high-value problem is proper service naming and DNS ownership rather than route
creation.

## Recommended Path

### Phase 1 - Validate stock capabilities

Confirm whether the GT6 stock firmware actually exposes:

- SSH enablement in the admin UI
- built-in DDNS provider support
- policy-routing features such as VPN Fusion
- any persistent script hook for custom DNS or route updates

If these exist and meet the need, stop here and avoid Entware.

### Phase 2 - Clarify the actual automation target

Before writing any scripts, decide which problem needs solving:

- dynamic public DNS update
- internal DNS override
- static route insertion
- policy routing for selected destinations or devices

This matters because a router UI feature may solve the problem without command
line changes.

For the current repo checkpoint, the next concrete target is:

- local DNS for LAN-wide service names such as `langfuse.hom.lab` and
  `litellm.hom.lab`

That step supports the Traefik/hostname path already discussed in the K3s
intake and service-identity planning work.

### Phase 3 - Evaluate limited scripting

If stock features are close but not enough, test whether the GT6 supports:

- custom DDNS update hooks
- scheduled scripts
- safe SSH-based inspection and command execution

Only pursue this if the hook surfaces are confirmed on stock firmware.

### Phase 4 - Entware fallback

Use Entware only if the router cannot meet the target through native features
or lightweight built-in hooks.

Possible Entware use cases:

- `curl` to external DNS APIs
- scheduled route or DNS-change scripts
- extra shell tooling for controlled automation

This is the most flexible path, but also the least proven in this intake note.

## Current Working Assumptions

- The GT6 does not appear to have a strong custom-firmware path worth planning
  around.
- Stock ASUS firmware may already cover part of the routing and DDNS use case.
- VPN Fusion may solve some route-selection problems more cleanly than manual
  route-table edits.
- Entware may be possible, but it should be treated as a fallback, not the
  starting architecture.

## Validation Targets

The prior rough AI pass claimed the following. These are the first items to
prove or disprove:

- SSH can be enabled from `Administration -> System`
- DDNS can be configured from `WAN -> DDNS`
- a custom DDNS hook may exist at `/jffs/inuse/ddns_custom_updated`
- VPN Fusion can cover some selective-routing use cases
- Entware or `amtm` may be usable on the GT6 without third-party firmware

The routed-subnet static-route milestone is already behavior-verified. The
remaining unverified router claims are mainly:

- router SSH availability on stock GT6 firmware
- router-side DNS record management path
- any stock-firmware script hook suitable for automation

## Decision Gate

Promote this intake into a real plan only if the validation pass shows at least
one of these is true:

- stock firmware alone can meet the DNS and routing requirement
- stock firmware plus built-in hooks can meet the requirement cleanly
- Entware is confirmed to be practical on this exact GT6 firmware lane

If none of those hold, the direction needs to change before planning further.

For the current checkpoint, the next promotion gate is narrower:

- local DNS record management path is proven manually or via router SSH
- repo ownership for those records is defined cleanly
- future router automation surface is clear enough to justify a real plan packet

## Open Questions

- Does stock GT6 firmware really expose a usable custom script hook?
- Are the needed route changes true static routes or really policy-routing?
- Is the DNS need public DDNS, internal DNS overrides, or provider API updates?
- Is Entware stable enough on this model to be worth carrying operationally?
- What exact SSH access path, if any, does the GT6 expose on stock firmware?
- Will LAN service names live on the router, a dedicated DNS authority, or a
  temporary host-managed fallback?

## Next Research Pass

Before implementation, verify:

- official ASUS GT6 documentation for SSH, DDNS, and routing features
- live GT6 admin screens for the claimed menus and toggles
- whether stock firmware supports persistent custom scripts
- whether Entware support on GT6 is documented, reproducible, and worth the added complexity

## Future Repo Surfaces (Stubbed Now)

The repo does not yet have router automation implementation, but the intended
surfaces are now clear enough to stub:

| Future surface | Intended use |
|---|---|
| `docs/diagnostics/asus-gt6-gpu-lane-router-current-state.md` | operator-applied current state and exact values |
| `docs/plans/2026-05-28--hyperv-routed-subnet-convergence-and-traefik-name-bridge/README.md` | official now-plan for symmetric routed-subnet convergence + current name bridge |
| `docs/intake/future-state-dns-authority-and-service-entry-architecture.md` | future-leaning DNS/service-entry pseudo-plan |
| `docs/plans/YYYY-MM-DD--asus-gt6-router-automation/README.md` | approved implementation packet once access path is proven |
| `playbooks/router_access_validate.yaml` | read-only router validation playbook |
| `playbooks/router_dns.yaml` | router local DNS management or validation |
| `roles/router_local_dns` | lifecycle management for DNS records |
| `roles/router_stock_ssh_access` | router SSH validation / access-layer role if supported |
| `inventory/host_vars/<router-host>.yaml` | router connection details and desired-state vars |

### Stub values to carry forward

```yaml
router_static_routes:
  - destination: "192.168.137.0"
    mask: "255.255.255.0"
    gateway: "192.168.50.158"
    metric: 1
    interface: "LAN"
  - destination: "192.168.138.0"
    mask: "255.255.255.0"
    gateway: "192.168.50.234"
    metric: 1
    interface: "LAN"

router_local_dns_records:
  - hostname: "langfuse.hom.lab"
    address: "192.168.50.158"
    owner: "k3s_traefik_routes"
    source_route_key: "langfuse-web"
  - hostname: "litellm.hom.lab"
    address: "192.168.50.158"
    owner: "k3s_traefik_routes"
    source_route_key: "litellm-gateway"

router_ssh_access:
  enabled: false
  host: null
  port: 22
  username: null
  authentication: null
```

These are documentation stubs only. They are not yet active inventory or role
inputs.

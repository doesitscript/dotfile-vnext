# macOS XProtect / Gatekeeper Friction Patterns

> **Status: brainstorming / evidence capture — NOT repo work**
>
> This packet archives live investigation findings from the mac-dev controller
> about XProtect Remediator vs Gatekeeper (`syspolicyd`) noise when running
> developer tooling. It is not approved implementation scope and not active
> automation behavior.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read this packet unless the task explicitly asks about macOS
  XProtect, Gatekeeper, quarantine, or CLI/tool launch friction on Mac.
- Treat disable/mitigation ideas as candidates until promoted through
  `docs/intake/` or `docs/plans/`.
- Do not infer that XProtect or Gatekeeper are already managed by Ansible
  from this packet.

## Packet Artifacts

| File | Role |
|------|------|
| [`macos-xprotect-gatekeeper-friction-plan.md`](./macos-xprotect-gatekeeper-friction-plan.md) | Investigation findings, process map, mitigation options, and later implementation backlog |
| [`.aiignore`](./.aiignore) | Local advisory context boundary for AI agents |

## Intended Use

Use this packet for later work around:

- distinguishing Remediator timer scans from Gatekeeper first-launch checks
- reducing friction for known-safe CLIs (Homebrew, HashiCorp, local builds)
- deciding whether any of this becomes a macOS controller capability
- capture/watch commands for future evidence collection

## Promotion Path

Move shaped, decision-ready material to `docs/intake/`. Move approved and
actionable work to a packet under `docs/plans/`.

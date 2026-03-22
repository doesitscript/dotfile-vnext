# Examples

## Example 1: Tunnelblick staged profile work

Use an issue because:
- the app install is done
- profile automation is staged
- the missing router export blocks implementation
- the work should survive beyond a README note

Suggested title:

`tunnelblick: import router OpenVPN profile on mac-dev`

Suggested labels:

- `type:capability`
- `state:blocked`
- `scope:tunnelblick`
- `area:ansible`
- `platform:macos`
- `topic:vpn`

Suggested body:

```md
Overview:
Track the next step for moving Tunnelblick on mac-dev from app-only automation
to a fully configured VPN capability.

Current state:
- Tunnelblick app install automation is working on macOS 12 Monterey
- staged profile metadata exists in `inventory/host_vars/mac-dev.yaml`
- secret home is prepared in `vault/mac_dev.vault.yml`
- local raw-export landing zone is `private/tunnelblick/`

Primary execution plan:
- add the exported client config
- decide whether to vault the `.ovpn` content or translate a `.tblk` bundle
- implement profile import and lifecycle handling in `roles/tunnelblick_mac`

Blockers / missing inputs:
- the router-exported client config (`.ovpn` or `.tblk`) is still missing

Definition of done:
- the role can install and remove the Tunnelblick profile declaratively
- the secret material is loaded from Vault instead of ad hoc local state

Pick-up references:
- `roles/tunnelblick_mac/README.md`
- `inventory/host_vars/mac-dev.yaml`
- `vault/mac_dev.vault.yml`
- `private/tunnelblick/README.md`
```

## Example 2: Hyper-V / Multipass replacement intake

Use an issue because:
- the repo already has massaged intake/planning material
- the work is broader than one local README note
- it is the kind of staged next-state work that benefits from backlog visibility

Suggested title:

`network-server: translate Hyper-V/Multipass intake into Ubuntu VM automation`

Suggested labels:

- `type:capability`
- `state:staged`
- `scope:network-server`
- `area:ansible`
- `platform:windows`
- `topic:vm`

Suggested body:

```md
Overview:
Track the translation of existing Hyper-V / Multipass intake material into an
actual Ubuntu VM automation path for this repo.

Current state:
- repo has intake/research material around replacing older WSL-oriented assumptions
- the likely direction is a fuller Ubuntu VM path via Hyper-V or Multipass-style workflow
- old WSL-era notes should be treated as translation/reference material, not direct implementation

Primary execution plan:
- review the current intake notes
- choose the VM/provisioning direction
- identify which older WSL steps translate cleanly into the new approach

Blockers / missing inputs:
- the target VM workflow has not been chosen and the actual provisioning path is not yet approved

Definition of done:
- the chosen VM approach is explicit
- the translated automation shape is documented
- obsolete WSL-specific assumptions are not driving new implementation

Pick-up references:
- `docs/intake/hyper-v-docker-modernized.md`
- `docs/intake/hyper-v-docker-modernized--implement-ideas.md`
- relevant role/node docs for network-server or server-225
```

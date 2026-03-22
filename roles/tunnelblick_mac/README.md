# tunnelblick_mac

Manages the deprecated Monterey-compatible Tunnelblick build on macOS.

This is a special-case role for older Macs. It does not use Homebrew. It pins the official deprecated Tunnelblick DMG for macOS 10.13 through macOS 12 and uses Tunnelblick's documented command-line installer.

## Why this role exists

Your current macOS version is Monterey (`12.7.6`). Current Tunnelblick releases require macOS 13 or later.

Tunnelblick still provides an official deprecated build for Monterey on its deprecated-downloads page:
- `Tunnelblick 3.8.8g`
- macOS `10.13-12`
- notarized
- released `2023-12-03`

Important warning:
- Tunnelblick marks this release as deprecated
- Tunnelblick says these older releases contain serious security vulnerabilities

This role is for compatibility on an older Mac, not because it is the preferred security posture.

## State interface

This role is modeled as a capability with state:

```yaml
tunnelblick_mac_state: present | absent
```

That is the preferred control surface for this role.

Because Tunnelblick's lifecycle is asymmetric, the implementation uses two internal paths behind one state variable:
- `present`: download, mount, install, verify
- `absent`: run Tunnelblick's bundled uninstaller, then verify removal

## What this role does

For `state: present`:
1. Downloads the pinned official DMG with a fixed SHA256 checksum.
2. Mounts the DMG.
3. Runs Tunnelblick's documented command-line installer with privilege escalation.
4. Verifies:
   - the app bundle exists
   - the installed version matches the pinned legacy version
5. Optionally performs a small stabilization pass for quarantine reassessment.

For `state: absent`:
1. Detects whether Tunnelblick is installed.
2. Runs Tunnelblick's bundled uninstaller via `osascript`.
3. Verifies that `/Applications/Tunnelblick.app` is gone.

## Why this is a special case

This app fits the repo's legacy-app pattern:
- deprecated/legacy-compatible version
- older host OS
- installer path outside normal package-manager flow
- extra verification needed after install

The broader pattern is documented in:
- [docs/ansible/mac-homebrew-special-cases.md](/Users/joshc/develop/dotfile-vnext/docs/ansible/mac-homebrew-special-cases.md)

Despite that doc's name, the same layered approach applies here even though this role uses an official direct-download DMG instead of Homebrew.

## Success model

### Core install proof

This role treats install as proven only when:
- `/Applications/Tunnelblick.app` exists
- `CFBundleShortVersionString` matches the pinned legacy version (`3.8.8g`)

### Extra evidence

The role also reports:
- quarantine inspection via `xattr`
- security assessment via `spctl`
- code-signature verification via `codesign --verify`

These help distinguish:
- app not actually installed
- app installed but trust/stabilization still questionable

## Privilege model

The privileged part is the Tunnelblick installer itself.

For interactive present runs, use:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags tunnelblick_mac \
  --limit mac-dev \
  --ask-become-pass
```

The role mounts the DMG under a user-writable path in `/tmp`, not under `/Volumes`, so the normal user can prepare the mountpoint and only the installer step needs elevation.

To remove it:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags tunnelblick_mac \
  --limit mac-dev \
  -e tunnelblick_mac_state=absent
```

## Become password options

For one-off interactive runs, `--ask-become-pass` is still the cleanest path.

If you need an environment variable, Ansible supports:

```bash
export ANSIBLE_BECOME_PASS='your-password'
```

Legacy alias:

```bash
export ANSIBLE_SUDO_PASS='your-password'
```

That works, but it is weaker operational hygiene than a prompt or vaulted variable because the password can leak through shell history, process environment, or session logging.

This role is intentionally narrower than a generic DMG role because it is pinned to one official deprecated Tunnelblick build for Monterey.

## VPN profile staging

Tracked in GitHub issue [#3](https://github.com/doesitscript/dotfile-vnext/issues/3).

The app installation path is implemented. The VPN client-profile path is not.

This repo now stages the intended profile shape in:
- [inventory/host_vars/mac-dev.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/mac-dev.yaml)
- [vault/mac_dev.vault.yml](/Users/joshc/develop/dotfile-vnext/vault/mac_dev.vault.yml)
- [private/tunnelblick/README.md](/Users/joshc/develop/dotfile-vnext/private/tunnelblick/README.md)

Current staged values:
- profile name: `router-openvpn`
- remote address: `99.63.7.93`
- remote netmask: `255.255.255.255`
- password placeholder: `V7j________`
- temporary local secret env var: `TUNNELBLICK_MAC_ROUTER_OPENVPN_AUTH_PASSWORD`
- vault variable names:
  - `vault_tunnelblick_mac_router_openvpn_auth_username`
  - `vault_tunnelblick_mac_router_openvpn_auth_password`
  - `vault_tunnelblick_mac_router_openvpn_ovpn_content`

Important:
- the role does **not** consume those profile variables yet
- they exist so the repo captures where we are and how to resume
- the actual VPN profile import work is blocked on the missing router-exported
  client config (`.ovpn` or `.tblk`)

### What is still needed to finish Tunnelblick setup

To complete the VPN-profile side of this role, we still need:
- the router-exported OpenVPN client config (`.ovpn` or `.tblk`)
- the username, if the router-exported profile uses username/password auth
- any CA, client cert, client key, or TLS auth material if it is not embedded in
  the export
- a decision on the durable secret home

Recommended secret handling:
- short term: local `.envrc` or shell env using
  `TUNNELBLICK_MAC_ROUTER_OPENVPN_AUTH_PASSWORD`
- better long term: move the password into Ansible Vault under
  [vault/mac_dev.vault.yml](/Users/joshc/develop/dotfile-vnext/vault/mac_dev.vault.yml)

Recommended client-export handling:
- if the router exports a plain `.ovpn`, either:
  - place it temporarily at `private/tunnelblick/router-openvpn.ovpn`, or
  - copy its full text into `vault_tunnelblick_mac_router_openvpn_ovpn_content`
- if the router exports a `.tblk` bundle or zip archive, place it temporarily in
  `private/tunnelblick/` first so we can inspect and translate it cleanly

Once the router export is available, the next improvement should be to make the
profile itself a stateful capability behind the same lifecycle pattern as the
app:

```yaml
tunnelblick_mac_profiles:
  - name: router-openvpn
    state: present
```

## Where we left off

Tracked in GitHub issue [#3](https://github.com/doesitscript/dotfile-vnext/issues/3).

This is the current pickup point for future work:
- Tunnelblick app install automation is working on macOS 12 Monterey
- profile metadata is staged in `inventory/host_vars/mac-dev.yaml`
- Mac-specific secret placeholders live in `vault/mac_dev.vault.yml`
- the ignored local landing zone for raw client exports is `private/tunnelblick/`
- the missing blocker is the router-exported client config (`.ovpn` or `.tblk`)
- the role does not yet import or manage VPN profiles

If you ask later "where did we leave off on Tunnelblick?", the short answer is:
- app install is done
- profile automation is staged but blocked on the missing client export
- the next implementation step is to consume `tunnelblick_mac_profiles` plus
  `vault/mac_dev.vault.yml` and render/import the actual profile

## Defaults

| Variable | Default |
|---|---|
| `tunnelblick_mac_download_url` | `https://tunnelblick.net/iprelease/Tunnelblick_3.8.8g_build_5779.3.dmg` |
| `tunnelblick_mac_expected_version` | `3.8.8g` |
| `tunnelblick_mac_app_path` | `/Applications/Tunnelblick.app` |
| `tunnelblick_mac_state` | `present` |
| `tunnelblick_mac_verify_install` | `true` |
| `tunnelblick_mac_verify_absent` | `true` |
| `tunnelblick_mac_attempt_stabilization` | `false` |

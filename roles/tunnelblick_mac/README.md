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

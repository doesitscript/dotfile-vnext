# remote_desktop_mac

Installs **Microsoft Remote Desktop** on macOS via a community-maintained Homebrew mirror.

---

## Why this tap exists

Microsoft's official Remote Desktop app on the Mac App Store dropped support for **macOS 12 Monterey** — the version running on this machine (`macOS 12.7.6 Monterey`). The official Homebrew cask (`microsoft-remote-desktop`) also targets only current macOS releases.

The [`junian/homebrew-mirrors`](https://github.com/junian/homebrew-mirrors) tap is a **community-maintained** mirror that preserves older formula/cask builds, including `microsoft-remote-desktop-for-macos12`.

> ⚠️ **This is not an official Microsoft distribution.**
> Validate the tap and formula before deploying in a production or shared environment.

---

## What this role does

1. Taps `junian/homebrew-mirrors` via `community.general.homebrew_tap`.
2. Uses `brew fetch --cask` as the normal user to obtain the pkg-backed installer artifact.
3. Runs the macOS `installer` command with Ansible privilege escalation for the actual pkg install step.
4. Prints a colorful notice to the console before installing so the operator is aware of the community-mirror origin.
5. Optionally imports exported Windows Remote Desktop leaf certs into the System keychain (stops the LAN cert nag).
6. Optionally upserts standard-named MSRDC bookmarks + Keychain password for `joshc` (from `vault_windows_house_remoting_password`).

This role is **macOS-only**. It skips on all other platforms.

### LAN connections + cert trust

Use the dedicated playbook (Windows export play + Mac configure play):

```bash
ansible-playbook playbooks/remote_desktop_mac_lan.yaml \
  -i inventory/inventory.yaml \
  --ask-become-pass
```

Bookmark names match inventory hostnames (`HOM-LAB-HVH-02`, …). Connection
hostnames use the RDP certificate CN so name checks match. `/etc/hosts` aliases
are added for CN → LAN IP when needed.

This app is a special case:
- community-maintained source
- deprecated/legacy macOS compatibility path
- pkg-based install rather than a straightforward `.app` cask drop

Because of that, this role treats success in layers instead of assuming Homebrew alone proves installation.

---

## Target OS

| OS | Supported |
|---|---|
| macOS 12 Monterey | ✅ |
| Other macOS versions | ⚠️ Formula may not match |
| Linux | ✗ Not targeted |
| Windows | ✗ Not targeted |

---

## Usage

Include the role in a playbook that targets `mac_dev` or any macOS host:

```yaml
- hosts: mac_dev
  roles:
    - remote_desktop_mac
```

## Success Model For This Role

For this special-case app, installation success is evaluated in layers.

### Core install proof

The role now checks:
- the `.app` bundle exists at the expected path
- the pkg receipt exists

If either of those is missing, the role treats install as not yet proven successful.

Homebrew state is still reported as useful evidence, but it is no longer the blocking success gate for this role because the current install path uses `brew fetch` plus a direct pkg install.

### Extra evidence for pkg-based installs

The role also collects:
- pkg receipt presence via `pkgutil`
- quarantine inspection via `xattr`
- security assessment via `spctl`
- code-signature verification via `codesign --verify`

These help distinguish:
- install presence problems
- trust/stabilization problems after install

This means a run can be a partial success:
- install may succeed
- core install proof may pass
- one or more stabilization checks may still be red at the end

For this role, that should be treated as "installed, but still needs trust/stabilization follow-up" rather than "not installed at all."

In practice:
- green install proof means app bundle and pkg receipt agree
- red stabilization checks after that mean the app is installed but still needs trust/remediation follow-up

### Optional stabilization

This role includes optional post-install stabilization tasks for this app:
- remove quarantine recursively
- apply ad hoc deep signing
- reassess with `spctl`

They are disabled by default because they may require elevated permissions and are not appropriate for every install.

Variables:

```yaml
remote_desktop_mac_attempt_stabilization: false
remote_desktop_mac_enforce_stabilization: false
remote_desktop_mac_stabilization_become: false
```

If you enable stabilization for a local `/Applications` install, you may also need privilege escalation.

## Important Privilege Note

Do not run the Homebrew cask install for this role as root and do not fix it with playbook-level `become` on the Homebrew task.

Why:
- Homebrew refuses to run as root
- this cask is pkg-backed, so the privileged part is the macOS installer step, not Homebrew itself

The current role uses a split install path:
- Homebrew fetches the pkg as the normal user
- Ansible runs `/usr/sbin/installer` with `become` for the privileged pkg step

For interactive runs, use:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --tags remote_desktop_mac \
  --limit mac-dev \
  --ask-become-pass
```

This is different from `become: true`:
- `become: true` on Homebrew itself makes Homebrew run as root, which fails
- the split path keeps Homebrew non-root and elevates only the pkg installer step

## Deprecated / Special Instructions Pattern

This role is also the current example of a broader pattern:
- deprecated or legacy-compatible app
- community-maintained source
- pkg-based install artifact
- extra verification or remediation needed after package-manager install

That pattern should live in Ansible role docs and Ansible-side helper guidance, not in the generic Codex framework.

See [docs/ansible/mac-homebrew-special-cases.md](/Users/joshc/develop/dotfile-vnext/docs/ansible/mac-homebrew-special-cases.md).

Future macOS/Homebrew roles with similar behavior should reuse that pattern doc instead of re-explaining the whole model inside each role README.

## Old Mac Operational Note

On older Macs, automatic operating-system or App Store update behavior can become part of the risk surface for legacy-compatible apps.

For machines like this one, it can be reasonable to treat automatic updates as an explicit operator choice rather than a default assumption. That is separate from this role's install logic, but worth documenting when the host is intentionally pinned to an older macOS release.

---

## Dependencies

- `community.general` collection (provides `homebrew_tap` and `homebrew_cask` modules)
- Homebrew installed on the target Mac (`/opt/homebrew/bin/brew` or `/usr/local/bin/brew`)

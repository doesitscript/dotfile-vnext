# macOS Homebrew Special Cases

This note is for Ansible-side installation patterns on macOS when a role cannot be treated like a normal Homebrew app install.

Despite the filename, some legacy-app cases may skip Homebrew entirely and use an official deprecated DMG or other direct-download path. The same layered thinking still applies.

It is not part of the generic Codex framework. It exists so edge cases stay close to Ansible role design instead of bloating the cross-project framework layer.

## When To Use This Pattern

Use special-case handling when an app has one or more of these traits:
- deprecated or legacy-compatible build
- community-maintained tap or mirror
- pkg-based install artifact instead of a straightforward `.app` cask layout
- extra post-install trust or stabilization work on macOS
- known mismatch between what Homebrew reports and what actually lands on disk

## Recommended Role Structure

For these roles, separate the work into three layers:

1. install
   tap/cask/pkg actions
2. verify
   prove what is really present on disk and in package-manager state
3. stabilize
   optional remediation steps for trust, quarantine, signing, or other special handling

And expose the capability itself as state whenever possible:

```yaml
role_name_state: present | absent
```

If install and uninstall are asymmetric, keep the interface state-based anyway and hide the asymmetry behind separate internal present/absent task paths.

## Quick Decision Guide

Use this quick sort before writing or changing a macOS/Homebrew role:

- normal cask app
  Homebrew cask is expected to install a normal `.app` bundle and that bundle is the main success signal
- tap plus cask app
  A custom tap is required, but install success is still mostly normal once the cask is available
- pkg-backed cask
  Homebrew reports install state, but the real artifact may be a pkg receipt and an app placed elsewhere by the installer
- post-install trust/stabilization app
  The app may be present, but quarantine, `spctl`, or code-signing state still needs to be checked separately
- deprecated or community-maintained legacy app
  Treat install, verification, and stabilization as separate layers and document the risk plainly

If the role falls into the last two categories, do not rely on package-manager state alone.

## Minimum Verification For Special-Case Apps

At minimum, report these separately:
- package-manager present: yes/no
- app-bundle present: yes/no

For pkg-based apps, also consider:
- pkg receipt present
- quarantine inspection
- `spctl --assess`
- `codesign --verify`

## Password And Privilege Handling

When a role needs privilege for only one part of the install path, do not guess.

Check the module or tool behavior first:
- does the module already support password passing
- does it shell out to another installer tool
- does Homebrew need to stay non-root while a later step needs elevation

For macOS/Homebrew special cases, prefer the narrowest correct privilege boundary:
- user-space fetch or package-manager preparation
- explicit elevated installer/remediation step only where needed

Do not default to root-running Homebrew just because the downstream installer needs privilege.

For Ansible specifically, thread privilege only into the task that actually needs it:
- do not escalate the whole playbook if only one installer step needs elevation
- do not escalate the package manager if only the downstream installer needs elevation
- prefer role/task design where the password requirement is attached to the exact step that consumes it

## Concise Patterns To Reuse

### Pattern A: Standard Homebrew cask

Use when a cask cleanly installs a normal app bundle.

Prove:
- cask present
- app bundle present

Usually no extra stabilization layer is needed.

### Pattern B: Tap plus cask

Use when the app comes from a non-default tap but still behaves like a normal cask install.

Prove:
- tap present
- cask present
- app bundle present

Document why the tap exists and whether it is official or community-maintained.

### Pattern C: Pkg-backed cask

Use when `brew` installs a pkg rather than dropping a normal app bundle directly.

Prove:
- cask present
- app bundle present
- pkg receipt present

Do not assume the app path until you verify where the installer actually placed it.

### Pattern D: Present but not trusted

Use when the app is on disk but launch/trust status is still questionable.

Inspect:
- `xattr`
- `spctl --assess`
- `codesign --verify`

Treat this as a stabilization problem, not an installation-presence problem.

### Pattern E: Official deprecated direct-download app

Use when the vendor still provides an older compatible release, but not through current package-manager channels.

Prove:
- the pinned official download URL is exact
- the checksum matches
- the app bundle lands at the expected path
- the installed version matches the pinned legacy release

If the vendor documents a supported command-line installer, prefer that over inventing a copy/mount flow from scratch.

## Why This Matters

For some macOS apps, "Homebrew says installed" is not enough.

The role should be able to distinguish:
- install presence failure
- app bundle placement problem
- post-install trust/stabilization problem

## Current Example

The active example in this repo is:
- [roles/remote_desktop_mac/README.md](/Users/joshc/develop/dotfile-vnext/roles/remote_desktop_mac/README.md)

That role uses community-maintained packaging for a legacy-compatible Microsoft Remote Desktop build on macOS 12 Monterey.

It currently demonstrates:
- tap + cask
- pkg-backed install
- layered verification
- optional stabilization

Another special-case pattern in this repo is:
- `roles/tunnelblick_mac`

That role demonstrates:
- official deprecated direct-download DMG
- checksum-pinned legacy release
- documented command-line installer
- layered verification without relying on Homebrew state

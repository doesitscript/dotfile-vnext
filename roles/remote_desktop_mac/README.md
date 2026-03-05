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
2. Installs the `microsoft-remote-desktop-for-macos12` cask via `community.general.homebrew_cask`.
3. Prints a colorful notice to the console before installing so the operator is aware of the community-mirror origin.

This role is **macOS-only**. It skips on all other platforms.

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

---

## Dependencies

- `community.general` collection (provides `homebrew_tap` and `homebrew_cask` modules)
- Homebrew installed on the target Mac (`/opt/homebrew/bin/brew` or `/usr/local/bin/brew`)

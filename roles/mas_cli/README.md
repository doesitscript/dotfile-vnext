# mas_cli

Installs the `mas` Mac App Store CLI on macOS.

## What this role does

1. Chooses an installer path that fits the current macOS release.
2. Uses Homebrew for newer macOS versions where that path is appropriate.
3. Uses the official `mas` package release on older macOS versions such as
   Monterey, where the latest Homebrew/core path is not a good fit.
4. Leaves App Store sign-in and app ownership to the current Mac user.

## Why this role exists

`Speech Central` is distributed through the Mac App Store. This repo prefers a
repeatable install surface, so the App Store CLI is managed separately from the
app-install role that uses it. On Monterey, this role avoids forcing a modern
Homebrew/swift build chain for `mas` and instead uses the official compatible
pkg release.

## Notes

- `mas` can install only apps that the signed-in Apple account already owns.
- The current `mas` major releases require newer macOS versions than Monterey.
- For Monterey and other legacy macOS versions, this role pins the official
  compatible pkg release and installs it with macOS `installer`.

## Variables

```yaml
mas_cli_install_method: auto
mas_cli_state: present
mas_cli_homebrew_formula_name: mas
mas_cli_homebrew_tap_formula_name: mas-cli/tap/mas
mas_cli_pkg_release_version_legacy: "4.1.2"
```

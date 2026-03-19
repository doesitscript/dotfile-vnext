# Microsoft Remote Desktop for macOS 12 — install verification and recovery

## What the current evidence proves
The latest checks show:

- package-manager present: yes
- app-bundle present: no

That means Homebrew believes the cask is installed, but the application bundle is not present at the expected path:

`/Applications/Microsoft Remote Desktop.app`

Because the bundle is missing, quarantine and `spctl` checks cannot yet be used to judge app trust or survivability. They fail only because there is no bundle to inspect.

## Immediate conclusion
Do not treat this as a post-install security-remediation problem yet.

Treat it first as an install-location / artifact-presence problem.

## What to do next
1. Reinstall the cask cleanly.
2. Immediately locate where the app bundle was actually placed.
3. If the bundle exists in a different location, report that path.
4. If the bundle does not exist anywhere obvious, treat the install as failed even if Homebrew reports it as installed.
5. Only after the bundle is found should post-install remediation be applied.

## Commands to run
### Reinstall cleanly
```bash
brew reinstall microsoft-remote-desktop-for-macos12
Check whether Homebrew still reports it installed
brew list --cask | grep -Fx "microsoft-remote-desktop-for-macos12"
Look for the actual app bundle
find /Applications ~/Applications -maxdepth 2 -name "Microsoft Remote Desktop.app" 2>/dev/null
Optional: inspect Homebrew cask metadata for install path clues
brew info --cask microsoft-remote-desktop-for-macos12
If the app bundle is found

Then run the stabilization steps against the real bundle path:

sudo xattr -dr com.apple.quarantine "/path/to/Microsoft Remote Desktop.app"
sudo codesign --force --deep --sign - "/path/to/Microsoft Remote Desktop.app"
spctl --assess --verbose "/path/to/Microsoft Remote Desktop.app"
If the app bundle is not found

Then the install is not actually successful, regardless of what Homebrew reports.

At that point, report:

cask reported installed by Homebrew

no .app bundle found in /Applications or ~/Applications

install must be treated as incomplete, hidden, redirected, or removed during/after install

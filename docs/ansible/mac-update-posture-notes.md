# macOS Update Posture Notes

This note exists for older macOS hosts where automatic updates may work against the stability of legacy-compatible applications.

It is not a rule for every Mac. It is a place to capture operator posture for older hosts.

## Why This Matters

On an older Mac, automatic updates can create drift in a few different ways:
- the OS may move in a direction the host is not meant to follow
- App Store updates may replace or remove a legacy-compatible application path
- support assumptions for community-maintained or deprecated app installs may change without warning

For that reason, update behavior on an older Mac should be treated as an explicit host-level decision.

## Current Relevance

This matters for roles like:
- `remote_desktop_mac`

where the application is:
- legacy-compatible
- community-maintained
- sensitive to install/remediation behavior on an older macOS host

## Suggested Handling

- document the desired update posture for the host
- do not assume automatic upgrades are wanted on older Macs
- keep app-specific mitigation in the role README when needed
- keep broader Mac posture notes here or in another Ansible-side doc, not in the generic Codex framework

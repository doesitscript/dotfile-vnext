# mac_user_niceties

Applies macOS controller-side quality-of-life preferences for noisy notifications and Notification Center widgets.

This role captures the notification changes from this session so they can be reapplied via Ansible instead of manual one-off terminal edits.

## What it does

- Disables notifications for selected app bundles by setting `auth=0` and `flags=0` in `com.apple.ncprefs.plist`.
- Clears Notification Center widget configuration in `com.apple.notificationcenterui.plist`.
- Restarts `usernoted`, `NotificationCenter`, and `cfprefsd` (optional) so the updated preferences are reloaded.

## Defaults

| Variable | Default |
|---|---|
| `mac_user_niceties_state` | `present` |
| `mac_user_niceties_disable_notification_bundle_ids` | `["com.apple.news", "com.apple.iCal", "com.apple.reminders", "com.apple.ScreenTimeNotifications", "com.apple.ScreenTimeEnabledNotifications"]` |
| `mac_user_niceties_clear_widgets` | `true` |
| `mac_user_niceties_restart_notification_services` | `true` |

## Tags

| Tag | Description |
|---|---|
| `mac_user_niceties` | Run all role tasks |
| `mac_user_niceties_notifications` | Notification bundle changes only |
| `mac_user_niceties_widgets` | Widget configuration reset only |

## Usage

Example local converge on your Mac execution node:

```yaml
- name: Development niceties for macOS controller
  hosts: node_purpose_development
  gather_facts: true
  roles:
    - role: mac_user_niceties
      tags: [mac_user_niceties]
```

Override bundle IDs when needed:

```yaml
mac_user_niceties_disable_notification_bundle_ids:
  - "com.apple.news"
  - "com.apple.reminders"
```

# speech_central

Installs `Speech Central` on macOS through the Mac App Store CLI.

> Speechify is the next paid App Store option planned for evaluation if Speech
> Central does not meet the read-aloud goal.

## What this role does

1. Checks whether `Speech Central` is already installed.
2. Uses `mas` to install or uninstall the app by App Store ID.
3. Verifies the requested final state through app-bundle and `mas list` checks.

## State interface

```yaml
speech_central_state: present | absent
```

The role name stays capability-focused. OS handling lives inside
`tasks/main.yml`, which currently dispatches only to macOS because that is the
only platform Speech Central targets in this repo.

## Important constraints

- `Speech Central` is a paid Mac App Store app.
- The signed-in Apple account must already own it before `mas install` can work.
- `mas` cannot purchase paid apps for you; that purchase must happen directly in
  the App Store first.
- `mas` requires elevated privileges for install and uninstall actions.
- This role declares a dependency on `mas_cli`, so the App Store CLI is
  installed before the app role runs.

## Privilege model

Privilege is threaded only into the `mas install` and `mas uninstall` tasks.
That matches the repo pattern used by other macOS installer roles.

For an interactive install run, use:

```bash
.venv/bin/ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml \
  --limit mac-dev \
  --tags speech_central \
  --ask-become-pass
```

If you prefer an environment variable for a one-off run, Ansible supports:

```bash
export ANSIBLE_BECOME_PASS='your-password'
```

## Variables

```yaml
speech_central_app_id: "1223093645"
speech_central_state: present
speech_central_verify_install: true
speech_central_install_timeout_seconds: 120
speech_central_app_bundle_candidates:
  - /Applications/Speech Central.app
  - "{{ ansible_env.HOME }}/Applications/Speech Central.app"
```

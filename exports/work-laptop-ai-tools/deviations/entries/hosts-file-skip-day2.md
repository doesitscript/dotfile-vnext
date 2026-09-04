---
id: hosts-file-skip-day2
status: accepted
behavior_group: sudo-hosts-file
title: Skip hosts_file on day-2 converge
---

## Trigger

- `homelab_hosts_file_mac` needs `--ask-become-pass`.
- Laptop hosts file already complete; day-2 churn hit sudo repeatedly.

## Accommodation

- Default day-2: `--skip-tags hosts_file`.
- Refresh hosts only when catalog names change: `--tags hosts_file --ask-become-pass`.
- Encoded in skill `work-laptop-day2-apply`.

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file
```

## Generalize

- Other bootstrap-once become tags on corporate Mac — document skip vs intentional refresh.

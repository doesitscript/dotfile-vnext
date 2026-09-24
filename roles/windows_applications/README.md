---
# windows_applications
#
# Resolve explicitly commissioned Windows application capabilities from host
# intent (`windows_applications`) against `policy/capability_catalog.yml` and
# host classification (`host_execution_roles`). Dispatch approved roles via
# `include_role` with `apply.tags`. Never scan `roles/` for application-like
# names.
#
# Apply / Verify / Undo / Change class
# - Apply: deploy_applications.yaml dispatches selected capability roles
# - Verify: orchestrator receipt + per-role `--tags verify` (mutate tags excluded)
# - Undo: remove capability ID from host intent and/or set role `*_state: absent`
# - Change class: idempotent orchestration; mutation lives in capability roles
#
# Playbook: playbooks/deploy_applications.yaml
# Site phase: playbooks/site.yaml → site_windows_applications

## Host intent

```yaml
windows_applications:
  - windows_steam_client
windows_steam_client_state: present
```

## Filter (Steam recovery wrapper)

```yaml
windows_applications_filter:
  - windows_steam_client
```

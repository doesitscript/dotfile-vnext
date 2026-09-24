# infracost_cli

Manage Infracost CLI via Homebrew on macOS

## State interface

```yaml
infracost_cli_state: present | absent
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `infracost_cli` with state present |
| Verify | `[infracost, --version]` |
| Undo | `infracost_cli_state: absent` |
| Change class | idempotent configuration |

Authority: HRL `implementation-guides/terraform/terratest-progressive-test-suites.md`

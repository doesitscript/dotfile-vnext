# checkov_cli

Manage Checkov IaC scanner via Homebrew on macOS

## State interface

```yaml
checkov_cli_state: present | absent
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `checkov_cli` with state present |
| Verify | `[checkov, --version]` |
| Undo | `checkov_cli_state: absent` |
| Change class | idempotent configuration |

Authority: HRL `implementation-guides/terraform/terratest-progressive-test-suites.md`

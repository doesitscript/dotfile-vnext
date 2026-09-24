# gotestsum_cli

Manage gotestsum Go test reporter via Homebrew on macOS

## State interface

```yaml
gotestsum_cli_state: present | absent
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `gotestsum_cli` with state present |
| Verify | `[gotestsum, --version]` |
| Undo | `gotestsum_cli_state: absent` |
| Change class | idempotent configuration |

Authority: HRL `implementation-guides/terraform/terratest-progressive-test-suites.md`

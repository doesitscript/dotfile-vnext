# tflint_cli

Manage TFLint CLI via Homebrew on macOS

## State interface

```yaml
tflint_cli_state: present | absent
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `tflint_cli` with state present |
| Verify | `[tflint, --version]` |
| Undo | `tflint_cli_state: absent` |
| Change class | idempotent configuration |

Authority: HRL `implementation-guides/terraform/terratest-progressive-test-suites.md`

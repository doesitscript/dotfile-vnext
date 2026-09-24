# terraform_docs_cli

Manage terraform-docs via Homebrew on macOS

## State interface

```yaml
terraform_docs_cli_state: present | absent
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `terraform_docs_cli` with state present |
| Verify | `[terraform-docs, version]` |
| Undo | `terraform_docs_cli_state: absent` |
| Change class | idempotent configuration |

Authority: HRL `implementation-guides/terraform/terratest-progressive-test-suites.md`

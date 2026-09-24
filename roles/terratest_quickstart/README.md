# terratest_quickstart

Deploys a Hello-World Terratest scaffold and pulls Go modules for Terratest
plus `testify`.

Based on Context7 docs for `/websites/terratest_gruntwork_io` and the HRL
progressive suites guide complementary toolchain:

- Requirements: Go + Terraform (or OpenTofu) installed
- Layout: `examples/` + `test/`
- Init: `go mod init`, `go get` Terratest + testify, `go mod tidy`
- Run: `go test -count=1 -v -timeout 30m`

## State interface

```yaml
terratest_quickstart_state: present | absent
```

## Variables

```yaml
terratest_quickstart_state: present
terratest_quickstart_root: "{{ ansible_env.HOME }}/Documents/develop/terratest-quickstart"
terratest_quickstart_module_path: github.com/doesitscript/terratest-quickstart
terratest_quickstart_go_packages:
  - github.com/gruntwork-io/terratest@latest
  - github.com/stretchr/testify@latest
terratest_quickstart_verify: true
```

## Operations

| Action | How |
| --- | --- |
| Apply | Playbook tags `terratest` / `terratest_quickstart` with state present |
| Verify | `go list -m` for terratest and testify; optional `go test -count=1` |
| Undo | `terratest_quickstart_state: absent` |

## Related companion roles (same `terratest` tag)

`tflint_cli`, `checkov_cli`, `gotestsum_cli`, `terraform_docs_cli`,
`infracost_cli` (recommended present). See packet `TERRATEST.md`.

Run `golang_cli` and `terraform_cli` present in the same play before this role.

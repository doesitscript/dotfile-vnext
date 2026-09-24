# terratest_quickstart

Deploys a Hello-World Terratest scaffold on macOS and pulls the Terratest Go
module so you can run the first test immediately.

Based on Context7 docs for `/websites/terratest_gruntwork_io`:

- Requirements: Go >= 1.26, Terraform CLI
- Layout: `examples/` + `test/`
- Init: `go mod init`, `go get github.com/gruntwork-io/terratest@latest`,
  `go mod tidy`
- Run: `cd test && go test -v -timeout 30m`

## State interface

```yaml
terratest_quickstart_state: present | absent
```

## Variables

```yaml
terratest_quickstart_state: present
terratest_quickstart_root: "{{ ansible_env.HOME }}/Documents/develop/terratest-quickstart"
terratest_quickstart_module_path: github.com/doesitscript/terratest-quickstart
terratest_quickstart_go_package: github.com/gruntwork-io/terratest@latest
terratest_quickstart_verify: true
```

## Apply / Verify / Undo

| | |
| --- | --- |
| Apply | Playbook tags `terratest` / `terratest_quickstart` with state present |
| Verify | `go list -m github.com/gruntwork-io/terratest`; optional `go test -v -timeout 30m` |
| Undo | `terratest_quickstart_state: absent` |
| Change class | Bootstrap / semi-manual scaffold (tree under Documents/develop) |

## Prerequisites

Run `golang_cli` and `terraform_cli` present in the same play before this role.

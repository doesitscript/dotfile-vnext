# Terratest on the work Mac

Quick start for infrastructure tests with Terratest.

## What the packet installs

| Role | Purpose |
| --- | --- |
| `terraform_cli` | Terraform binary (Homebrew `hashicorp/tap/terraform`) |
| `golang_cli` | Go toolchain (Homebrew `go`) |
| `terratest_quickstart` | Hello-World scaffold + `go get` Terratest module |

Scaffold path: `~/Documents/develop/terratest-quickstart`

## Apply (after sibling pull)

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags terratest
```

Or use `scripts/recent_and_next.md` → Terratest grouped update.

## First test

```bash
cd ~/Documents/develop/terratest-quickstart/test
go test -v -timeout 30m
```

## Research basis (Context7)

Library: `/websites/terratest_gruntwork_io`

- Requirements: Go installed (docs cite >= 1.26)
- Layout: `examples/` + `test/`
- Init: `go mod init`, `go get github.com/gruntwork-io/terratest@latest`, `go mod tidy`
- Run: `go test -v -timeout 30m`
- Helpers: `terraform.WithDefaultRetryableErrors`, `InitAndApplyContext`,
  `DestroyContext`, `OutputContext`

Upstream: https://terratest.gruntwork.io/docs/getting-started/quick-start

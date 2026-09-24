# Terratest on the work Mac

Progressive Terraform / Terratest toolchain for the work-laptop packet.

Authority: HRL guide
`homelab-reference-library/implementation-guides/terraform/terratest-progressive-test-suites.md`.

There is **no Terratest CLI**. Terratest is a Go module run with `go test`.

## Work map — required + recommended

| Tier | Tool | Packet role / surface | Default state |
| --- | --- | --- | --- |
| Required | Terraform | `terraform_cli` | present |
| Required | Go | `golang_cli` | present |
| Required | Terratest | `terratest_quickstart` (`go get`) | present |
| Required | `testify` | `terratest_quickstart` (`go get`) | present |
| Recommended | TFLint | `tflint_cli` | present |
| Recommended | Checkov | `checkov_cli` | present |
| Recommended | `gotestsum` | `gotestsum_cli` | present |
| Recommended | `terraform-docs` | `terraform_docs_cli` | present |
| Recommended | Infracost | `infracost_cli` | present |

Capability catalog entry: `terratest` in
`group_vars/all/work_laptop_capabilities.yml`.

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
go test -count=1 -v -timeout 30m
# CI-style reporting once gotestsum is present:
gotestsum --junitfile test-results.xml -- -count=1 -timeout 30m ./...
```

## Static / security / docs / cost (recommended CLIs)

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
tflint --init && tflint --recursive
checkov -d . --framework terraform --quiet
terraform-docs markdown table --output-file README.md --output-mode inject .
infracost breakdown --path .
```

## Research basis

- HRL progressive suites guide (required + recommended complementary tools)
- Context7 / upstream: https://terratest.gruntwork.io/docs/getting-started/quick-start
- Helpers: `terraform.WithDefaultRetryableErrors`, `InitAndApplyContext`,
  `DestroyContext`, `OutputContext`; prefer `-count=1`, `-p 1` when suites
  share credentials or mutate shared fixtures

# Terratest quickstart (work Mac)

Scaffold managed by role `terratest_quickstart`.

## Prerequisites (packet playbook)

- `golang_cli_state: present` (Go >= 1.26)
- `terraform_cli_state: present`

## First run

```bash
cd ~/Documents/develop/terratest-quickstart/test
go test -v -timeout 30m
```

Authority: https://terratest.gruntwork.io/docs/getting-started/quick-start

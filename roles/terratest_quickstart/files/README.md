Scaffold managed by role `terratest_quickstart`.

Prerequisites (same play / `--tags terratest`):

- `golang_cli_state: present` (Go >= 1.26 preferred)
- `terraform_cli_state: present`
- Go modules: Terratest + testify

```bash
cd ~/Documents/develop/terratest-quickstart/test
go test -count=1 -v -timeout 30m
```

Authority: https://terratest.gruntwork.io/docs/getting-started/quick-start
Companion CLIs: see packet `TERRATEST.md` work map.

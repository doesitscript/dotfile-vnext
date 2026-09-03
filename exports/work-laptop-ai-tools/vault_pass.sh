#!/bin/bash
# Vault password script: print repo-root .vault_pass so Ansible can use it.
# Use this when .vault_pass has the execute bit set on a Windows mount (WSL cannot clear it).
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cat "$REPO_ROOT/.vault_pass"

# redhat-ansible-frozen

Frozen snapshot of the older Red Hat Ansible MCP build.

This role is kept for rollback/reference only. The live deployment role is
`roles/mcp_servers/redhat-ansible/`, which is pinned to the current upstream
release. Do not bump the frozen snapshot unless you are explicitly refreshing
the archive.

## Snapshot

- Upstream source: `ansible/vscode-ansible`
- Frozen pin: `v25.12.2`
- Intended status: reference only, not part of `playbooks/mac/mcp_servers.yaml`


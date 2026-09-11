---
id: continue-mcp-tool-execution-gap
status: accepted
behavior_group: continue-mcp-client
title: Continue may discover MCP resources without executing tools
---

## Trigger

- Inbox `2026-09-10-continue-mcp-working-configuration.md`
- Terraform MCP resources visible (`Terraform Module Development Guide`,
  `Terraform Style Guide`) but Continue responded with planned tool text and
  no `fetch_url_content` result

## Accommodation

- Treat **resource discovery ≠ tool execution** for Continue acceptance tests.
- Packet must not mark Terraform/AWS MCP “working” from catalog names alone.
- Acceptance: ask Continue to call a named tool (e.g. `fetch_url_content` with
  supplied URLs) and require a real tool result or explicit server error in the
  chat — not planning-only prose.
- Verify advertised tools (`fetch_url_content`,
  `terraform_mcp_get_module_details`, `terraform_mcp_get_provider_details`)
  and that the selected model/tool-use settings allow execution.
- This is a client/model boundary, not fixed by changing MCP server install
  paths alone.

## Re-apply

```text
In Continue: ask to call fetch_url_content for two HashiCorp doc URLs.
Pass only if chat shows tool result content or a server error receipt.
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Cline / other MCP clients | maybe | same discovery-vs-execution acceptance test |
| Any Continue MCP | yes | require tool result evidence |

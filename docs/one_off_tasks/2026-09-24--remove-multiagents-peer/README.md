# One-off request: remove live `multiagents-peer` MCP entry

- Date / target: 2026-09-24; mac-dev Cursor user MCP config
- Request and explicit authorization: User requested: “multiagents-peer, remove from mcp servers as a one off.”
- Reason: not specified
- Action and result: Removed only the live `multiagents-peer` key from `~/.cursor/mcp.json`; before SHA-256 `2d786df2a73d72bab888647a35cee3e6c47e15c6dc922fedb3e28ae41bff7e66`, after SHA-256 `1a855018d0cf034d350a7ef891390bfd75cfb035b532801d824c32f699771ec0`, remaining matching entries `0`.
- Remaining state: The Cursor role still owns and can redeploy this entry; a future reconciliation may restore it.
- Disposition: executed
- User decision on debt or deferral: One-off live removal authorized; no upstream removal authorized.
- Reconciliation or follow-up link: `roles/cursor/tasks/multiagents_mcp.yml`; rerun the Cursor MCP deployment to restore it.

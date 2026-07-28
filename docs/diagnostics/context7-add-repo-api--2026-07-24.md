---
title: Context7 add-repo API failure
document_type: diagnostics
status: draft
created_at: "2026-07-24"
tags:
  - context7
  - diagnostics
---

# Context7 `POST /v2/add/repo/github` failure (2026-07-24)

## Evidence

- `CONTEXT7_API_KEY` present (MCP env) — **search** `GET /api/v2/libs/search` returns 200.
- `POST https://context7.com/api/v2/add/repo/github` with Bearer key returns:

```json
{"error":"internal_error","message":"An error occurred while processing your request"}
```

HTTP **500** for:

- `https://github.com/langchain-ai/langgraph-101`
- `https://github.com/langchain-ai/langchain-academy`
- `https://github.com/doesitscript/dotfile-vnext` (`private: false`)
- `https://github.com/doesitscript/homelab-reference-library` (`private: true` + `gh auth token` as `gitToken`)

## Workaround

1. Repo roots now have `context7.json` (allowlisted folders, secrets excluded).
2. Submit via dashboard: https://context7.com/add-library or teamspace **Sources**.
3. After success, expected library ids:
   - `/doesitscript/dotfile-vnext`
   - `/doesitscript/homelab-reference-library`
   - `/langchain-ai/langgraph-101`
4. Re-run Context7 resolve + refresh HRL packs.

## Local completeness meanwhile

- langgraph-101 curriculum ingested into HRL from GitHub README (Firecrawl).
- HRL indexes rebuilt; Cursor skill `hrl-library-index-entry` opens indexes on demand.

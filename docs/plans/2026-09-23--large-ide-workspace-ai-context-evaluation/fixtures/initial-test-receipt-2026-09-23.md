# Initial reusable-fixture test receipt — 2026-09-23

## Fixture state

- Visible source fixture existed at `docs/ai-context-boundary-test-visible.md`.
- Excluded artifact fixture existed at `artifacts/ai-context-boundary-test/ignored-sentinel.txt`.
- The artifact fixture was Git-ignored and listed by `.cursorignore`.

## Codex native-search attempt

Result: `test-unsupported`.

The Codex session reported that no native workspace file/code search capability
was available. It correctly did not use shell, MCP, direct reads, or substitute
search methods. No sentinel was searched and no file content was exposed.

## User-reported Cursor search results

The user reported one result for each search:

- Visible result: `/Users/joshc/develop/dotfile-vnext/docs/ai-context-boundary-test-visible.md`
- Excluded result: `/Users/joshc/develop/dotfile-vnext/artifacts/ai-context-boundary-test/ignored-sentinel.txt`

The exact Cursor surface used for these two results was not recorded, so this
does not yet prove that Cursor native Search ignored the configured exclusion.
If these came from the Search panel, the result is unexpected because the
active workspace settings contain `search.exclude: {"**/artifacts/**": true}`;
repeat the test while recording whether the action was Search, Quick Open,
Agent context selection, or another surface.

## Interpretation

- The Codex attempt proves only that the requested native-search capability was
  unavailable in that session.
- The two Cursor paths prove that both fixture paths were surfaced somewhere,
  but not which indexing/search boundary surfaced them.
- Morph MCP remains unsuitable for proving Cursor exclusion because it is a
  separate MCP search surface and may use a stale index.

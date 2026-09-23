# Reusable AI-context boundary test fixture

This fixture is retained for repeatable comparison testing. It is intentionally
small and contains no secrets.

## Fixtures

| Class | Path | Sentinel | Expected policy |
|---|---|---|---|
| Visible source | `docs/ai-context-boundary-test-visible.md` | `AI_CONTEXT_BOUNDARY_VISIBLE_20260923` | Discoverable by ordinary source search |
| Excluded artifact | `artifacts/ai-context-boundary-test/ignored-sentinel.txt` | `AI_CONTEXT_BOUNDARY_IGNORED_20260923` | Excluded by `.cursorignore`, workspace search settings, and the temporary `.gitignore` rule |

Keep both files in place while repeating the test. Remove them after the test
campaign is complete; do not commit the temporary fixture.

## Important test rule

The test must name the search surface. Morph MCP, shell, `rg`, `find`, and
direct file reads do not prove Cursor native Search or Codex native search
behavior. If a client cannot expose its native search surface without those
tools, record `test-unsupported` rather than substituting another tool.

The multi-root workspace used during the initial test is:

`/Users/joshc/develop/dotfile-vnext.code-workspace`

Its current workspace-level settings include the same watcher, Explorer, and
search exclusions as the project settings, plus `search.useIgnoreFiles`,
`search.useGlobalIgnoreFiles`, and `search.useParentIgnoreFiles`.

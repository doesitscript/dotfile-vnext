# Native-search boundary test prompts

## Codex or Cursor agent prompt

```text
Run a controlled native workspace-search boundary test in this repository.

Do not use:
- shell commands;
- rg, find, grep, or git;
- Morph MCP;
- any other MCP server;
- direct file reads or manual path opening.

Use only the client’s native workspace file-search or code-search capability.

Search separately for these exact strings:

1. AI_CONTEXT_BOUNDARY_VISIBLE_20260923
2. AI_CONTEXT_BOUNDARY_IGNORED_20260923

Do not open the matching files. Report only:

- whether each string was found;
- the path returned, if any;
- which native search capability produced the result;
- result count;
- whether the search result exposed metadata only or file contents;
- whether the native search capability is unavailable.

Do not inspect .gitignore, .cursorignore, .aiignore, or the plan files until
this search test is complete.

If the client cannot perform native workspace search without using shell or
MCP, stop and report the test as unsupported. Do not substitute another search
method.
```

## Post-hoc audit prompt

```text
Now perform a post-hoc audit of the preceding boundary test.

Use $large-ide-workspace-evaluator in posthoc-context-audit mode.

Inspect the repository boundary configuration only after evaluating the search
receipts:

- .gitignore
- .cursorignore
- .aiignore
- .vscode/settings.json
- the active multi-root .code-workspace file, if one was used

Classify each sentinel separately as:

- verified-invisible;
- naturally-absent-unproven;
- visible-or-consumed;
- unknown;
- test-unsupported.

Distinguish path metadata, opened contents, tool output, model context, and
response-used content. Do not claim invisibility merely because contents were
not opened. Do not use Morph MCP, shell tools, or a fresh repository scan to
replace missing receipts.
```

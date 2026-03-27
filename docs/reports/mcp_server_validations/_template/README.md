# MCP validation report template

Use this directory as the reusable shape for MCP server validation artifacts.

## Expected files

- `README.md`
  Human summary of the validation run
- `test_<server>_mcp.mjs`
  Repeatable validation harness
- `*_validation_results.json`
  Raw collected results
- sample source inputs used to exercise the server

## Minimum proof points

- install surface or executable path used
- reported tool surface or command surface
- config merge behavior against repo-local targets
- notable side effects such as browser launch, editor handoff, or network expectations

## Notes

- Prefer storing validation output under `docs/reports/mcp_server_validations/<server>/` when the artifact family grows beyond a few files.
- Keep the report usable without opening the raw JSON first.

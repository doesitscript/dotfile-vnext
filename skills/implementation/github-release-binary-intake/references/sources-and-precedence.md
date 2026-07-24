# Sources And Precedence

For GitHub release binary intake in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. Existing repo role defaults and task patterns
3. GitHub release metadata for the exact repo and tag
4. Published checksum files or signed release artifacts
5. Official upstream docs that confirm supported platforms
6. Live install verification after apply

If release metadata and README examples disagree, prefer the current release
page and checksum assets, then document the mismatch.

# Sources And Precedence

For macOS tool install design in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. `.codex/config.toml`
3. `docs/codex_framework/*`
4. Active `.cursor/rules/framework-*.mdc` guidance already loaded for the task
5. Existing repo roles, playbooks, inventory, and validation entrypoints
6. Official upstream install docs and release notes
7. Live preview/apply evidence

Do not choose Homebrew, cask, or upstream binary from habit. Choose it from the
repo pattern plus current upstream evidence.

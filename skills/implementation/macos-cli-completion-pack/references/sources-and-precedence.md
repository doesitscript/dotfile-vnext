# Sources And Precedence

For macOS CLI completion work in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. Existing completion-owning roles and shared substrate roles
3. The CLI's own completion generator or published upstream completion file
4. Current playbook/tag composition that delivers the tool
5. Real PTY proof after apply

Do not let README snippets outrank the CLI's generated completion output or the
shared `common/bash_completion` substrate pattern.

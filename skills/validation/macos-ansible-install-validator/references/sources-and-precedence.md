# Sources And Precedence

For macOS Ansible install validation in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. The current role task flow in repo
3. Ansible module behavior and platform notes
4. Current target-host facts and direct command probes
5. Preview/check/apply failure output

When task logic and live failure output disagree, inspect the failure output
first and then adjust the smallest evidenced cause.

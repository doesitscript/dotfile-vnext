# Sources And Precedence

For legacy runtime-skill migration in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. The project skill library under `skills/`
3. Current framework docs that explain whether the old surface is still active
4. Runtime `.cursor/skills/catalog.yml`
5. The legacy `.cursor/skills/<skill>/SKILL.md` body

Legacy runtime content may seed the migration, but the destination source of
truth must be the project skill library.

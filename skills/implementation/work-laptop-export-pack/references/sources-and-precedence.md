# Sources And Precedence

For the work-laptop export packet in `dotfile-vnext`, prefer:

1. `AGENTS.md`
2. The global placement decision rules used to keep this workflow project-local
3. `exports/work-laptop-ai-tools/export-manifest.yml`
4. The packet playbook, inventory, and role files under `exports/work-laptop-ai-tools/`
5. The project runtime bridge for exposing the skill in `.cursor/skills`

Do not let runtime copies, ad hoc zip commands, or broader repo playbooks
outrank the manifest-owned export packet.

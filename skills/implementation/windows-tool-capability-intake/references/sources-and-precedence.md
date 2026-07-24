# Sources And Precedence

For Windows tool capability intake in `dotfile-vnext`, prefer:

1. `AGENTS.md` §32 (Ansible-first / anti-ad-hoc)
2. `.cursor/rules/framework-agent-role-and-persona.mdc` HARD STOP — NO AD-HOC HOST MUTATION
3. Existing Windows roles (`python`, `windows_ollama_runtime`, `huggingface_hub`, Chocolatey roles)
4. Inventory connection surfaces for HVH hosts
5. Official upstream Windows install docs (Firecrawl / Context7)
6. `ansible-doc` for `win_chocolatey`, `win_command`, `win_package`
7. Live preview/apply evidence via `bin/codex-env ansible-playbook`

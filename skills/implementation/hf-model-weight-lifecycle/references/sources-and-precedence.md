# Sources And Precedence

For HF weight lifecycle work in `dotfile-vnext`, prefer:

1. `AGENTS.md` §32 and agent-role HARD STOP — NO AD-HOC HOST MUTATION
2. HRL model-doc-pack via `model-doc-pack-preflight`
3. `inventory/group_vars/model_catalog/manifest.yml` + `SOURCE-ROUTING.md`
4. `roles/huggingface_hub` (client only)
5. `roles/k3s_litellm_gateway` / `roles/continue_ide` only after a real backend exists
6. Hugging Face Hub download docs (Firecrawl / Context7) for `hf download` / snapshot APIs
7. Live Ansible apply evidence on `HOM-LAB-HVH-01`

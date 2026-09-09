# Useful commands

# Top 10 prompts. Paste one block. Skills named here are the slice skills
# under .agents/skills/. Design authority is this packet. The sibling
# checkout work-laptop-ai-tools is generated. Do not edit the sibling
# as the source of truth.

## 1. Sync source to sibling

Use skill `work-laptop-packet-ops` to sync the work-laptop-ai-tools source packet to the sibling. Validate the export contract, then copy every manifest path from `dotfile-vnext/exports/work-laptop-ai-tools/` into the sibling checkout so the sibling matches the packet. Do not treat the sibling as design authority. Do not commit or push.

## 2. Sync source to sibling, then git push the sibling

Use skill `work-laptop-packet-ops` to sync the work-laptop-ai-tools source packet to the sibling. Validate the export contract, then copy every manifest path from `dotfile-vnext/exports/work-laptop-ai-tools/` into the sibling checkout so the sibling matches the packet. Then do the git work in the sibling subproject only: status, diff, commit the synced packet files, and push that sibling branch to its remote. Do not force-push. Do not commit vault secrets. Leave unrelated dirty files unstaged.

## 3. Pin Qwen3-4B for Jan RAG, then sync and push

Use skill work-laptop-model-runtime-import to pin Qwen3-4B as the Jan RAG chat model, then work-laptop-packet-ops to sync and push the packet and sibling.

## 4. Add a controller download

Use skill `work-laptop-model-public-download` to add a controller-Mac Hugging Face download line and the matching later process line for <repo> <file.gguf> in `helpers/work-mac-local-models/continue-mac-local-controller.sh`. Do not run the download unless asked.

## 5. Add a work-laptop import

Use skill `work-laptop-model-runtime-import` to add the work-laptop echo and process lines that import <file.gguf> from `~/models` into Ollama. Point at the local copy, not the share. Do not claim the import ran.

## 6. Apply on the work laptop

Use skill `work-laptop-day2-apply` on the work Mac after `git pull`. Full apply is `--skip-tags hosts_file`. If the change is only in the sequential tail of `playbook.yaml` roles, use the quick window instead: `--tags recent_10` for the last 10 role entries, or `--tags recent_15` for the last 15. Still pass `--skip-tags hosts_file`. Then verify Continue, Cline, and `cx-*`. Do not invent an ad-hoc SSH or scp apply. Do not use a recent window for a change outside that tail.

## 7. Vault status, names only

Use skill `work-laptop-vault-status` to check whether the packet vault exists, is ciphertext, and which mapped keys are nonempty. Names only. Do not print secret values.

## 8. Work-laptop recorded facts

Use skill `work-laptop-recorded-facts` for the work laptop model, chip, macOS version, hostname, and username. Read `host_vars/work-laptop.yaml` first. Do not search the tree or guess.

## 9. Inbound laptop feedback review

Use skill `work-laptop-improvement-review` to pull the latest sibling, ingest inbound laptop feedback, and register accepted deviations. Audit only unless asked to implement.

## 10. Enable an MCP on this slice

Use skill `work-laptop-mcp-commission` to enable <mcp> for Continue, Cline, and Codex on this packet. Do not enable VS Code native `mcp.json`. Do not apply live on the laptop unless asked. After packet edits, use skill `work-laptop-packet-ops` to sync the sibling.

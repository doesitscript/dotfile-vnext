# jan_ide

Write the work-laptop Jan desktop RAG config. Does not install Jan and does
not download a model.

## Lifecycle

`jan_ide_state: present|absent`

`present` writes:

- `~/Library/Application Support/Jan/data/homelab-reference-library-rag.json`
- `assistants/homelab-reference-library/assistant.json` (retrieval tool)
- `projects/homelab-reference-library/project.json`
- a `homelab-reference-library` filesystem MCP server in `mcp_config.json`

Document source is `jan_ide_rag_corpus_path`, which must be
`~/Documents/develop/homelab-reference-library`.

`absent` removes those three managed paths and drops the
`homelab-reference-library` MCP server. It does not delete Jan's data folder.

## Apply

On the work laptop, after sync:

```bash
ansible-playbook playbook.yaml --tags jan
```

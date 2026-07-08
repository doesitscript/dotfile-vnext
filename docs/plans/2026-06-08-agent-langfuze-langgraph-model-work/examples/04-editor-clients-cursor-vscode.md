# Editor Clients Adaptation

## External sources

- `https://langfuse.com/integrations/developer-tools/cursor`
- `https://langfuse.com/integrations/developer-tools/vscode`
- local vendor references:
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/vscode-integration.md`
  - `/Users/joshc/develop/ai-resource-library/vendors/langfuse/langfuse-mcp-readme.md`

## Repo authority sources

- `/Users/joshc/develop/dotfile-vnext/AGENTS.md`
- `/Users/joshc/develop/dotfile-vnext/README.md`
- `/Users/joshc/develop/dotfile-vnext/docs/reports/mcp_server_validations/research_collection_stack/README.md`

## Suggested pattern from upstream

Upstream client guidance suggests:

- Cursor can connect to Langfuse-adjacent MCP and tracing surfaces
- VS Code can use Langfuse via MCP-oriented workflows
- editor clients are consumer surfaces, not placement authorities
- Cursor's model selection happens in the editor client through the model picker
  and `Cursor Settings > Models`
- Cursor's OpenAI-compatible path is the relevant local-model setup surface for
  this plan family, not a separate "local models" infrastructure product

## Repo adaptation

For this repo:

- Cursor and VS Code are client surfaces that should consume the repo-approved
  model gateway and Langfuse-adjacent tooling
- client setup must follow repo-managed MCP and environment patterns
- the clients do not decide where Langfuse, LiteLLM, or `vLLM` live
- Cursor should point at the repo-managed LiteLLM gateway, not directly at raw
  `vLLM`
- the repo-approved Cursor OpenAI-compatible base URL should map to
  `http://litellm.hom.lab/v1`
- Cursor-visible model names must match durable LiteLLM aliases exactly rather
  than informal plan labels

`Jupyter` belongs in the same consumer class:

- useful workbench/client
- not a Langfuse integration entry in itself
- not an authority source for infrastructure shape

## Conflicts with current infrastructure

- upstream editor examples are developer-tool focused, not homelab-topology
  focused
- example configs do not encode repo wrappers, environment loading, or local
  MCP governance expectations
- upstream/local-model discussions often assume `localhost` or disposable
  tunneling, while this repo should prefer the governed gateway hostname and
  service path
- the plan currently names models conceptually (`Ornith`, `Qwen Coder`,
  `DeepSeek`) without yet pinning the exact LiteLLM aliases Cursor operators
  should choose

## Decision for this project

- treat editor surfaces as consumers only
- keep Cursor and VS Code in scope as integration examples
- keep Jupyter classified as a client/workbench only
- use Cursor's OpenAI-compatible settings path for local models
- route Cursor through LiteLLM first so Langfuse can observe the gateway path
- treat the Cursor `OpenAI API Key` field as configuration required by Cursor,
  but do not assume a real OpenAI provider key is the long-term repo pattern
  when the gateway uses repo-controlled auth instead

## Cursor local-model setup mapping

Official Cursor docs confirm:

- user-managed provider setup lives in `Cursor Settings > Models`
- provider-backed models appear in the model picker
- the current conversation can switch models with the model picker
- custom API keys only apply to chat models, not tab completion

Repo-adapted operator flow:

1. Open `Cursor Settings > Models`.
2. Use the OpenAI-compatible provider path.
3. Populate the `OpenAI API Key` field as required by Cursor.
4. Enable `Override OpenAI Base URL`.
5. Set the base URL to the repo-approved gateway endpoint:
   `http://litellm.hom.lab/v1`
6. Add or select custom models using the exact LiteLLM-exposed names.
7. Choose the desired model from the Cursor model picker.

Community evidence adds two practical warnings:

- Cursor local/OpenAI-compatible usage often fails against plain `localhost`.
- Placeholder-key usage is common for local/OpenAI-compatible backends, but
  Cursor's official docs do not explicitly guarantee "any string" semantics.

## Open verification items

- final model-selection UX per editor
- whether separate editor profiles should map to distinct LiteLLM routes
- whether Langfuse MCP access should be documented in this plan family or in a
  separate operator workflow packet
- durable LiteLLM alias names for the Cursor-visible local models
- the Cursor-side auth pattern to use against the reachable, auth-protected
  LiteLLM gateway at `litellm.hom.lab`

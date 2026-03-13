# OpenAI Reference

This folder is a quick reference for asking Codex to research OpenAI topics using official docs before answering.

Use these references when you want better answers about:
- multi-agent workflows
- MCP servers and connectors
- Responses API
- tool calling and function calling
- Codex configuration
- OpenAI SDK usage

Recommended default instruction:

```text
Research this in the OpenAI docs first. Use the OpenAI docs MCP server to search official docs, guides, examples, API reference, and relevant blog-style docs pages. Then give me a practical answer with links and examples: <your question>
```

Recommended workflow:
1. Search the official docs first.
2. Pull the exact API reference or guide when needed.
3. Prefer examples over memory.
4. Separate documented facts from inference.

Files in this folder:
- `prompts-and-templates.md` - reusable prompts you can paste into chat
- `research-workflow.md` - how to ask for a docs-first answer

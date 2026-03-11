What it provides
Read-only access to OpenAI developer documentation (search + page content).
A way to pull documentation into your agent’s context while you work.

88888
Alternatively, you can add it in ~/.codex/config.toml directly:

[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"

To have Codex reliably use the MCP server, add this snippet to your AGENTS.md:

Always use the OpenAI developer documentation MCP server if you need to work with the OpenAI API, ChatGPT Apps SDK, Codex,… without me having to explicitly ask.

Tips
If you don’t have the snippet in the AGENTS.md file, you need to explicitly tell your agent to consult the Docs MCP server for the answer.
If you have more than one MCP server, keep server names short and descriptive to aid the agent in selecting the server.
OpenAI Docs Skill
If you use skills in your AI tooling, pair this MCP server with the OpenAI Docs Skill. It tells the agent to use Docs MCP tools first for OpenAI questions, then fall back to official OpenAI domains.

Install the skill from the OpenAI skills repository.
Confirm you configured this Docs MCP server at https://developers.openai.com/mcp.
Enable the skill for your project or session in your agent tooling.
Ask OpenAI product/API questions and request citations so answers stay traceable to docs sources.
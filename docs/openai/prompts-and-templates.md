# OpenAI Prompts And Templates

## General docs-first prompt

```text
Research this in the OpenAI docs first. Use the OpenAI docs MCP server to search official docs, guides, examples, API reference, and relevant blog-style docs pages. Then give me a practical answer with links and examples: <your question>
```

## Deep research prompt

```text
Do an OpenAI-docs research pass first. Search official docs, examples, API reference, and relevant guidance for this topic. Include links, note any ambiguities, and separate confirmed facts from your inference: <your question>
```

## Multi-agent prompt

```text
Use the OpenAI docs MCP server to research this topic across official docs, guides, examples, and config reference. Prioritize exact behavior, limits, and examples over memory. Then summarize the recommended approach and show me a concrete example: <your multi-agent question>
```

## MCP prompt

```text
Research OpenAI's official MCP and connectors docs first. Find the current guidance, auth model, tool behavior, risks, and at least one example. Then explain the recommended implementation for this use case: <your MCP question>
```

## Responses API prompt

```text
Use the OpenAI docs MCP server to research the Responses API for this task. Pull the relevant guides and endpoint reference, then give me a minimal working example in <language>: <your question>
```

## Codex config prompt

```text
Research the official Codex config reference before answering. Find the current settings, exact option names, defaults if documented, and one example config snippet for this goal: <your question>
```

## Compare-two-approaches prompt

```text
Research this in the official OpenAI docs first, then compare these two approaches using documented tradeoffs, examples, and limitations. End with a recommendation for my use case: <approach A> vs <approach B>
```

## Extract examples prompt

```text
Search the OpenAI docs for examples related to this topic. Gather the best official examples, summarize what each demonstrates, and show me the most relevant one adapted to my use case: <topic>
```

## Exact behavior prompt

```text
I want the documented answer, not a memory-based answer. Use the OpenAI docs MCP server to find the exact current behavior, config names, and any limits or caveats for: <topic>
```

## Ready-made examples

### Multi-agent orchestration

```text
Use the OpenAI docs MCP server to research multi-agent support, agent roles, orchestration patterns, and any relevant Codex configuration. Pull official docs and examples, then recommend a practical setup for this repo.
```

### Responses API with tools

```text
Research the official OpenAI docs for Responses API tool calling, web search, file search, and function calling. Then show me the simplest recommended JavaScript example and explain when each tool type should be used.
```

### Remote MCP servers

```text
Research the official OpenAI docs for remote MCP servers and connectors. Explain how auth works, how tool discovery works, what the risks are, and show me a concrete example request.
```

### Codex multi-agent config

```text
Research the official Codex config reference for multi-agent settings. Find the exact config keys, defaults if documented, and show me a sample config.toml for planning, implementation, and review agents.
```

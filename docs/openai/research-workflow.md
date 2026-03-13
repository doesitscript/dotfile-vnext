# OpenAI Docs Research Workflow

Use this when you want Codex to answer from official OpenAI sources instead of memory.

## What to ask for

Ask for:
- official docs
- guides
- examples
- API reference
- config reference
- exact behavior
- links

Ask Codex to:
- research first
- prefer official sources over memory
- distinguish documented facts from inference
- include at least one concrete example

## Good prompt pattern

```text
Research this in the OpenAI docs first. Use the OpenAI docs MCP server to search official docs, guides, examples, API reference, and config reference. Then answer with links, examples, and a short recommendation for my use case: <question>
```

## Good follow-up prompts

```text
Now pull the exact API reference for the endpoint you mentioned and show me the minimal curl and JavaScript examples.
```

```text
Find the best official example for this and adapt it to my use case.
```

```text
Separate what is explicitly documented from what you are inferring.
```

```text
Compare the docs guidance for these two options and recommend one.
```

## Best use cases

This works especially well for:
- OpenAI multi-agent questions
- MCP server and connector questions
- Responses API behavior
- tool and function calling
- web search and file search
- SDK examples
- Codex config questions

## Short version

```text
OpenAI-docs research pass first, then answer with links and examples: <question>
```

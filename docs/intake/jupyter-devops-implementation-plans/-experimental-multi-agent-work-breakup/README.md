# Experimental Multi-Agent Work Breakup

## Purpose

This folder captures a potential future optionality for breaking up work across
multiple AI agents or models in this project.

The approach is experimental. It is not a standing project rule and should not
be treated as required workflow unless it is later promoted into the active
framework/rules layer.

## Current Test Candidate

The current candidate for this experiment is the Jupyter DevOps implementation
plan set:

- upgraded server Ubuntu/Docker/K3s baseline
- remote JupyterLab workbench
- Langfuse on K3s
- LiteLLM gateway
- vLLM runtime and Hugging Face cache
- end-to-end AI DevOps validation

The experiment is specifically testing whether Sonnet-class and Gemini 2.5
agents can safely assist with research, drafting, and critique while preserving
the final quality level normally expected in this repo.

## Experimental Division Of Labor

| Function | Experimental Agent Fit | Required Review |
|---|---|---|
| Source collection | Gemini 2.5, Sonnet, or similar subagent | Check source list and relevance |
| Research summarization | Gemini 2.5 or Sonnet | Verify against repo rules and current docs |
| Draft plan generation | Gemini 2.5 or Sonnet | Final architect must review |
| Diagram drafting | Gemini 2.5 or Sonnet | Final architect must validate required plan gates |
| Naming/schema decisions | Final architect preferred | Must use active schema and critical naming process |
| NetBox/Ansible implementation path | Final architect required | Must verify live/repo state before execution |
| Official plan promotion | Final architect required | Must satisfy `docs/plans/` packet and diagram rules |

## Git Commit And Tag Guidance

When committing work that is intentionally part of this experiment, make the
experimental nature visible in the commit message or tag.

Suggested commit prefixes:

```text
experiment(multi-agent): draft jupyter devops plan split
experiment(gemini-agent): capture background research findings
experiment(sonnet-agent): compare plan critique against repo gates
```

Suggested branch or tag shapes:

```text
experiment/multi-agent-jupyter-devops
experiment/multi-agent-jupyter-devops-YYYYMMDD
experiment/gemini-jupyter-devops-pass-YYYYMMDD
experiment/sonnet-jupyter-devops-pass-YYYYMMDD
```

Use these labels only for the experimental process artifacts or experimental
agent outputs. Do not label normal implementation commits as experimental unless
the implementation itself is part of the test.

## Promotion Rule

Experimental agent output may become official only after a final repo-grounded
review confirms:

- sources are listed and relevant
- names follow `docs/reference/naming-standards/`
- NetBox assumptions are verified or clearly marked unverified
- Ansible role/playbook placement follows repo patterns
- official plans include required Mermaid diagrams
- old-name cleanup and stale-alias risks are addressed

## Related Documents

- [IMPORTANT-MULTI-AGENT-GEMNI-NOTE.md](../IMPORTANT-MULTI-AGENT-GEMNI-NOTE.md)
- [IMPORTANT-approach-tracking-EXPERIMENTAL.md](IMPORTANT-approach-tracking-EXPERIMENTAL.md)
- [findings/](findings/)

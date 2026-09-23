# AI Agent Profiles

This file is managed by Ansible role `cursor`.

Primary machine-readable contract:

- Cursor: `/Users/joshc/develop/dotfile-vnext/.cursor/ai-agent-profiles.json`
- Codex: `/Users/joshc/develop/dotfile-vnext/.codex/ai-agent-profiles.json`

Gateway:

```text
http://litellm.hom.lab/v1
```

Use this profile contract when a Codex or Cursor-compatible client needs to map
work roles to model lane names. Runtime availability still depends on the
LiteLLM, vLLM, Langfuse, and GPU prerequisite gates.

## Agent Roles

- `planner` -> default `ministral-3-8b`, alternate
  `qwen2.5-coder-1.5b-base-q8_0`, boundary `read_only`
- `coder` -> default `qwen3-coder-30b-a3b`, alternate
  `ministral-3-8b`, boundary `repo_write`
- `tester` -> default `qwen2.5-coder-1.5b-base-q8_0`, alternate
  `ministral-3-8b`, boundary `test_execution`
- `reviewer` -> default `qwen3-coder-30b-a3b`, alternate
  `ministral-3-8b`, boundary `read_only`
- `documenter` -> default `qwen2.5-coder-1.5b-base-q8_0`, alternate
  `qwen3-coder-30b-a3b`, boundary `repo_write`
- `steward` -> default `ministral-3-8b`, alternate
  `qwen3-coder-30b-a3b`, boundary `governance`

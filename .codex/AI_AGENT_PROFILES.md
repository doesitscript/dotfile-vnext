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

- `planner` -> default `ripi-private`, alternate
  `code-fast`, boundary `read_only`
- `coder` -> default `deepreinforce-ai/Ornith-1.0-35B-GGUF`, alternate
  `code-fast`, boundary `repo_write`
- `tester` -> default `code-test`, alternate
  `code-fast`, boundary `test_execution`
- `reviewer` -> default `code-review`, alternate
  `ripi-private`, boundary `read_only`
- `documenter` -> default `code-fast`, alternate
  `deepreinforce-ai/Ornith-1.0-35B-GGUF`, boundary `repo_write`
- `steward` -> default `ripi-private`, alternate
  `code-review`, boundary `governance`

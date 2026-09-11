# Start here

## Implementation (default)

1. Read [orchestration/01-critical-path--expert-to-evaluator.md](orchestration/01-critical-path--expert-to-evaluator.md).
2. Confirm a **refined technical handoff** exists. Canonical storage example:
   [orchestration/05-refined-technical-handoff--storage-layout.md](orchestration/05-refined-technical-handoff--storage-layout.md).
3. Launch via [../launch-directory.md](../launch-directory.md) (parent manages
   Implementer/Evaluator). Prefer **Light** orchestration.
4. Runner docs: [runtime/implementation-runner.md](runtime/implementation-runner.md).

Expert stays on-call for lab questions after the heavy pass:
[orchestration/06-expert-on-call--lab-consultation.md](orchestration/06-expert-on-call--lab-consultation.md).

Historical research→campaign transforms (examples only):
[orchestration/examples/storage-layout-research-transforms/](orchestration/examples/storage-layout-research-transforms/).

## Preparation (Coordinator + Researcher, optional re-run)

Two chats: [agent-prompts/onsite-expert-coordinator-draft-prompt.md](agent-prompts/onsite-expert-coordinator-draft-prompt.md)
then [agent-prompts/researcher-draft-prompt.md](agent-prompts/researcher-draft-prompt.md).
Or use `runtime/run-preparation.ts` with a fresh output directory.

Packet ownership: [capability.yml](capability.yml).

## Authority / runtime surfaces

- [orchestration/02-authority--who-to-call.md](orchestration/02-authority--who-to-call.md)
- [orchestration/07-runtime-surfaces--broker-vs-peer-mcp.md](orchestration/07-runtime-surfaces--broker-vs-peer-mcp.md)
  — standalone Mac broker vs Cursor peer MCP (query surface, not orchestrator)
- Evaluator Ansible practices: global skill `ansible-gpa-project-evaluator` +
  [orchestration/references/ansible-gpa/](orchestration/references/ansible-gpa/)

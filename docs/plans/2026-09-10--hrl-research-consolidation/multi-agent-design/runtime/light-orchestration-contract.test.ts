import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const root = import.meta.dir;
const read = (relative: string) => readFileSync(join(root, relative), "utf8");

describe("Light orchestration contract", () => {
  test("starts the pass deadline only after role dispatch", () => {
    const runner = read("run-implementation.ts");
    expect(runner).toContain("await post('/release-held'");
    expect(runner).toContain("await post('/send-message'");
    expect(runner).toContain("log('pass_dispatched'");
    expect(runner.indexOf("log('pass_dispatched'")).toBeGreaterThan(runner.indexOf("await post('/send-message'"));
  });

  test("keeps the default batch source-local and bounded", () => {
    const runner = read("run-implementation.ts");
    expect(runner).toContain("defaultLightOwnerBatch");
    expect(runner).toContain("do not run SSH, inventory-targeted ansible/ansible-playbook commands");
    expect(runner).toContain("Allowed validation is one bundled source-local whitespace, syntax, lint, template, argument-contract or static module check");
    expect(runner).toContain("do not run S3/S4 safety-contract playbooks");
  });

  test("routes refined handoff first then dynamic work queue", () => {
    const runner = read("run-implementation.ts");
    expect(runner).toContain("refined_technical_handoff_path");
    expect(runner).toContain("Read the refined technical handoff FIRST");
    expect(runner).toContain("implementation_work_queue_path");
    expect(runner).toContain("Derive or refresh the dynamic work queue");
    const queue = read("../../implementation-campaign/coordination/implementation-work-queue.md");
    expect(queue).toContain("Implementer-owned and dynamic");
    expect(queue).toContain("FA-hf-cache-desired-state");
    expect(queue).toContain("FA-containerd-imagefs-bind");
    expect(queue).toContain("FA-capacity-signal");
    expect(queue).toContain("Evaluator’s first verdict is whether the declared target state is present");
    const handoff = read("../../implementation-campaign/coordination/research-application/performance-layout-bootstrap-2026-09-11/refined-technical-handoff.md");
    expect(handoff).toContain("Functional areas → project owners");
    expect(handoff).toContain("onsite-expert");
    expect(handoff).toContain("transcript");
  });

  test("keeps supporting inspection tied to the selected implementation target", () => {
    const runner = read("run-implementation.ts");
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(runner).toContain("Treat diffs, file reads, git status, task/argument inspection, and source checks only as evidence directly tied to that target");
    expect(implementer).toContain("not adjacent hygiene or rediscovery");
    expect(evaluator).toContain("not a separate");
  });

  test("keeps dashboard updates non-interactive while preserving terminal gates", () => {
    const policy = read("implementation-policy.ts");
    expect(policy).toContain('tools.set_summary.approval_mode": "approve"');
    expect(policy).toContain('[`mcp_servers.multiagents-peer.tools.${tool}.approval_mode`]: "approve"');
  });

  test("role adapters prohibit broad research and remote work in Light", () => {
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(implementer).toContain("broad research in Light");
    expect(implementer).toContain("SSH/live discovery");
    expect(evaluator).toContain("SSH");
    expect(evaluator).toContain("inventory ansible");
    expect(implementer).toContain("refined-technical-handoff.md");
    expect(evaluator).toContain("refined-technical-handoff.md");
    expect(implementer).toContain("Dynamic chunking");
  });

  test("uses the project lab-cattle quality boundary", () => {
    const runner = read("run-implementation.ts");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(runner).toContain("recreatable lab treats workloads and storage state as cattle");
    expect(evaluator).toContain("cattle, not pets");
    expect(evaluator).toContain("failure-forensics");
  });

  test("retires S3/S4 safety fixtures and coalesces Light status", () => {
    const runner = read("run-implementation.ts");
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    const queue = read("../../implementation-campaign/coordination/implementation-work-queue.md");
    expect(runner).toContain("Publish at most a start summary naming the chunk and a final handoff/verdict summary");
    expect(implementer).toContain("S3/S4 safety-contract playbooks");
    expect(evaluator).toContain("do not split whitespace/syntax/lint into separate");
    expect(queue).not.toContain("verify_k3s_storage_offload_safety");
    expect(queue).not.toContain("verify_vllm_cache_migration_safety");
    expect(runner).toContain("agent_type:'codex'");
  });
});

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
    expect(runner).toContain("Ansible intake");
    expect(runner).toContain("verification only");
    expect(runner).toContain("orchestration/temp");
    const queue = read("../orchestration/examples/storage-layout-research-transforms/implementation-work-queue.md");
    expect(queue).toContain("Implementer-owned and dynamic");
    expect(queue).toContain("FA-hf-cache-desired-state");
    expect(queue).toContain("FA-containerd-imagefs-bind");
    expect(queue).toContain("FA-capacity-signal");
    expect(queue).toContain("Evaluator’s first verdict is whether the declared target state is present");
    const handoff = read("../orchestration/05-refined-technical-handoff--storage-layout.md");
    expect(handoff).toContain("Functional areas → project owners");
    expect(handoff).toContain("onsite-expert");
    expect(handoff).toContain("transcript");
  });

  test("keeps supporting inspection tied to the selected implementation target", () => {
    const runner = read("run-implementation.ts");
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(runner).toContain("Treat diffs, file reads, git status, task/argument inspection, and source checks only as evidence directly tied to that target");
    expect(implementer).toContain("refactor the whole repo");
    expect(evaluator).toContain("not a separate deliverable");
  });

  test("keeps dashboard updates non-interactive while preserving terminal gates", () => {
    const policy = read("implementation-policy.ts");
    expect(policy).toContain('[`${PEER}.set_summary.approval_mode`]: "approve"');
    expect(policy).toContain('[`${PEER}.${tool}.approval_mode`]: "approve"');
    expect(policy).toContain("scrubInvalidToolApprovalModes");
  });

  test("role adapters prohibit broad research and remote work in Light", () => {
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(implementer).toContain("Ansible intake");
    expect(implementer).toContain("SSH/live discovery");
    expect(evaluator).toContain("SSH");
    expect(evaluator).toContain("inventory ansible");
    expect(implementer).toContain("05-refined-technical-handoff--storage-layout.md");
    expect(evaluator).toContain("05-refined-technical-handoff--storage-layout.md");
    expect(implementer).toContain("Chunk the handoff");
    expect(evaluator).toContain("re-teach");
    expect(evaluator).toContain("ansible-gpa-project-evaluator");
  });

  test("uses the project lab-cattle quality boundary", () => {
    const runner = read("run-implementation.ts");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    expect(runner).toContain("recreatable lab treats workloads and storage state as cattle");
    expect(evaluator).toContain("Cattle, not pets");
    expect(evaluator).toContain("forensics");
  });

  test("retires S3/S4 safety fixtures and coalesces Light status", () => {
    const runner = read("run-implementation.ts");
    const implementer = read("../implementer/skills/storage-plan-implementer-light-beta/SKILL.md");
    const evaluator = read("../evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md");
    const queue = read("../orchestration/examples/storage-layout-research-transforms/implementation-work-queue.md");
    expect(runner).toContain("Publish at most a start summary naming the chunk and a final handoff/verdict summary");
    expect(implementer).toContain("S3/S4 safety-contract playbooks");
    expect(evaluator).toContain("One bundled source-quality verdict");
    expect(queue).not.toContain("verify_k3s_storage_offload_safety");
    expect(queue).not.toContain("verify_vllm_cache_migration_safety");
    expect(runner).toContain("agent_type:workerAgentType");
    expect(runner).toContain("workerAgentType='codex'");
    expect(runner).toContain("allow_full_tip_resume");
    expect(runner).toContain("Light profile refuses to resume Full-era tip");
    expect(read("paired-events.ts")).toContain("non-contract filename");
    expect(read("implementation-policy.ts")).toContain("scrubInvalidToolApprovalModes");
    expect(read("implementation-policy.ts")).toContain('[`${PEER}.set_summary.approval_mode`]: "approve"');
  });
});

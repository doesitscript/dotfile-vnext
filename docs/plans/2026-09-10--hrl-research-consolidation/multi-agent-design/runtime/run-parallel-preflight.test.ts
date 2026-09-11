import { describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const runner = join(import.meta.dir, "run-parallel-preflight.ts");
function config(root: string, jobs: unknown[]) { const path = join(root, "config.json"); writeFileSync(path, JSON.stringify({ project_root: root, plan_dir: root, output_dir: join(root, "out"), run_id: "parallel-test", jobs })); return path; }
describe("bounded parallel preflight", () => {
  test("runs allowed evidence jobs concurrently and writes a synthesis manifest", () => {
    const root = mkdtempSync(join(tmpdir(), "parallel-preflight-"));
    try { const result = Bun.spawnSync(["bun", runner, config(root, [{ id: "evidence", purpose: "collect facts", command: ["git", "--version"] }, { id: "tests", purpose: "check runtime", command: ["bun", "--version"] }])], { stdout: "pipe", stderr: "pipe" });
      expect(result.exitCode).toBe(0); const manifest = JSON.parse(readFileSync(join(root, "out", "manifest.json"), "utf8")); expect(manifest.jobs).toHaveLength(2); expect(manifest.synthesis_owner).toBe("implementer");
    } finally { rmSync(root, { recursive: true, force: true }); }
  });
  test("quarantines mutation-capable work before a worker starts", () => {
    const root = mkdtempSync(join(tmpdir(), "parallel-preflight-"));
    try { const result = Bun.spawnSync(["bun", runner, config(root, [{ id: "bad-job", purpose: "bad", command: ["git", "reset", "--hard"] }])], { stdout: "pipe", stderr: "pipe" }); expect(result.exitCode).toBe(0); const admission = JSON.parse(readFileSync(join(root, "out", "admission.json"), "utf8")); expect(admission.rejected[0].reason).toContain("mutation-capable");
    } finally { rmSync(root, { recursive: true, force: true }); }
  });
  test("records an explicit zero-job admission instead of skipping it", () => {
    const root = mkdtempSync(join(tmpdir(), "parallel-preflight-"));
    try { const result = Bun.spawnSync(["bun", runner, config(root, [])], { stdout: "pipe", stderr: "pipe" }); expect(result.exitCode).toBe(0); const admission = JSON.parse(readFileSync(join(root, "out", "admission.json"), "utf8")); expect(admission.admitted).toEqual([]);
    } finally { rmSync(root, { recursive: true, force: true }); }
  });
});

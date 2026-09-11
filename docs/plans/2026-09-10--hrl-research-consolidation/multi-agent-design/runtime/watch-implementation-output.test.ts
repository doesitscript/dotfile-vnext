import { describe, expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const script = join(import.meta.dir, "watch-implementation-output.sh");

describe("implementation terminal monitor", () => {
  test("documents its read-only, curl-backed contract", () => {
    expect(existsSync(script)).toBe(true);
    const result = spawnSync("bash", [script, "--help"], { encoding: "utf8" });
    expect(result.status).toBe(0);
    expect(result.stdout).toContain("/slots/list");
    expect(result.stdout).toMatch(/never sends a\s+message/);
  });

  test("rejects a monitor without its session and run evidence inputs", () => {
    const root = mkdtempSync(join(tmpdir(), "implementation-monitor-test-"));
    mkdirSync(join(root, "run"));
    writeFileSync(join(root, "run", "events.jsonl"), "\n");
    const result = spawnSync("bash", [script, "--once", "--run-dir", join(root, "run")], { encoding: "utf8" });
    expect(result.status).toBe(2);
    expect(result.stderr).toContain("Usage:");
  });
});

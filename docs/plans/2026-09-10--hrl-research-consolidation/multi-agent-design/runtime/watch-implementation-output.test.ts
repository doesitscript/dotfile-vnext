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
    expect(result.stdout).toContain("/list-peers");
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

  test("renders the broker peer summary instead of only adapter metadata", async () => {
    const root = mkdtempSync(join(tmpdir(), "implementation-monitor-summary-"));
    writeFileSync(join(root, "events.jsonl"), "\n");
    const server = Bun.serve({
      port: 0,
      fetch(request) {
        if (new URL(request.url).pathname === "/slots/list") {
          return Response.json([{ id: 9, display_name: "implementer", peer_id: "cx-summary", status: "connected", task_state: "working" }]);
        }
        if (new URL(request.url).pathname === "/list-peers") {
          return Response.json([{ id: "cx-summary", summary: "Implementer: targeted S3 validation running" }]);
        }
        return new Response("not found", { status: 404 });
      },
    });
    try {
      const child = Bun.spawn(["bash", script, "--once", "--session-id", "summary-test", "--run-dir", root, "--endpoint", `http://127.0.0.1:${server.port}`], { stdout: "pipe", stderr: "pipe" });
      const [stdout, exitCode] = await Promise.all([new Response(child.stdout).text(), child.exited]);
      expect(exitCode).toBe(0);
      expect(stdout).toContain("Implementer: targeted S3 validation running");
    } finally {
      server.stop(true);
    }
  });
});

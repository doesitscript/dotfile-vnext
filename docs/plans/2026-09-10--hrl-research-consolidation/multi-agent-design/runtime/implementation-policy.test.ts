import { describe, expect, test } from "bun:test";
import { scopedThreadParams } from "./implementation-policy";

const key = "mcp_servers.multiagents-peer.tools.approve.approval_mode";
describe("Evaluator-only thread signal policy", () => {
  test("Evaluator gets only its final approve tool override", () => {
    expect(scopedThreadParams("evaluator", {})).toEqual({ config: { [key]: "approve" } });
  });
  for (const role of ["implementer", "researcher", "coordinator", "observer", undefined]) {
    test(`${role ?? "missing role"} gets no added permission`, () => {
      const original = Object.freeze({ config: Object.freeze({ approval_policy: "never" }) });
      expect(scopedThreadParams(role, original)).toBe(original);
    });
  }
  test("existing thread params and unrelated tool policies remain unchanged", () => {
    const config = Object.freeze({ approval_policy: "never", model: "original-model",
      "mcp_servers.multiagents-peer.tools.submit_feedback.approval_mode": "never",
      "mcp_servers.other-server.tools.approve.approval_mode": "never",
      [key]: "never" });
    const original = Object.freeze({ cwd: "/work/project", sandbox: "workspace-write", config });
    const result = scopedThreadParams("evaluator", original);
    expect(result).toEqual({ ...original, config: { ...config, [key]: "approve" } });
    expect(result).not.toBe(original);
    expect(result.config).not.toBe(config);
    expect(original.config[key]).toBe("never");
  });
  test("per-thread override is idempotent", () => {
    const first = scopedThreadParams("evaluator", { config: { approval_policy: "never" } });
    expect(scopedThreadParams("evaluator", first)).toEqual(first);
  });
});

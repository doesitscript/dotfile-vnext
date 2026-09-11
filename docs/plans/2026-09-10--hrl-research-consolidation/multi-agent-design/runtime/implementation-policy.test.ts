import { describe, expect, test } from "bun:test";
import { scopedThreadParams } from "./implementation-policy";

const approveKey = "mcp_servers.multiagents-peer.tools.approve.approval_mode";
const doneKey = "mcp_servers.multiagents-peer.tools.signal_done.approval_mode";
const summaryKey = "mcp_servers.multiagents-peer.tools.set_summary.approval_mode";
describe("Role-scoped terminal signal policy", () => {
  test("Evaluator gets non-interactive dashboard summary and final approve overrides", () => {
    expect(scopedThreadParams("evaluator", {})).toEqual({ config: {
      [summaryKey]: "auto", [approveKey]: "auto" } });
  });
  test("Implementer gets non-interactive dashboard summary and final signal_done overrides", () => {
    expect(scopedThreadParams("implementer", {})).toEqual({ config: {
      [summaryKey]: "auto", [doneKey]: "auto" } });
  });
  for (const role of ["researcher", "coordinator", "observer", undefined]) {
    test(`${role ?? "missing role"} gets no added permission`, () => {
      const original = Object.freeze({ config: Object.freeze({ approval_policy: "never" }) });
      expect(scopedThreadParams(role, original)).toEqual({
        config: { approval_policy: "never" },
      });
    });
  }
  test("existing thread params and unrelated tool policies remain unchanged", () => {
    const config = Object.freeze({ approval_policy: "never", model: "original-model",
      "mcp_servers.multiagents-peer.tools.submit_feedback.approval_mode": "never",
      "mcp_servers.other-server.tools.approve.approval_mode": "never",
      [approveKey]: "never" });
    const original = Object.freeze({ cwd: "/work/project", sandbox: "workspace-write", config });
    const result = scopedThreadParams("evaluator", original);
    expect(result).toEqual({ ...original, config: {
      ...config,
      "mcp_servers.multiagents-peer.tools.submit_feedback.approval_mode": "approve",
      "mcp_servers.other-server.tools.approve.approval_mode": "approve",
      [summaryKey]: "auto",
      [approveKey]: "auto",
    } });
    expect(result).not.toBe(original);
    expect(result.config).not.toBe(config);
    expect(original.config[approveKey]).toBe("never");
  });
  test("per-thread override is idempotent", () => {
    const first = scopedThreadParams("evaluator", { config: { approval_policy: "never" } });
    expect(scopedThreadParams("evaluator", first)).toEqual(first);
  });
  test("Implementer override preserves unrelated policies and is idempotent", () => {
    const first = scopedThreadParams("implementer", { config: {
      approval_policy: "never", [doneKey]: "never", [approveKey]: "never" } });
    expect(first.config).toEqual({ approval_policy: "never", [summaryKey]: "auto",
      [doneKey]: "auto", [approveKey]: "approve" });
    expect(scopedThreadParams("implementer", first)).toEqual(first);
  });
  test("scrubs nested never tool approval modes before startSession", () => {
    const result = scopedThreadParams("implementer", {
      config: {
        mcp_servers: {
          "multiagents-peer": {
            tools: { set_summary: { approval_mode: "never" } },
          },
        },
      },
    });
    expect(result.config.mcp_servers["multiagents-peer"].tools.set_summary.approval_mode).toBe("approve");
    expect(result.config[summaryKey]).toBe("auto");
  });
});

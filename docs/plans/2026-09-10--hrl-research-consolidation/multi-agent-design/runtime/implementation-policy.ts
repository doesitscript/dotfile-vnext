/** Pure per-thread policy adapter: enable non-mutating dashboard status and each role's terminal signal.
 * Applied to thread/start by the scoped preload, never to global config files.
 * Authorization for infrastructure changes remains a separate plan contract.
 *
 * Codex tool approval_mode accepts only: auto | prompt | writes | approve.
 * The turn-level approvalPolicy value `never` is NOT valid for per-tool modes.
 * Scrub any injected `never` under mcp tool keys so startSession cannot crash.
 */
const PEER = "mcp_servers.multiagents-peer.tools";
const TOOL_APPROVAL_MODES = new Set(["auto", "prompt", "writes", "approve"]);

function scrubInvalidToolApprovalModes(config: Record<string, any>): Record<string, any> {
  const next: Record<string, any> = { ...config };
  for (const [key, value] of Object.entries(next)) {
    if (!key.includes(".tools.") || !key.endsWith(".approval_mode")) continue;
    if (value === "never" || (typeof value === "string" && !TOOL_APPROVAL_MODES.has(value))) {
      next[key] = "approve";
    }
  }
  // Nested mcp_servers.<name>.tools.<tool>.approval_mode shapes
  const servers = next.mcp_servers;
  if (servers && typeof servers === "object" && !Array.isArray(servers)) {
    const scrubbedServers: Record<string, any> = { ...servers };
    for (const [serverName, server] of Object.entries(scrubbedServers)) {
      if (!server || typeof server !== "object" || Array.isArray(server)) continue;
      const tools = (server as any).tools;
      if (!tools || typeof tools !== "object" || Array.isArray(tools)) continue;
      const scrubbedTools: Record<string, any> = { ...tools };
      for (const [toolName, tool] of Object.entries(scrubbedTools)) {
        if (!tool || typeof tool !== "object" || Array.isArray(tool)) continue;
        const mode = (tool as any).approval_mode;
        if (mode === "never" || (typeof mode === "string" && !TOOL_APPROVAL_MODES.has(mode))) {
          scrubbedTools[toolName] = { ...tool, approval_mode: "approve" };
        }
      }
      scrubbedServers[serverName] = { ...server, tools: scrubbedTools };
    }
    next.mcp_servers = scrubbedServers;
  }
  return next;
}

export function scopedThreadParams(role: string | undefined, params: Record<string, any>): Record<string, any> {
  const tool = role === "evaluator" ? "approve" : role === "implementer" ? "signal_done" : null;
  if (!tool) {
    if (!params?.config) return params;
    return { ...params, config: scrubInvalidToolApprovalModes({ ...params.config }) };
  }
  const base = scrubInvalidToolApprovalModes({ ...(params.config || {}) });
  return {
    ...params,
    config: {
      ...base,
      // Dashboard status must stay non-interactive; never reuse turn approvalPolicy=never here.
      [`${PEER}.set_summary.approval_mode`]: "approve",
      [`${PEER}.${tool}.approval_mode`]: "approve",
    },
  };
}

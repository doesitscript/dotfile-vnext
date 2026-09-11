/** Pure per-thread policy adapter: enable only each role's terminal transport signal.
 * Applied to thread/start by the scoped preload, never to global config files.
 * Authorization for infrastructure changes remains a separate plan contract.
 */
export function scopedThreadParams(role: string | undefined, params: Record<string, any>): Record<string, any> {
  const tool = role === "evaluator" ? "approve" : role === "implementer" ? "signal_done" : null;
  if (!tool) return params;
  return { ...params, config: { ...params.config,
    [`mcp_servers.multiagents-peer.tools.${tool}.approval_mode`]: "approve" } };
}

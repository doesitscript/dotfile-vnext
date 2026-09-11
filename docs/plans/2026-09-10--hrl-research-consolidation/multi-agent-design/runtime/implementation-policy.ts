/** Pure per-thread policy adapter: enable only the Evaluator's final signal.
 * Applied to thread/start by the scoped preload, never to global config files.
 * Authorization for infrastructure changes remains a separate plan contract.
 */
export function scopedThreadParams(role: string | undefined, params: Record<string, any>): Record<string, any> {
  if (role !== "evaluator") return params;
  return { ...params, config: { ...params.config,
    "mcp_servers.multiagents-peer.tools.approve.approval_mode": "approve" } };
}

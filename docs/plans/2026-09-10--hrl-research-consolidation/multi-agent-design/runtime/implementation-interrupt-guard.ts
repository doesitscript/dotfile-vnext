/**
 * The installed multiagents orchestrator interrupts a Codex turn after 60s of
 * no app-server notification. Parent-managed implementation passes can have
 * legitimate quiet intervals (for example a remote read-only Ansible probe).
 * This guard is loaded only by implementation-preload.ts; the parent runner's
 * finite pass and run deadlines remain the failure boundary.
 */
const installed = Symbol.for("pairedImplementation.parentManagedInterruptGuard");
const timeoutInstalled = Symbol.for("pairedImplementation.parentManagedTurnTimeout");

export function installParentManagedInterruptGuard(
  Driver: { prototype: Record<PropertyKey, unknown> },
  emit: (event: { event: string; thread_id: string }) => void,
): void {
  if (Driver.prototype[installed]) return;
  Driver.prototype[installed] = true;
  Driver.prototype.interrupt = async function (this: unknown, threadId: string): Promise<void> {
    emit({ event: "upstream_idle_interrupt_suppressed", thread_id: threadId });
  };
}

/**
 * The installed CodexDriver defaults every turn to 600 seconds. Keep that
 * private upstream default aligned with the explicit parent pass deadline so
 * a healthy long turn cannot fail before the parent can make its own bounded
 * decision. This is loaded only by implementation-preload.ts.
 */
export function installParentManagedTurnTimeout(
  Driver: { prototype: Record<PropertyKey, unknown> },
  timeoutMs: number,
  emit: (event: { event: string; timeout_ms: number }) => void,
): void {
  if (!Number.isSafeInteger(timeoutMs) || timeoutMs < 60_000) {
    throw new Error("Parent-managed turn timeout must be a safe integer of at least 60000ms");
  }
  if (Driver.prototype[timeoutInstalled]) return;
  const original = Driver.prototype.startTurnAndWait;
  if (typeof original !== "function") throw new Error("Installed CodexDriver startTurnAndWait is unavailable");
  Driver.prototype[timeoutInstalled] = true;
  Driver.prototype.startTurnAndWait = function (
    this: unknown,
    threadId: string,
    params: Record<string, unknown>,
  ): unknown {
    return original.call(this, threadId, params, timeoutMs);
  };
  emit({ event: "upstream_turn_timeout_aligned", timeout_ms: timeoutMs });
}

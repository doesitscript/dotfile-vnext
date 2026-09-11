import { describe, expect, test } from "bun:test";
import {
  installParentManagedInterruptGuard,
  installParentManagedTurnTimeout,
} from "./implementation-interrupt-guard";

describe("parent-managed implementation interrupt guard", () => {
  test("suppresses only the installed upstream idle-interrupt entry point", async () => {
    let originalCalls = 0;
    class Driver { async interrupt() { originalCalls++; } }
    const events: unknown[] = [];
    installParentManagedInterruptGuard(Driver, event => events.push(event));
    await new Driver().interrupt("thread-1");
    expect(originalCalls).toBe(0);
    expect(events).toEqual([{ event: "upstream_idle_interrupt_suppressed", thread_id: "thread-1" }]);
  });

  test("is idempotent and keeps one guard installed", async () => {
    class Driver { async interrupt() {} }
    const events: unknown[] = [];
    installParentManagedInterruptGuard(Driver, event => events.push(event));
    const guarded = Driver.prototype.interrupt;
    installParentManagedInterruptGuard(Driver, event => events.push({ second: event }));
    expect(Driver.prototype.interrupt).toBe(guarded);
    await new Driver().interrupt("thread-2");
    expect(events).toHaveLength(1);
  });
});

describe("parent-managed implementation turn timeout", () => {
  test("aligns the installed private turn timeout to the explicit parent limit", async () => {
    class Driver {
      async startTurnAndWait(_thread: string, _params: unknown, timeout: number) { return timeout; }
    }
    const events: unknown[] = [];
    installParentManagedTurnTimeout(Driver, 900_000, event => events.push(event));
    expect(await new Driver().startTurnAndWait("thread-1", {}, 600_000)).toBe(900_000);
    expect(events).toEqual([{ event: "upstream_turn_timeout_aligned", timeout_ms: 900_000 }]);
  });

  test("rejects an unsafe short timeout and is idempotent once installed", () => {
    class Driver { async startTurnAndWait() {} }
    expect(() => installParentManagedTurnTimeout(Driver, 59_999, () => {})).toThrow();
    installParentManagedTurnTimeout(Driver, 900_000, () => {});
    const aligned = Driver.prototype.startTurnAndWait;
    installParentManagedTurnTimeout(Driver, 1_200_000, () => {});
    expect(Driver.prototype.startTurnAndWait).toBe(aligned);
  });
});

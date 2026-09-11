import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { acceptEvent, resumeEvent, scanEvents, type ExpectedEvent } from "./paired-events";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function fixture() { const root = mkdtempSync(join(tmpdir(), "paired-events-test-")); roots.push(root); return root; }
const expected: ExpectedEvent = {
  campaign_id: "test-campaign", run_id: "test-invocation", role: "implementer",
  upstream_plan_sha256: "a".repeat(64), responds_to: null,
};
const names = {
  review_ready: "review_ready_for_evaluator_2026-09-11T010101.md",
  feedback: "feedback_for_review_by_evaluator_2026-09-11T010102.md",
  waiting: "waiting_for_review_by_evaluator_2026-09-11T010102.md",
  ready: "ready_for_review_by_evaluator_2026-09-11T010102.md",
};
function write(root: string, name: string, meta: Record<string, unknown> = expected) {
  writeFileSync(join(root, name), `---\n${Object.entries(meta).map(([key, value]) => `${key}: ${JSON.stringify(value)}`).join("\n")}\n---\nEvidence belongs to the role.\n`);
}

describe("paired finite-pass event acceptance", () => {
  test("implementer outbox routes to evaluator with an absolute path and digest", () => {
    const root = fixture(), before = scanEvents(root); write(root, names.review_ready);
    expect(acceptEvent(root, before, expected)).toEqual({ path: join(root, names.review_ready),
      sha256: scanEvents(root)[names.review_ready], kind: "review_ready", nextActor: "evaluator" });
  });
  for (const [kind, nextActor] of [["feedback", "implementer"], ["waiting", "operator"], ["ready", "none"]] as const) {
    test(`evaluator ${kind} routes to ${nextActor}`, () => {
      const root = fixture(); write(root, names.review_ready);
      const before = scanEvents(root), evaluator = { ...expected, role: "evaluator" as const, responds_to: join(root, names.review_ready) };
      write(root, names[kind], evaluator);
      expect(acceptEvent(root, before, evaluator)).toMatchObject({ kind, nextActor });
    });
  }
  test("runtime, observer, and nested file noise do not become events", () => {
    const root = fixture(); write(root, "observer.md"); mkdirSync(join(root, "runtime"));
    write(join(root, "runtime"), names.review_ready); expect(scanEvents(root)).toEqual({});
  });
  test("successful turn without a new event is not a handoff", () => {
    const root = fixture(); expect(() => acceptEvent(root, {}, expected)).toThrow("exactly one");
  });
  test("multiple new owned events are rejected", () => {
    const root = fixture(); write(root, names.review_ready); write(root, "review_ready_for_evaluator_later.md");
    expect(() => acceptEvent(root, {}, expected)).toThrow("found 2");
  });
  for (const field of ["campaign_id", "run_id", "role", "upstream_plan_sha256", "responds_to"] as const) {
    test(`wrong ${field} is rejected`, () => {
      const root = fixture(); write(root, names.review_ready, { ...expected, [field]: "wrong" });
      expect(() => acceptEvent(root, {}, expected)).toThrow(`${field} mismatch`);
    });
  }
  test("missing explicit null binding is rejected", () => {
    const root = fixture(), { responds_to: omitted, ...meta } = expected; write(root, names.review_ready, meta);
    expect(() => acceptEvent(root, {}, expected)).toThrow("responds_to mismatch");
  });
  test("new opposing-role artifact is rejected even alongside a valid outbox", () => {
    const root = fixture(); write(root, names.review_ready); write(root, names.ready, { ...expected, role: "evaluator" });
    expect(() => acceptEvent(root, {}, expected)).toThrow("Opposing-role");
  });
  for (const prior of [names.review_ready, names.feedback]) {
    test(`mutation of prior ${prior} is rejected`, () => {
      const root = fixture(); write(root, prior); const before = scanEvents(root);
      write(root, prior, { ...expected, run_id: "changed" }); write(root, "review_ready_for_evaluator_new.md");
      expect(() => acceptEvent(root, before, expected)).toThrow("Pre-existing event changed or removed");
    });
  }
  test("deletion of an existing event is rejected", () => {
    const root = fixture(); write(root, names.feedback); const before = scanEvents(root);
    rmSync(join(root, names.feedback)); write(root, names.review_ready);
    expect(() => acceptEvent(root, before, expected)).toThrow("changed or removed");
  });
  test("missing frontmatter is rejected", () => {
    const root = fixture(); writeFileSync(join(root, names.review_ready), "not frontmatter\n");
    expect(() => acceptEvent(root, {}, expected)).toThrow("Missing YAML frontmatter");
  });
  test("YAML arrays are rejected", () => {
    const root = fixture(); writeFileSync(join(root, names.review_ready), "---\n- value\n---\n");
    expect(() => acceptEvent(root, {}, expected)).toThrow("Invalid YAML object");
  });
  test("matching event symlinks are rejected", () => {
    const root = fixture(); write(root, "not-an-event.md"); symlinkSync(join(root, "not-an-event.md"), join(root, names.review_ready));
    expect(() => scanEvents(root)).toThrow("regular file");
  });
  test("matching directories are rejected", () => {
    const root = fixture(); mkdirSync(join(root, names.review_ready)); expect(() => scanEvents(root)).toThrow("regular file");
  });
});

describe("causal resume routing", () => {
  function append(root: string, name: string, predecessor: string | null, role: "implementer" | "evaluator" = "evaluator") {
    write(root, name, { ...expected, role, run_id: `invocation-${name}`, responds_to: predecessor });
  }
  test("empty campaign starts fresh; outbox resumes evaluator", () => {
    const root = fixture(); expect(resumeEvent(root, expected)).toBeNull();
    append(root, names.review_ready, null, "implementer");
    expect(resumeEvent(root, expected)).toMatchObject({ path: join(root, names.review_ready), nextActor: "evaluator" });
  });
  for (const [kind, nextActor] of [["feedback", "implementer"], ["waiting", "operator"], ["ready", "none"]] as const) {
    test(`${kind} retains its routing after restart`, () => {
      const root = fixture(); append(root, names.review_ready, null, "implementer");
      append(root, names[kind], join(root, names.review_ready));
      expect(resumeEvent(root, expected)).toMatchObject({ kind, nextActor });
    });
  }
  test("explicit links outrank filename order, and relative local links are supported", () => {
    const root = fixture(); append(root, "review_ready_for_evaluator_z.md", null, "implementer");
    append(root, names.feedback, "review_ready_for_evaluator_z.md");
    append(root, "review_ready_for_evaluator_a.md", names.feedback, "implementer");
    expect(resumeEvent(root, expected)).toMatchObject({ path: join(root, "review_ready_for_evaluator_a.md"), nextActor: "evaluator" });
  });
  for (const field of ["campaign_id", "upstream_plan_sha256", "role"] as const) {
    test(`resume rejects mismatched ${field}`, () => {
      const root = fixture(); write(root, names.review_ready, { ...expected, [field]: "wrong" });
      expect(() => resumeEvent(root, expected)).toThrow(`${field} mismatch`);
    });
  }
  for (const predecessor of ["missing.md", "../review_ready_for_evaluator_outside.md"]) {
    test(`resume rejects dangling/external link ${predecessor}`, () => {
      const root = fixture(); append(root, names.feedback, predecessor);
      expect(() => resumeEvent(root, expected)).toThrow("Missing or outside-campaign predecessor");
    });
  }
  test("two children of an outbox are ambiguous rather than timestamp-selected", () => {
    const root = fixture(); append(root, names.review_ready, null, "implementer");
    append(root, names.feedback, names.review_ready); append(root, names.ready, names.review_ready);
    expect(() => resumeEvent(root, expected)).toThrow("Branched event chain");
  });
  test("two independent roots are ambiguous", () => {
    const root = fixture(); append(root, names.review_ready, null, "implementer"); append(root, names.feedback, null);
    expect(() => resumeEvent(root, expected)).toThrow("expected one tip, found 2");
  });
  test("duplicate invocation artifacts are rejected", () => {
    const root = fixture(); write(root, names.review_ready);
    write(root, names.feedback, { ...expected, role: "evaluator", responds_to: names.review_ready });
    expect(() => resumeEvent(root, expected)).toThrow("Duplicate invocation events");
  });
  test("cycles and disconnected cycles cannot hide behind one valid tip", () => {
    const root = fixture(); append(root, names.feedback, names.ready); append(root, names.ready, names.feedback);
    expect(() => resumeEvent(root, expected)).toThrow("expected one tip, found 0");
    append(root, names.review_ready, null, "implementer");
    expect(() => resumeEvent(root, expected)).toThrow("Disconnected or cyclic");
  });
  test("missing responds_to is not silently treated as a root", () => {
    const root = fixture(), { responds_to, ...meta } = expected; write(root, names.review_ready, meta);
    expect(() => resumeEvent(root, expected)).toThrow("Invalid event responds_to");
  });
});

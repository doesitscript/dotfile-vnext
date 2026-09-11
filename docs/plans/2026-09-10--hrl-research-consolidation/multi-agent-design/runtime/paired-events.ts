/** Read-only acceptance of one append-only, identity-bound paired-role handoff.
 * The caller must first observe successful completion of the dispatched turn.
 * This module validates transport/artifact binding, never evaluator judgment.
 */
import { createHash } from "node:crypto";
import { lstatSync, readFileSync, readdirSync } from "node:fs";
import { resolve } from "node:path";

export type EventSnapshot = Record<string, string>;
export type Role = "implementer" | "evaluator";
export type EventKind = "review_ready" | "feedback" | "waiting" | "ready";
export type ExpectedEvent = {
  campaign_id: string;
  run_id: string;
  role: Role;
  upstream_plan_sha256: string;
  responds_to: string | null;
};
export type AcceptedEvent = {
  path: string;
  sha256: string;
  kind: EventKind;
  nextActor: "implementer" | "evaluator" | "operator" | "none";
};

const patterns: [RegExp, EventKind, Role, AcceptedEvent["nextActor"]][] = [
  [/^review_ready_for_evaluator_.+\.md$/, "review_ready", "implementer", "evaluator"],
  [/^feedback_for_review_by_evaluator_.+\.md$/, "feedback", "evaluator", "implementer"],
  [/^waiting_for_review_by_evaluator_.+\.md$/, "waiting", "evaluator", "operator"],
  [/^ready_for_review_by_evaluator_.+\.md$/, "ready", "evaluator", "none"],
];

/** Near-miss Evaluator filenames that must hard-fail instead of silent ignore. */
const invalidEvaluatorNames = [
  /^ready_for_review_by_coordinator_.+\.md$/,
  /^feedback_for_review_by_coordinator_.+\.md$/,
  /^waiting_for_review_by_coordinator_.+\.md$/,
  /^ready_for_review_by_implementer_.+\.md$/,
];

function eventType(name: string) {
  return patterns.find(([pattern]) => pattern.test(name));
}

function assertNoInvalidEvaluatorFilename(planDir: string, before: EventSnapshot, role: Role) {
  if (role !== "evaluator") return;
  const afterNames = readdirSync(planDir);
  const added = afterNames.filter(name => !Object.hasOwn(before, name));
  const bad = added.filter(name => invalidEvaluatorNames.some(pattern => pattern.test(name)));
  if (bad.length > 0) {
    throw Error(
      `Light/Evaluator wrote non-contract filename(s): ${bad.join(", ")}. ` +
      "Use ready_for_review_by_evaluator_*, feedback_for_review_by_evaluator_*, or waiting_for_review_by_evaluator_* only.",
    );
  }
}

function readEvent(planDir: string, name: string): Buffer {
  const path = resolve(planDir, name);
  const stat = lstatSync(path);
  if (!stat.isFile() || stat.isSymbolicLink()) throw Error(`Event must be a regular file: ${name}`);
  return readFileSync(path);
}

function sha(bytes: Buffer): string {
  return createHash("sha256").update(bytes).digest("hex");
}

function metadata(bytes: Buffer, name: string): Record<string, unknown> {
  const match = bytes.toString("utf8").match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  if (!match) throw Error(`Missing YAML frontmatter: ${name}`);
  const meta = Bun.YAML.parse(match[1]);
  if (!meta || typeof meta !== "object" || Array.isArray(meta)) throw Error(`Invalid YAML object: ${name}`);
  return meta as Record<string, unknown>;
}

/** Only mature top-level event filenames participate; runtime/observer noise does not. */
export function scanEvents(planDir: string): EventSnapshot {
  return Object.fromEntries(readdirSync(planDir).sort().filter(name => eventType(name))
    .map(name => [name, sha(readEvent(planDir, name))]));
}

export function acceptEvent(planDir: string, before: EventSnapshot, expected: ExpectedEvent): AcceptedEvent {
  if (!["implementer", "evaluator"].includes(expected.role)) throw Error("Invalid expected role");
  for (const field of ["campaign_id", "run_id", "upstream_plan_sha256"] as const) {
    if (typeof expected[field] !== "string" || !expected[field]) throw Error(`Missing expected ${field}`);
  }
  if (expected.responds_to !== null && (typeof expected.responds_to !== "string" || !expected.responds_to)) {
    throw Error("Invalid expected responds_to");
  }
  assertNoInvalidEvaluatorFilename(planDir, before, expected.role);
  const after = scanEvents(planDir);
  for (const [name, digest] of Object.entries(before)) {
    if (after[name] !== digest) throw Error(`Pre-existing event changed or removed: ${name}`);
  }
  const added = Object.keys(after).filter(name => !Object.hasOwn(before, name));
  for (const name of added) {
    if (eventType(name)![2] !== expected.role) throw Error(`Opposing-role event written: ${name}`);
  }
  if (added.length !== 1) throw Error(`Expected exactly one new ${expected.role} event; found ${added.length}`);
  const name = added[0];
  const bytes = readEvent(planDir, name);
  const digest = sha(bytes);
  if (digest !== after[name]) throw Error(`Event changed during acceptance: ${name}`);
  const meta = metadata(bytes, name);
  for (const field of ["campaign_id", "run_id", "role", "upstream_plan_sha256", "responds_to"] as const) {
    if ((meta as Record<string, unknown>)[field] !== expected[field]) throw Error(`Event ${field} mismatch: ${name}`);
  }
  const [, kind, , nextActor] = eventType(name)!;
  return { path: resolve(planDir, name), sha256: digest, kind, nextActor };
}

/** Recover only an unambiguous causal tip, never infer chronology from mtimes.
 * Durable role artifacts determine routing; this does not assert a previous
 * runtime was cleaned up or independently re-evaluate an approval's evidence.
 */
export function resumeEvent(planDir: string, expected: Pick<ExpectedEvent, "campaign_id" | "upstream_plan_sha256">): AcceptedEvent | null {
  const snapshot = scanEvents(planDir);
  const events = new Map<string, { event: AcceptedEvent; predecessor: string | null }>();
  const invocations = new Set<string>();
  for (const [name, digest] of Object.entries(snapshot)) {
    const bytes = readEvent(planDir, name);
    if (sha(bytes) !== digest) throw Error(`Event changed during resume: ${name}`);
    const meta = metadata(bytes, name);
    const [, kind, role, nextActor] = eventType(name)!;
    for (const [field, value] of Object.entries({ campaign_id: expected.campaign_id, upstream_plan_sha256: expected.upstream_plan_sha256, role })) {
      if (meta[field] !== value) throw Error(`Event ${field} mismatch: ${name}`);
    }
    if (typeof meta.run_id !== "string" || !meta.run_id) throw Error(`Missing event run_id: ${name}`);
    if (invocations.has(meta.run_id)) throw Error(`Duplicate invocation events: ${meta.run_id}`);
    invocations.add(meta.run_id);
    if (meta.responds_to !== null && (typeof meta.responds_to !== "string" || !meta.responds_to)) {
      throw Error(`Invalid event responds_to: ${name}`);
    }
    const path = resolve(planDir, name);
    events.set(path, { event: { path, sha256: digest, kind, nextActor },
      predecessor: meta.responds_to === null ? null : resolve(planDir, meta.responds_to as string) });
  }
  if (events.size === 0) return null;
  const consumed = new Set<string>();
  for (const { predecessor } of events.values()) {
    if (predecessor === null) continue;
    if (!events.has(predecessor)) throw Error(`Missing or outside-campaign predecessor: ${predecessor}`);
    if (consumed.has(predecessor)) throw Error(`Branched event chain: ${predecessor}`);
    consumed.add(predecessor);
  }
  const tips = [...events.keys()].filter(path => !consumed.has(path));
  if (tips.length !== 1) throw Error(`Ambiguous event chain: expected one tip, found ${tips.length}`);
  const visited = new Set<string>();
  let path: string | null = tips[0];
  while (path !== null) {
    if (visited.has(path)) throw Error("Cyclic event chain");
    visited.add(path);
    path = events.get(path)!.predecessor;
  }
  if (visited.size !== events.size) throw Error("Disconnected or cyclic event chain");
  return events.get(tips[0])!.event;
}

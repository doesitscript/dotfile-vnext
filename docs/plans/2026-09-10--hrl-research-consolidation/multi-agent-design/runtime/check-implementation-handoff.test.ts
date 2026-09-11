import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { artifactPaths, checkCampaign, digest, verifyBundle, type Manifest } from "./check-implementation-handoff";

const campaign = resolve(import.meta.dir, "../../implementation-campaign");
function fixture() {
  const manifest = JSON.parse(readFileSync(resolve(campaign, "upstream-manifest.json"), "utf8")) as Manifest;
  const snapshots = Object.fromEntries(Object.entries(artifactPaths).map(([k, p]) => [k, readFileSync(resolve(campaign, "upstream", p))])) as Record<keyof typeof artifactPaths, Buffer>;
  return { manifest, snapshots };
}
function replace(f: ReturnType<typeof fixture>, key: keyof typeof artifactPaths, from: string, to: string) {
  expect(f.snapshots[key].toString()).toContain(from);
  f.snapshots[key] = Buffer.from(f.snapshots[key].toString().replace(from, to));
  // Rehash the changed snapshot so tests exercise semantic binding, not just byte integrity.
  f.manifest.artifacts[key].sha256 = digest(f.snapshots[key]);
}

describe("implementation intake", () => {
  test("real project snapshot is sufficient without reading the original run", () => {
    expect(checkCampaign(campaign)).toMatchObject({ intake: "verified", live_apply_authorized_by_checker: false, implementation_approved_by_checker: false });
  });
  test("tampered plan bytes fail", () => {
    const f = fixture(); f.snapshots.plan = Buffer.concat([f.snapshots.plan, Buffer.from("changed")]);
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("Hash mismatch: plan");
  });
  test("cross-run review fails even when its own hash was updated", () => {
    const f = fixture(); replace(f, "review", 'run_id: "hrl-preparation-20260911-r2"', 'run_id: "another-run"');
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("identity mismatch for run_id");
  });
  test("changed plan needs fresh independent review", () => {
    const f = fixture(); replace(f, "plan", "# Current-phase implementation plan", "# Changed implementation plan");
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("stale plan review hash");
  });
  test("failed independent review is not readiness", () => {
    const f = fixture(); replace(f, "review", 'status: "plan_review_passed"', 'status: "plan_changes_required"');
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("Independent review did not pass");
  });
  test("review of another path is rejected", () => {
    const f = fixture(); replace(f, "review", `reviewed_plan_path: "${f.manifest.artifacts.plan.original_path}"`, 'reviewed_plan_path: "/other-plan.md"');
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("wrong reviewed plan path");
  });
  test("release cannot bypass separate authority", () => {
    const f = fixture(); replace(f, "release", 'downstream_activation: "authorized_separately"', 'downstream_activation: "apply_now"');
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("separate activation boundary");
  });
  test("release must bind the matching review", () => {
    const f = fixture(); replace(f, "release", `plan_review_path: "${f.manifest.artifacts.review.original_path}"`, 'plan_review_path: "/other-review.md"');
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("wrong review");
  });
  test("snapshot mapping cannot redirect readers", () => {
    const f = fixture(); f.manifest.artifacts.plan.snapshot = "../../other-project/plan.md";
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("Invalid snapshot mapping");
  });
  test("pipeline identity remains aligned", () => {
    const f = fixture(); f.manifest.pipeline_id = "another-pipeline";
    expect(() => verifyBundle(f.manifest, f.snapshots)).toThrow("Pipeline/task mismatch");
  });
});

/** Read-only intake validation. No broker calls, writes, approval or Apply. */
import { createHash } from "node:crypto";
import { readFileSync, realpathSync } from "node:fs";
import { isAbsolute, relative, resolve, sep } from "node:path";

export const artifactPaths = {
  route: "coordination/current-phase-routing.md",
  brief: "research/current-phase-readiness-brief.md",
  plan: "handoff/current-phase-implementation-plan.md",
  review: "research/current-phase-plan-review.md",
  release: "handoff/current-phase-release.md",
} as const;
type Key = keyof typeof artifactPaths;
type Fields = Record<string, unknown>;
export type Manifest = {
  schema_version: number;
  pipeline_id: string;
  task_id: string;
  campaign_id: string;
  stage_id: string;
  upstream_identity: Fields;
  artifacts: Record<Key, { original_path: string; snapshot: string; sha256: string }>;
};
export const digest = (bytes: string | Buffer) => createHash("sha256").update(bytes).digest("hex");
function requireThat(ok: unknown, message: string): asserts ok {
  if (!ok) throw new Error(message);
}
function metadata(bytes: Buffer): Fields {
  const match = bytes.toString("utf8").match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  requireThat(match, "Missing YAML frontmatter");
  const value = Bun.YAML.parse(match[1]);
  requireThat(value && typeof value === "object" && !Array.isArray(value), "Invalid frontmatter");
  return value as Fields;
}

/** Pure verification also used by the rejection tests. */
export function verifyBundle(manifest: Manifest, snapshots: Record<Key, Buffer>) {
  requireThat(manifest.schema_version === 1, "Unsupported manifest schema");
  requireThat(manifest.stage_id === "implementation", "Wrong downstream stage");
  requireThat(typeof manifest.campaign_id === "string" && /^[a-z0-9][a-z0-9-]+$/.test(manifest.campaign_id), "Invalid campaign ID");
  const identity = manifest.upstream_identity;
  const identityKeys = ["contract_version", "pipeline_id", "task_id", "stage_id", "run_id", "source_plan_root", "preparation_output_root", "project_root"];
  for (const key of identityKeys) requireThat(identity?.[key] !== undefined && identity[key] !== "", `Missing upstream ${key}`);
  requireThat(identity.contract_version === 1 && identity.stage_id === "preparation", "Invalid upstream contract/stage");
  requireThat(identity.pipeline_id === manifest.pipeline_id && identity.task_id === manifest.task_id, "Pipeline/task mismatch");
  for (const key of ["project_root", "source_plan_root", "preparation_output_root"]) {
    requireThat(typeof identity[key] === "string" && isAbsolute(identity[key] as string), `Invalid ${key}`);
  }
  const fields = {} as Record<Key, Fields>;
  for (const key of Object.keys(artifactPaths) as Key[]) {
    const item = manifest.artifacts?.[key];
    requireThat(item && item.snapshot === `upstream/${artifactPaths[key]}`, `Invalid snapshot mapping: ${key}`);
    requireThat(item.original_path === resolve(identity.preparation_output_root as string, artifactPaths[key]), `Invalid original path: ${key}`);
    requireThat(/^[a-f0-9]{64}$/.test(item.sha256) && digest(snapshots[key]) === item.sha256, `Hash mismatch: ${key}`);
    fields[key] = metadata(snapshots[key]);
    for (const name of identityKeys) requireThat(fields[key][name] === identity[name], `${key}: identity mismatch for ${name}`);
  }
  requireThat(fields.route.status === "research_requested" && fields.brief.status === "ready", "Preparation inputs not ready");
  requireThat(fields.plan.status === "awaiting_plan_review", "Unexpected frozen plan status");
  requireThat(fields.review.status === "plan_review_passed", "Independent review did not pass");
  requireThat(fields.release.status === "ready_for_implementation", "Release is not ready");
  for (const key of ["review", "release"] as const) {
    requireThat(fields[key].reviewed_plan_path === manifest.artifacts.plan.original_path, `${key}: wrong reviewed plan path`);
    requireThat(fields[key].reviewed_plan_sha256 === manifest.artifacts.plan.sha256, `${key}: stale plan review hash`);
  }
  requireThat(fields.release.plan_review_path === manifest.artifacts.review.original_path, "Release points to wrong review");
  requireThat(fields.release.next_actor === "Implementer", "Wrong release recipient");
  requireThat(fields.release.downstream_activation === "authorized_separately", "Missing separate activation boundary");
  return {
    intake: "verified",
    campaign_id: manifest.campaign_id,
    upstream_run_id: identity.run_id,
    upstream_plan_sha256: manifest.artifacts.plan.sha256,
    ready_for: "implementation work beginning with discovery",
    live_apply_authorized_by_checker: false,
    implementation_approved_by_checker: false,
  };
}

export function checkCampaign(planDir: string) {
  const root = realpathSync(planDir);
  const manifest = JSON.parse(readFileSync(resolve(root, "upstream-manifest.json"), "utf8")) as Manifest;
  const snapshots = {} as Record<Key, Buffer>;
  for (const key of Object.keys(artifactPaths) as Key[]) {
    // Read only the fixed package paths, never arbitrary manifest paths.
    const actual = realpathSync(resolve(root, "upstream", artifactPaths[key]));
    const within = relative(root, actual);
    requireThat(within !== ".." && !within.startsWith(`..${sep}`) && !isAbsolute(within), `Snapshot escapes campaign: ${key}`);
    snapshots[key] = readFileSync(actual);
  }
  return verifyBundle(manifest, snapshots);
}

if (import.meta.main) {
  try {
    requireThat(process.argv.length === 3, "Usage: bun check-implementation-handoff.ts <plan_dir>");
    console.log(JSON.stringify(checkCampaign(process.argv[2]), null, 2));
  } catch (error) {
    console.error(`Intake blocked: ${error instanceof Error ? error.message : error}`);
    process.exitCode = 1;
  }
}

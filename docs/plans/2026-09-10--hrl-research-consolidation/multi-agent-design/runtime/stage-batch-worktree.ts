/** Create an isolated, no-commit candidate batch from selected source paths. */
import { cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";

type Check = { id: string; command: string[] };
type Config = { source_root: string; staging_root: string; batch_id: string; paths: string[]; validation?: Check[] };
const cfg = JSON.parse(readFileSync(process.argv[2], "utf8")) as Config;
if (!cfg.source_root || !cfg.staging_root || !/^[a-z0-9][a-z0-9-]+$/.test(cfg.batch_id) || !Array.isArray(cfg.paths) || !cfg.paths.length) throw Error("Missing batch staging inputs");
const source = resolve(cfg.source_root), target = resolve(cfg.staging_root, cfg.batch_id);
if (relative(resolve(cfg.staging_root), target).startsWith("..") || existsSync(target)) throw Error("Batch worktree target must be fresh and under staging_root");
for (const path of cfg.paths) if (!path || path.startsWith("/") || path.split("/").includes("..")) throw Error(`Unsafe source path: ${path}`);
function run(command: string[], cwd = source) { const result = Bun.spawnSync(command, { cwd, stdout: "pipe", stderr: "pipe" }); if (result.exitCode !== 0) throw Error(`${command.join(" ")}: ${result.stderr}`); return result.stdout.toString(); }
run(["git", "rev-parse", "--is-inside-work-tree"]); mkdirSync(dirname(target), { recursive: true });
run(["git", "worktree", "add", "--detach", target, "HEAD"]);
try {
  const patch = run(["git", "diff", "--binary", "HEAD", "--", ...cfg.paths]);
  if (patch) { const applied = Bun.spawnSync(["git", "apply", "--whitespace=nowarn", "-"], { cwd: target, stdin: new TextEncoder().encode(patch), stdout: "pipe", stderr: "pipe" }); if (applied.exitCode !== 0) throw Error(`Could not apply selected source snapshot: ${applied.stderr}`); }
  for (const path of cfg.paths) { const from = resolve(source, path), to = resolve(target, path); if (existsSync(from) && !existsSync(to)) { mkdirSync(dirname(to), { recursive: true }); cpSync(from, to, { recursive: true }); } }
  const checks = (cfg.validation || []).map(check => { const result = Bun.spawnSync(check.command, { cwd: target, stdout: "pipe", stderr: "pipe" }); const receipt = { id: check.id, command: check.command, exit_code: result.exitCode, stdout: result.stdout.toString(), stderr: result.stderr.toString() }; writeFileSync(resolve(target, `.batch-${check.id}.json`), JSON.stringify(receipt, null, 2) + "\n"); return receipt; });
  const manifest = { kind: "experimental-staged-batch", batch_id: cfg.batch_id, source_root: source, worktree_root: target, paths: cfg.paths, commit: run(["git", "rev-parse", "HEAD"]), validation: checks.map(({ stdout, stderr, ...receipt }) => receipt), status: checks.some(check => check.exit_code !== 0) ? "validation_failed" : "ready_for_grouped_evaluation", apply_authority: "closed", committed: false };
  writeFileSync(resolve(target, ".batch-manifest.json"), JSON.stringify(manifest, null, 2) + "\n"); console.log(JSON.stringify(manifest));
} catch (error) { writeFileSync(resolve(target, ".batch-failure.json"), JSON.stringify({ error: String(error), source_root: source, worktree_root: target, apply_authority: "closed" }, null, 2) + "\n"); throw error; }

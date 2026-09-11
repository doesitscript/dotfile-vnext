/** Bounded, read-only parallel preflight for a parent-owned implementation run. */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";

type Job = { id: string; purpose: string; command: string[]; timeout_seconds?: number };
type Config = { project_root: string; plan_dir: string; output_dir: string; run_id: string; jobs: Job[] };
const cfg = JSON.parse(readFileSync(process.argv[2], "utf8")) as Config;
if (!cfg.project_root || !cfg.plan_dir || !cfg.output_dir || !cfg.run_id || !Array.isArray(cfg.jobs)) throw Error("Missing parallel preflight inputs");
if (cfg.jobs.length < 1 || cfg.jobs.length > 4) throw Error("Parallel preflight allows one to four bounded jobs");
const root = resolve(cfg.project_root), out = resolve(cfg.output_dir);
if (existsSync(out)) throw Error("parallel preflight output_dir must be fresh");
mkdirSync(out, { recursive: true });
const safe = new Set(["rg", "find", "git", "ansible-inventory", "ansible-playbook", "bun"]);
function validate(job: Job) {
  if (!/^[a-z0-9][a-z0-9-]+$/.test(job.id) || !job.purpose || !Array.isArray(job.command) || !job.command.length) throw Error(`Invalid job: ${job.id}`);
  if (!safe.has(basename(job.command[0]))) throw Error(`Job ${job.id} uses a non-read-only command`);
  const text = job.command.slice(1).join(" ");
  if (/\b(apply|destroy|delete|remove|reset|checkout|commit|push|pull|install|deploy)\b/i.test(text)) throw Error(`Job ${job.id} has a mutation-capable argument`);
  if (basename(job.command[0]) === "ansible-playbook" && !/(--syntax-check|--list-(tasks|tags|hosts)|--check)/.test(text)) throw Error(`Job ${job.id} must use an Ansible inspection mode`);
  if (basename(job.command[0]) === "bun" && job.command[1] !== "test" && job.command[1] !== "--version") throw Error(`Job ${job.id} may only run Bun tests`);
}
for (const job of cfg.jobs) validate(job);
const started_at = new Date().toISOString();
const receipts = await Promise.all(cfg.jobs.map(async job => {
  const started = Date.now(), result = Bun.spawnSync(job.command, { cwd: root, stdout: "pipe", stderr: "pipe", timeout: (job.timeout_seconds ?? 120) * 1000 });
  const receipt = { id: job.id, purpose: job.purpose, command: job.command, started_at, elapsed_ms: Date.now() - started, exit_code: result.exitCode, stdout_path: `${job.id}.stdout.log`, stderr_path: `${job.id}.stderr.log` };
  writeFileSync(`${out}/${receipt.stdout_path}`, result.stdout.toString());
  writeFileSync(`${out}/${receipt.stderr_path}`, result.stderr.toString());
  writeFileSync(`${out}/${job.id}.json`, JSON.stringify(receipt, null, 2) + "\n");
  return receipt;
}));
const manifest = { kind: "bounded-read-only-parallel-preflight", run_id: cfg.run_id, project_root: root, plan_dir: resolve(cfg.plan_dir), started_at, completed_at: new Date().toISOString(), jobs: receipts, synthesis_owner: "implementer", evaluator_use: "review receipt relevance and failures; do not treat this as implementation evidence" };
writeFileSync(`${out}/manifest.json`, JSON.stringify(manifest, null, 2) + "\n");
console.log(JSON.stringify({ output_dir: out, manifest: `${out}/manifest.json`, jobs: receipts.map(job => ({ id: job.id, exit_code: job.exit_code })) }));

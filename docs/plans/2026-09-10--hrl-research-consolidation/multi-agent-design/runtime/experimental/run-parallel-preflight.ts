/** Bounded, read-only parallel preflight for a parent-owned implementation run. */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";

type Job = { id: string; purpose: string; command: string[]; timeout_seconds?: number };
type Config = { project_root: string; plan_dir: string; output_dir: string; run_id: string; jobs: Job[] };
const cfg = JSON.parse(readFileSync(process.argv[2], "utf8")) as Config;
if (!cfg.project_root || !cfg.plan_dir || !cfg.output_dir || !cfg.run_id || !Array.isArray(cfg.jobs)) throw Error("Missing parallel preflight inputs");
const root = resolve(cfg.project_root), out = resolve(cfg.output_dir);
if (existsSync(out)) throw Error("parallel preflight output_dir must be fresh");
mkdirSync(out, { recursive: true });
const safe = new Set(["rg", "find", "git", "ansible-inventory", "ansible-playbook", "bun"]);
function incompatibility(job: Partial<Job> | null, seen: Set<string>) {
  if (!job || !/^[a-z0-9][a-z0-9-]+$/.test(job.id || "") || !job.purpose || !Array.isArray(job.command) || !job.command.length) return "invalid job shape";
  if (seen.has(job.id)) return "duplicate job id";
  if (!safe.has(basename(job.command[0]))) return "non-read-only command";
  const text = job.command.slice(1).join(" ");
  if (/\b(apply|destroy|delete|remove|reset|checkout|commit|push|pull|install|deploy)\b/i.test(text)) return "mutation-capable argument";
  if (basename(job.command[0]) === "ansible-playbook" && !/(--syntax-check|--list-(tasks|tags|hosts)|--check)/.test(text)) return "Ansible command lacks inspection mode";
  if (basename(job.command[0]) === "bun" && job.command[1] !== "test" && job.command[1] !== "--version") return "Bun command is not a test";
  return null;
}
const seen = new Set<string>(), admitted: Job[] = [], rejected: { id: string; reason: string }[] = [];
for (const job of cfg.jobs) {
  const reason = admitted.length >= 4 ? "parallel limit reached" : incompatibility(job, seen);
  if (reason) rejected.push({ id: job?.id || "unknown", reason }); else { seen.add(job.id); admitted.push(job); }
}
writeFileSync(`${out}/admission.json`, JSON.stringify({ kind: "parallel-preflight-admission", admitted: admitted.map(job => job.id), rejected }, null, 2) + "\n");
const started_at = new Date().toISOString();
const receipts = await Promise.all(admitted.map(async job => {
  const started = Date.now(), result = Bun.spawnSync(job.command, { cwd: root, stdout: "pipe", stderr: "pipe", timeout: (job.timeout_seconds ?? 120) * 1000 });
  const receipt = { id: job.id, purpose: job.purpose, command: job.command, started_at, elapsed_ms: Date.now() - started, exit_code: result.exitCode, stdout_path: `${job.id}.stdout.log`, stderr_path: `${job.id}.stderr.log` };
  writeFileSync(`${out}/${receipt.stdout_path}`, result.stdout.toString());
  writeFileSync(`${out}/${receipt.stderr_path}`, result.stderr.toString());
  writeFileSync(`${out}/${job.id}.json`, JSON.stringify(receipt, null, 2) + "\n");
  return receipt;
}));
const manifest = { kind: "bounded-read-only-parallel-preflight", run_id: cfg.run_id, project_root: root, plan_dir: resolve(cfg.plan_dir), started_at, completed_at: new Date().toISOString(), jobs: receipts, rejected, synthesis_owner: "implementer", evaluator_use: "review receipt relevance and failures; do not treat this as implementation evidence" };
writeFileSync(`${out}/manifest.json`, JSON.stringify(manifest, null, 2) + "\n");
console.log(JSON.stringify({ output_dir: out, manifest: `${out}/manifest.json`, jobs: receipts.map(job => ({ id: job.id, exit_code: job.exit_code })), rejected }));

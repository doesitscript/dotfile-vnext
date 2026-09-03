#!/usr/bin/env bun
/**
 * Phase 1 smoke: call multiagents orchestrator create_team with two Codex roles.
 * Keeps the orchestrator MCP process alive while polling get_team_status.
 */
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { mkdirSync, writeFileSync, existsSync } from "fs";
import { join } from "path";

const PROJECT_DIR = `${process.env.HOME}/develop/oneoffs/phase1-multiagents-smoke`;
const PLAN =
  "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan";
const RECEIPT = join(PLAN, "validation/smoke-create-team-receipt.md");
const RAW = join(PLAN, "validation/smoke-create-team-raw.jsonl");
const SESSION_NAME = "phase1-smoke-outside";
const POLL_MS = 20_000;
const MAX_POLLS = 30; // ~10 minutes

mkdirSync(PROJECT_DIR, { recursive: true });
if (!existsSync(join(PROJECT_DIR, "README.md"))) {
  writeFileSync(
    join(PROJECT_DIR, "README.md"),
    "# Phase 1 smoke workspace\n\nTiny implementer/evaluator ping-pong sandbox.\n",
  );
}

function logLine(obj: unknown) {
  const line = JSON.stringify({ t: new Date().toISOString(), ...(typeof obj === "object" && obj ? obj : { msg: obj }) });
  console.log(line);
  writeFileSync(RAW, line + "\n", { flag: "a" });
}

const transport = new StdioClientTransport({
  command: "multiagents",
  args: ["orchestrator"],
  env: { ...process.env, PATH: `${process.env.HOME}/.bun/bin:${process.env.PATH}` },
  stderr: "pipe",
});

const client = new Client({ name: "phase1-smoke-harness", version: "0.1.0" });
await client.connect(transport);
logLine({ event: "orchestrator_connected" });

const createArgs = {
  project_dir: PROJECT_DIR,
  session_name: SESSION_NAME,
  agents: [
    {
      agent_type: "codex",
      name: "Implementer",
      role: "Software Engineer",
      role_description:
        "Phase-1 smoke implementer. Prefer tiny file edits. Use multiagents-peer MCP tools (set_summary, signal_done, check_messages). Do not expand scope.",
      initial_task: [
        "CRITICAL ORDER: write files FIRST before any doc reading.",
        "1) Immediately write ping.txt containing exactly: ping-1",
        "2) Immediately write review_ready_for_evaluator_smoke.md stating ping.txt is ready.",
        "3) Call set_summary briefly, then signal_done with proof (paths).",
        "4) If evaluator feedback asks for ping-N, update ping.txt and signal_done again.",
        "Do not read parent monorepo docs. This workspace AGENTS.md is sufficient.",
        "Stop after each signal_done; do not declare overall completion yourself.",
      ].join("\n"),
      file_ownership: ["ping.txt", "review_ready_for_evaluator_*.md"],
    },
    {
      agent_type: "codex",
      name: "Evaluator",
      role: "Code Reviewer",
      role_description:
        "Phase-1 smoke evaluator. Own termination. Use multiagents-peer MCP (submit_feedback, approve, set_summary). Keep feedback tiny.",
      initial_task: [
        "CRITICAL: do not read parent monorepo docs. Workspace AGENTS.md is enough.",
        "1) Poll for review_ready_for_evaluator_smoke.md and ping.txt.",
        "2) If ping.txt is ping-1: submit_feedback asking implementer to change it to ping-2.",
        "3) If ping.txt is ping-2: approve and end the loop (evaluator-owned termination).",
        "4) Target 2 handoffs minimum for this smoke.",
      ].join("\n"),
      file_ownership: ["feedback_*.md", "approval_*.md"],
    },
  ],
  plan: [
    { label: "Implementer writes ping-1 + review_ready", agent_name: "Implementer" },
    { label: "Evaluator requests ping-2 feedback", agent_name: "Evaluator" },
    { label: "Implementer writes ping-2 + review_ready", agent_name: "Implementer" },
    { label: "Evaluator approves and terminates", agent_name: "Evaluator" },
  ],
};

logLine({ event: "create_team_request", args: createArgs });
const created = await client.callTool({ name: "create_team", arguments: createArgs });
logLine({ event: "create_team_result", created });

const text = Array.isArray((created as any).content)
  ? (created as any).content.map((c: any) => c.text).join("\n")
  : String(created);
const sessionMatch = text.match(/session[_\s-]?id[:\s]+([a-z0-9-]+)/i) || text.match(/\b(phase1-smoke-pingpong(?:-\d+)?)\b/);
let sessionId = sessionMatch ? sessionMatch[1] : SESSION_NAME;
logLine({ event: "session_id_guess", sessionId, text_preview: text.slice(0, 800) });

const polls: unknown[] = [];
for (let i = 0; i < MAX_POLLS; i++) {
  await Bun.sleep(POLL_MS);
  try {
    const st = await client.callTool({
      name: "get_team_status",
      arguments: { session_id: sessionId },
    });
    polls.push(st);
    logLine({ event: "poll", i, st });
    const stText = Array.isArray((st as any).content)
      ? (st as any).content.map((c: any) => c.text).join("\n")
      : JSON.stringify(st);
    if (
      /Evaluator/i.test(stText) &&
      (/\bapproved\b.*Evaluator|Evaluator.*\bapproved\b/i.test(stText) ||
        /task state\s*\|\s*approved/i.test(stText) ||
        /Workflow:[\s\S]*approved:\s*Evaluator/i.test(stText)) &&
      !/0\/2 agents approved/i.test(stText)
    ) {
      logLine({ event: "early_stop_success_signal", i });
      break;
    }
  } catch (err) {
    logLine({ event: "poll_error", i, err: String(err) });
  }
}

const pingPath = join(PROJECT_DIR, "ping.txt");
const pingContent = existsSync(pingPath) ? Bun.file(pingPath).text() : Promise.resolve("(missing)");
const ping = await pingContent;

const receipt = `---
title: Smoke create_team receipt
created_at: ${new Date().toISOString()}
status: observed
---

# Smoke create_team receipt

## Claim

Called multiagents orchestrator \`create_team\` with two Codex agents
(Implementer + Evaluator) against \`${PROJECT_DIR}\`.

## Session

- requested name: \`${SESSION_NAME}\`
- resolved id guess: \`${sessionId}\`
- create_team text preview:

\`\`\`
${text.slice(0, 2000)}
\`\`\`

## Workspace artifacts

- \`ping.txt\`: ${JSON.stringify(ping).slice(0, 200)}

## Polls

- count: ${polls.length}
- raw log: \`validation/smoke-create-team-raw.jsonl\`

## Operator UI

Browser GUI at http://127.0.0.1:7900 was already up mid-setup (Agents 0 before
team spawn). Re-check Agents tab after this run.
`;

writeFileSync(RECEIPT, receipt);
logLine({ event: "receipt_written", RECEIPT });
console.error("Receipt:", RECEIPT);
// Keep process alive briefly so orchestrator child isn't torn down mid-bootstrap.
await Bun.sleep(5_000);
process.exit(0);

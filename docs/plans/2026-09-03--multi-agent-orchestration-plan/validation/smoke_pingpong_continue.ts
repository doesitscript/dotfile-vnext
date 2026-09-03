#!/usr/bin/env bun
/**
 * Phase 1 smoke continuation: fresh minimal team + direct_agent nudges + poll.
 */
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { existsSync, mkdirSync, writeFileSync } from "fs";
import { join } from "path";

const PROJECT_DIR = `${process.env.HOME}/develop/oneoffs/phase1-multiagents-smoke`;
const PLAN =
  "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan";
const RECEIPT = join(PLAN, "validation/smoke-receipt.md");
const RAW = join(PLAN, "validation/smoke-pingpong-raw.jsonl");
const SESSION = "phase1-smoke-v2";
const SESSION_OLD = "phase1-smoke-outside";

mkdirSync(PROJECT_DIR, { recursive: true });
mkdirSync(join(PROJECT_DIR, ".codex"), { recursive: true });

writeFileSync(
  join(PROJECT_DIR, "AGENTS.md"),
  `# Smoke sandbox ONLY

You are a smoke-test agent. Do exactly what direct messages say.
Do NOT load framework docs, skills, or parent repos.
Use one shell write + multiagents-peer signal_done / submit_feedback / approve.
`,
);

writeFileSync(
  join(PROJECT_DIR, ".codex/config.toml"),
  `# Minimal project config for phase-1 smoke — keep context tiny
model = "gpt-5.4-codex"
approval_policy = "never"

[features]
skills = false
memory = false
`,
);

function log(obj: Record<string, unknown>) {
  const line = JSON.stringify({ t: new Date().toISOString(), ...obj });
  console.log(line);
  writeFileSync(RAW, line + "\n", { flag: "a" });
}

async function brokerPost(path: string, body: object) {
  const res = await fetch(`http://127.0.0.1:7899${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  return res.json();
}

/** CodexDriver slots have peer_id=null; broker to_slot_id is the supported nudge path. */
async function sendToSlot(slotId: number, message: string) {
  const r = await brokerPost("/send-message", {
    from_id: "orchestrator",
    to_slot_id: slotId,
    session_id: SESSION,
    text: message,
    msg_type: "chat",
  });
  log({ event: "send_to_slot", slotId, message: message.slice(0, 120), r });
  return r;
}

async function resolveSlots(): Promise<{ implementer?: number; evaluator?: number }> {
  const slots = (await brokerPost("/slots/list", { session_id: SESSION })) as Array<{
    id: number;
    display_name?: string;
  }>;
  const implementer = slots.find((s) => s.display_name === "Implementer")?.id;
  const evaluator = slots.find((s) => s.display_name === "Evaluator")?.id;
  return { implementer, evaluator };
}

// Best-effort cleanup of prior session
try {
  await brokerPost("/sessions/delete", { id: SESSION_OLD });
  log({ event: "deleted_old_session", id: SESSION_OLD });
} catch (e) {
  log({ event: "delete_old_session_skipped", err: String(e) });
}

const transport = new StdioClientTransport({
  command: "multiagents",
  args: ["orchestrator"],
  env: { ...process.env, PATH: `${process.env.HOME}/.bun/bin:${process.env.PATH}` },
  stderr: "pipe",
});

const client = new Client({ name: "phase1-smoke-continue", version: "0.2.0" });
await client.connect(transport);
log({ event: "orchestrator_connected" });

const createArgs = {
  project_dir: PROJECT_DIR,
  session_name: SESSION,
  agents: [
    {
      agent_type: "codex",
      name: "Implementer",
      role: "Software Engineer",
      role_description: "Smoke implementer. One shell write only, then signal_done.",
      initial_task:
        'ONLY: run shell `printf "ping-1" > ping.txt` then write review_ready_for_evaluator_smoke.md with one line "ready". Then call signal_done with proof. No other work.',
      file_ownership: ["ping.txt", "review_ready_for_evaluator_smoke.md"],
    },
    {
      agent_type: "codex",
      name: "Evaluator",
      role: "Code Reviewer",
      role_description: "Smoke evaluator. Owns termination via approve.",
      initial_task:
        'Wait for review_ready_for_evaluator_smoke.md. If ping.txt is ping-1, submit_feedback to change to ping-2. If ping-2, approve.',
      file_ownership: ["feedback_*.md", "approval_*.md"],
    },
  ],
  plan: [
    { label: "Implementer ping-1", agent_name: "Implementer" },
    { label: "Evaluator feedback", agent_name: "Evaluator" },
    { label: "Implementer ping-2", agent_name: "Implementer" },
    { label: "Evaluator approve", agent_name: "Evaluator" },
  ],
};

const created = await client.callTool({ name: "create_team", arguments: createArgs });
log({ event: "create_team", created });

await Bun.sleep(25_000);

async function direct(target: string, message: string, slots: { implementer?: number; evaluator?: number }) {
  // Implementer is CodexDriver-managed (peer_id null) — use broker slot routing.
  if (target === "Implementer" && slots.implementer) {
    return sendToSlot(slots.implementer, message);
  }
  const r = await client.callTool({
    name: "direct_agent",
    arguments: { session_id: SESSION, target, message },
  });
  log({ event: "direct_agent", target, message, r });
  return r;
}

const slots = await resolveSlots();
log({ event: "resolved_slots", slots });

await direct(
  "Implementer",
  [
    "SMOKE OVERRIDE — do this now, nothing else:",
    "1) shell: printf 'ping-1' > ping.txt",
    "2) write review_ready_for_evaluator_smoke.md containing: ready",
    "3) multiagents-peer: set_summary('ping-1 written') then signal_done('ping.txt + review_ready written')",
  ].join("\n"),
  slots,
);

const handoffs: string[] = [];
for (let i = 0; i < 24; i++) {
  await Bun.sleep(15_000);
  const pingPath = join(PROJECT_DIR, "ping.txt");
  const reviewPath = join(PROJECT_DIR, "review_ready_for_evaluator_smoke.md");
  const ping = existsSync(pingPath) ? await Bun.file(pingPath).text() : "";
  const review = existsSync(reviewPath) ? await Bun.file(reviewPath).text() : "";
  const st = await client.callTool({
    name: "get_team_status",
    arguments: { session_id: SESSION },
  });
  const stText = Array.isArray((st as any).content)
    ? (st as any).content.map((c: any) => c.text).join("\n")
    : JSON.stringify(st);
  log({ event: "poll", i, ping: ping.trim(), review: review.trim().slice(0, 80), stText: stText.slice(0, 600) });

  if (ping.trim() === "ping-1" && review && !handoffs.includes("impl->eval-1")) {
    handoffs.push("impl->eval-1");
    await direct(
      "Evaluator",
      "ping.txt is ping-1 and review_ready exists. submit_feedback asking Implementer to set ping.txt to ping-2 and signal_done again.",
      slots,
    );
  }
  if (ping.trim() === "ping-2" && !handoffs.includes("impl->eval-2")) {
    handoffs.push("impl->eval-2");
    await direct("Evaluator", "ping.txt is ping-2. approve now (evaluator-owned termination).", slots);
  }
  if (/Evaluator.*approved|approved.*Evaluator|task state\s*\|\s*approved/i.test(stText) && ping.trim() === "ping-2") {
    handoffs.push("eval-approved");
    break;
  }
  if (i === 3 && ping.trim() !== "ping-1") {
    await direct(
      "Implementer",
      "Retry now: printf 'ping-1' > ping.txt ; echo ready > review_ready_for_evaluator_smoke.md ; signal_done",
      slots,
    );
  }
  if (handoffs.includes("impl->eval-1") && ping.trim() === "ping-1" && i > 8) {
    await direct(
      "Implementer",
      "Evaluator feedback received. Update ping.txt to ping-2, refresh review_ready, signal_done.",
      slots,
    );
  }
}

const finalPing = existsSync(join(PROJECT_DIR, "ping.txt"))
  ? await Bun.file(join(PROJECT_DIR, "ping.txt")).text()
  : "(missing)";

const receipt = `---
title: Smoke ping-pong receipt
created_at: ${new Date().toISOString()}
status: ${finalPing.trim() === "ping-2" && handoffs.includes("eval-approved") ? "pass-partial" : "blocked"}
---

# Smoke ping-pong receipt

## Session

- \`${SESSION}\` in \`${PROJECT_DIR}\`
- minimal \`.codex/config.toml\` (skills/memory off)

## Handoff trail

${handoffs.map((h) => `- ${h}`).join("\n") || "- (none)"}

## Artifacts

- ping.txt final: \`${finalPing.trim()}\`
- review_ready: ${existsSync(join(PROJECT_DIR, "review_ready_for_evaluator_smoke.md")) ? "present" : "missing"}

## Raw log

\`validation/smoke-pingpong-raw.jsonl\`
`;

writeFileSync(RECEIPT, receipt);
log({ event: "done", handoffs, finalPing: finalPing.trim(), receipt: RECEIPT });
console.error("Receipt:", RECEIPT);
await Bun.sleep(3_000);
process.exit(0);

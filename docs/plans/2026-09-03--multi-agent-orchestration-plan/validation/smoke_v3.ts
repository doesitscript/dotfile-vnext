#!/usr/bin/env bun
/**
 * Phase 1 smoke v3 — fresh session, slot-based broker routing for Implementer,
 * generous per-turn timeouts to accommodate high reasoning_effort.
 */
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { existsSync, mkdirSync, writeFileSync } from "fs";
import { join } from "path";

const PROJECT_DIR = `${process.env.HOME}/develop/oneoffs/phase1-multiagents-smoke`;
const PLAN =
  "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-03--multi-agent-orchestration-plan";
const RECEIPT = join(PLAN, "validation/smoke-receipt.md");
const RAW = join(PLAN, "validation/smoke-v3-raw.jsonl");
const SESSION = "phase1-smoke-v3";

mkdirSync(PROJECT_DIR, { recursive: true });
mkdirSync(join(PROJECT_DIR, ".codex"), { recursive: true });

// Minimal AGENTS.md — no framework, no parent repo bootstrap
writeFileSync(
  join(PROJECT_DIR, "AGENTS.md"),
  `# Smoke sandbox

You are a smoke-test agent. Do only what direct messages tell you.
Do NOT read parent repos or load external docs.
`
);

// Minimal .codex/config.toml — skills/memory off, use global model
writeFileSync(
  join(PROJECT_DIR, ".codex/config.toml"),
  `approval_policy = "never"\n\n[features]\nskills = false\nmemory = false\n`
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

async function getSlots(): Promise<{ implementer?: number; evaluator?: number }> {
  const slots = (await brokerPost("/slots/list", { session_id: SESSION })) as Array<{
    id: number;
    display_name?: string;
    status?: string;
  }>;
  log({ event: "slot_list", slots: slots.map((s) => ({ id: s.id, name: s.display_name, status: s.status })) });
  return {
    implementer: slots.find((s) => s.display_name === "Implementer")?.id,
    evaluator: slots.find((s) => s.display_name === "Evaluator")?.id,
  };
}

/** Nudge a CodexDriver-managed slot (peer_id=null) via broker to_slot_id */
async function nudgeSlot(slotId: number, msg: string) {
  const r = await brokerPost("/send-message", {
    from_id: "orchestrator",
    to_slot_id: slotId,
    session_id: SESSION,
    text: msg,
    msg_type: "chat",
  });
  log({ event: "nudge_slot", slotId, msg: msg.slice(0, 100), r });
}

/** Nudge Evaluator via direct_agent (it has a peer_id) */
async function nudgeDirect(client: Client, target: string, msg: string) {
  const r = await client.callTool({
    name: "direct_agent",
    arguments: { session_id: SESSION, target, message: msg },
  });
  log({ event: "direct_agent", target, msg: msg.slice(0, 100), r });
}

// --- Start orchestrator ---
const transport = new StdioClientTransport({
  command: "multiagents",
  args: ["orchestrator"],
  env: { ...process.env, PATH: `${process.env.HOME}/.bun/bin:${process.env.PATH}` },
  stderr: "pipe",
});
const client = new Client({ name: "smoke-v3", version: "0.3.0" });
await client.connect(transport);
log({ event: "orchestrator_connected" });

// Clean up old sessions
for (const old of ["phase1-smoke-v2", "phase1-smoke-outside"]) {
  try { await brokerPost("/sessions/delete", { id: old }); } catch { /* ok */ }
}

// Create fresh team
const created = await client.callTool({
  name: "create_team",
  arguments: {
    project_dir: PROJECT_DIR,
    session_name: SESSION,
    agents: [
      {
        agent_type: "codex",
        name: "Implementer",
        role: "Engineer",
        role_description: "Write ping.txt then signal done.",
        initial_task: "Write the text ping-1 to a file called ping.txt in your working directory. Use shell. Then call signal_done.",
        file_ownership: ["ping.txt"],
      },
      {
        agent_type: "codex",
        name: "Evaluator",
        role: "Reviewer",
        role_description: "Review ping.txt and approve.",
        initial_task: "Wait. When you receive a message saying ping.txt is ready, read it. If content is ping-1 call submit_feedback asking for ping-2. If content is ping-2 call approve.",
        file_ownership: ["feedback_*.md"],
      },
    ],
  },
});
log({ event: "create_team", result: (created as any)?.content?.[0]?.text?.slice(0, 300) });

// Give agents time to start and handle initial task (turns are slow with high reasoning_effort)
const TURN_WAIT_MS = 3 * 60 * 1000; // 3 min per turn cycle
log({ event: "waiting_for_initial_turns", wait_ms: TURN_WAIT_MS });
await Bun.sleep(TURN_WAIT_MS);

const handoffs: string[] = [];
const pingPath = join(PROJECT_DIR, "ping.txt");

for (let i = 0; i < 20; i++) {
  const slots = await getSlots();
  const ping = existsSync(pingPath) ? await Bun.file(pingPath).text() : "";
  const st = await client.callTool({ name: "get_team_status", arguments: { session_id: SESSION } });
  const stText = ((st as any)?.content ?? []).map((c: any) => c.text).join("\n");
  log({ event: "poll", i, ping: ping.trim(), stText: stText.slice(0, 400) });

  // ping-1 written — nudge evaluator
  if (ping.trim() === "ping-1" && !handoffs.includes("impl->eval-1")) {
    handoffs.push("impl->eval-1");
    log({ event: "handoff", step: "impl->eval-1" });
    if (slots.evaluator) {
      await nudgeDirect(client, "Evaluator", "ping.txt contains ping-1. submit_feedback asking Implementer to write ping-2 instead.");
    }
    await Bun.sleep(TURN_WAIT_MS);
    continue;
  }

  // ping-2 written — nudge evaluator to approve
  if (ping.trim() === "ping-2" && !handoffs.includes("impl->eval-2")) {
    handoffs.push("impl->eval-2");
    log({ event: "handoff", step: "impl->eval-2" });
    try { await nudgeDirect(client, "Evaluator", "ping.txt is now ping-2. Call approve now."); } catch { /* ok */ }
    await Bun.sleep(TURN_WAIT_MS);
    continue;
  }

  // Approved
  if (/approved|task state.*approved/i.test(stText) && ping.trim() === "ping-2") {
    handoffs.push("eval-approved");
    log({ event: "handoff", step: "eval-approved" });
    break;
  }

  // Nudge implementer if stuck (first nudge at i=1, then every 3 polls)
  if (!handoffs.includes("impl->eval-1") && slots.implementer && (i === 1 || i % 3 === 0)) {
    await nudgeSlot(
      slots.implementer,
      "Write ping-1 to ping.txt using shell, then call signal_done. This is the only thing to do."
    );
  }

  await Bun.sleep(90_000); // 90 s between polls
}

// Final state
const finalPing = existsSync(pingPath) ? await Bun.file(pingPath).text() : "(missing)";
const passed = finalPing.trim() === "ping-2" && handoffs.includes("eval-approved");

const receipt = `---
title: Smoke ping-pong receipt (v3)
created_at: ${new Date().toISOString()}
session: ${SESSION}
status: ${passed ? "pass" : handoffs.length > 0 ? "partial" : "blocked"}
---

# Smoke v3 receipt

## Handoffs
${handoffs.map((h) => `- ${h}`).join("\n") || "- (none)"}

## Final ping.txt
\`${finalPing.trim()}\`

## Raw log
\`validation/smoke-v3-raw.jsonl\`
`;

writeFileSync(RECEIPT, receipt);
log({ event: "done", passed, handoffs, finalPing: finalPing.trim() });
console.error("Done. Status:", passed ? "PASS" : "BLOCKED");
console.error("Receipt:", RECEIPT);
await Bun.sleep(2_000);
process.exit(passed ? 0 : 2);

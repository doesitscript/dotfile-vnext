#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const GLOBAL_NODE_MODULES = "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules";
const FIRECRAWL_SDK_BASE = path.join(
  GLOBAL_NODE_MODULES,
  "firecrawl-mcp",
  "node_modules",
  "@modelcontextprotocol",
  "sdk",
  "dist",
  "esm",
);
const CONTEXT7_SDK_BASE = path.join(
  GLOBAL_NODE_MODULES,
  "@upstash",
  "context7-mcp",
  "node_modules",
  "@modelcontextprotocol",
  "sdk",
  "dist",
  "esm",
);

const { Client } = await import(`file://${path.join(FIRECRAWL_SDK_BASE, "client", "index.js")}`);
const { StdioClientTransport } = await import(
  `file://${path.join(FIRECRAWL_SDK_BASE, "client", "stdio.js")}`
);

const SERVER_CONFIG = {
  firecrawl: {
    command: "/Users/joshc/.nvm/versions/node/v20.20.0/bin/firecrawl-mcp",
    envFile: "/Users/joshc/.config/dotfile-vnext/mcp/env.d/firecrawl.env",
  },
  context7: {
    command: "/Users/joshc/.nvm/versions/node/v20.20.0/bin/context7-mcp",
    envFile: "/Users/joshc/.config/dotfile-vnext/mcp/env.d/context7.env",
  },
};

function usage() {
  console.error(
    "Usage: mcp_tool_client.mjs <firecrawl|context7> <list-tools|call> [tool-name] [json-args-or-@file]",
  );
  process.exit(64);
}

function parseEnvFile(envFile) {
  const env = {};
  const text = fs.readFileSync(envFile, "utf8");
  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#")) {
      continue;
    }
    const match = line.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (!match) {
      continue;
    }
    let value = match[2].trim();
    if (
      (value.startsWith("'") && value.endsWith("'")) ||
      (value.startsWith('"') && value.endsWith('"'))
    ) {
      value = value.slice(1, -1);
    }
    env[match[1]] = value.trim();
  }
  return env;
}

function parseJsonArg(rawValue) {
  if (!rawValue) {
    return {};
  }
  if (rawValue.startsWith("@")) {
    return JSON.parse(fs.readFileSync(rawValue.slice(1), "utf8"));
  }
  return JSON.parse(rawValue);
}

async function main() {
  const [serverName, action, toolName, rawArgs] = process.argv.slice(2);
  if (!serverName || !action) {
    usage();
  }

  const server = SERVER_CONFIG[serverName];
  if (!server) {
    console.error(`Unknown server: ${serverName}`);
    process.exit(65);
  }

  const env = {
    ...process.env,
    ...parseEnvFile(server.envFile),
    LANG: "en_US.UTF-8",
    LC_ALL: "en_US.UTF-8",
    LC_CTYPE: "en_US.UTF-8",
  };
  if (serverName === "firecrawl") {
    delete env.FIRECRAWL_API_KEY;
  }
  if (serverName === "context7") {
    delete env.CONTEXT7_API_KEY;
  }

  const transport = new StdioClientTransport({
    command: server.command,
    args: [],
    env,
    stderr: "pipe",
  });
  const client = new Client(
    {
      name: "langfuse-guides-packet-client",
      version: "0.1.0",
    },
    { capabilities: {} },
  );

  await client.connect(transport);

  try {
    if (action === "list-tools") {
      const result = await client.listTools();
      process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
      return;
    }

    if (action !== "call" || !toolName) {
      usage();
    }

    const result = await client.callTool({
      name: toolName,
      arguments: parseJsonArg(rawArgs),
    });
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  } finally {
    await transport.close();
  }
}

await main();

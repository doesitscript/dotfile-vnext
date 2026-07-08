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

const { Client } = await import(`file://${path.join(FIRECRAWL_SDK_BASE, "client", "index.js")}`);
const { StdioClientTransport } = await import(
  `file://${path.join(FIRECRAWL_SDK_BASE, "client", "stdio.js")}`
);

export const SERVER_CONFIG = {
  firecrawl: {
    command: "/Users/joshc/.nvm/versions/node/v20.20.0/bin/firecrawl-mcp",
    envFile: "/Users/joshc/.config/dotfile-vnext/mcp/env.d/firecrawl.env",
  },
  context7: {
    command: "/Users/joshc/.nvm/versions/node/v20.20.0/bin/context7-mcp",
    envFile: "/Users/joshc/.config/dotfile-vnext/mcp/env.d/context7.env",
  },
};

function stripInlineComment(value) {
  let quote = null;
  for (let index = 0; index < value.length; index += 1) {
    const char = value[index];
    if ((char === "'" || char === '"') && value[index - 1] !== "\\") {
      if (quote === char) {
        quote = null;
      } else if (!quote) {
        quote = char;
      }
    }
    if (char === "#" && !quote) {
      return value.slice(0, index).trimEnd();
    }
  }
  return value.trimEnd();
}

export function parseEnvFile(envFile) {
  const env = {};
  const lines = fs.readFileSync(envFile, "utf8").split(/\r?\n/);

  for (let index = 0; index < lines.length; index += 1) {
    const rawLine = lines[index];
    const trimmed = rawLine.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const match = rawLine.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
    if (!match) {
      continue;
    }

    const key = match[1];
    let value = match[2];
    const quote = value[0];
    if (quote === "'" || quote === '"') {
      while (!(value.endsWith(quote) && value.length > 1) && index + 1 < lines.length) {
        index += 1;
        value += `\n${lines[index]}`;
      }
      if (value.endsWith(quote)) {
        value = value.slice(1, -1);
      } else {
        value = value.slice(1);
      }
      env[key] = value.trim();
      continue;
    }

    env[key] = stripInlineComment(value).trim();
  }

  return env;
}

export function buildServerEnv(serverName) {
  const server = SERVER_CONFIG[serverName];
  if (!server) {
    throw new Error(`Unknown server: ${serverName}`);
  }
  return {
    ...process.env,
    ...parseEnvFile(server.envFile),
    LANG: "en_US.UTF-8",
    LC_ALL: "en_US.UTF-8",
    LC_CTYPE: "en_US.UTF-8",
  };
}

export function extractToolText(result) {
  const textChunk = (result.content || []).find((item) => item.type === "text");
  if (!textChunk) {
    throw new Error(`MCP result missing text content: ${JSON.stringify(result).slice(0, 500)}`);
  }
  return textChunk.text;
}

function parseJsonTextPayload(text) {
  const trimmed = text.trim();
  if (!trimmed) {
    throw new Error("MCP text payload is empty");
  }
  try {
    return JSON.parse(trimmed);
  } catch {}

  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenced) {
    return JSON.parse(fenced[1].trim());
  }

  const firstBrace = Math.min(
    ...["{", "["]
      .map((token) => trimmed.indexOf(token))
      .filter((value) => value >= 0),
  );
  if (Number.isFinite(firstBrace) && firstBrace >= 0) {
    const candidate = trimmed.slice(firstBrace);
    try {
      return JSON.parse(candidate);
    } catch {}
  }

  throw new Error(`Could not parse JSON payload from MCP text: ${trimmed.slice(0, 300)}`);
}

export function extractJsonPayload(result) {
  return parseJsonTextPayload(extractToolText(result));
}

export function inferLibraryIdFromResolveOutput(text) {
  const line = text.split("\n").find((entry) => entry.includes("/"));
  if (!line) {
    return null;
  }
  return line.trim().split(/\s+/).find((token) => token.startsWith("/")) || null;
}

export async function withMcpClient(serverName, callback) {
  const server = SERVER_CONFIG[serverName];
  if (!server) {
    throw new Error(`Unknown server: ${serverName}`);
  }

  const transport = new StdioClientTransport({
    command: server.command,
    args: [],
    env: buildServerEnv(serverName),
    stderr: "pipe",
  });
  const client = new Client(
    {
      name: "ai-library-entry-mcp-client",
      version: "0.1.0",
    },
    { capabilities: {} },
  );

  await client.connect(transport);
  try {
    return await callback(client);
  } finally {
    await transport.close();
  }
}

export async function callMcpTool(serverName, toolName, args = {}) {
  return withMcpClient(serverName, async (client) =>
    client.callTool({
      name: toolName,
      arguments: args,
    })
  );
}

export async function listMcpTools(serverName) {
  return withMcpClient(serverName, async (client) => client.listTools());
}

function usage() {
  console.error(
    "Usage: mcp_tool_client.mjs <firecrawl|context7> <list-tools|call> [tool-name] [json-args-or-@file]",
  );
  process.exit(64);
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

export async function runMcpToolCli(argv = process.argv.slice(2)) {
  const [serverName, action, toolName, rawArgs] = argv;
  if (!serverName || !action) {
    usage();
  }

  if (action === "list-tools") {
    const result = await listMcpTools(serverName);
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }

  if (action !== "call" || !toolName) {
    usage();
  }

  const result = await callMcpTool(serverName, toolName, parseJsonArg(rawArgs));
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

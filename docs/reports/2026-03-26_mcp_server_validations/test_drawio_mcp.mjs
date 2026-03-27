import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { Client } from "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/@drawio/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js";
import { StdioClientTransport } from "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/@drawio/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const serverPath = "/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp";
const outDir = __dirname;

const cases = [
  {
    id: "mermaid",
    tool: "open_drawio_mermaid",
    sourceFile: "oauth2_auth_flow.mmd",
    arguments: {
      dark: "true",
    },
  },
  {
    id: "csv",
    tool: "open_drawio_csv",
    sourceFile: "aws_network_topology.csvimport.txt",
    arguments: {
      lightbox: true,
    },
  },
  {
    id: "xml",
    tool: "open_drawio_xml",
    sourceFile: "mcp_validation_architecture.drawio.xml",
    arguments: {
      dark: "auto",
    },
  },
];

function extractUrl(text) {
  const match = text.match(/https:\/\/app\.diagrams\.net\/\S+/);
  return match ? match[0] : null;
}

function toMarkdown(results) {
  const lines = [];
  lines.push("# draw.io MCP validation");
  lines.push("");
  lines.push(`Generated: ${results.generatedAt}`);
  lines.push("");
  lines.push("## Server");
  lines.push("");
  lines.push(`- Command: \`${results.server.command}\``);
  lines.push(`- Package version: \`${results.server.version}\``);
  lines.push(`- Reported server info: \`${results.server.serverInfo.name} ${results.server.serverInfo.version}\``);
  lines.push("");
  lines.push("## Tools");
  lines.push("");
  for (const tool of results.tools) {
    lines.push(`- \`${tool.name}\`: ${tool.description}`);
  }
  lines.push("");
  lines.push("## Runs");
  lines.push("");
  for (const run of results.runs) {
    lines.push(`### ${run.id}`);
    lines.push("");
    lines.push(`- Tool: \`${run.tool}\``);
    lines.push(`- Source: [${run.sourceFile}](./${run.sourceFile})`);
    lines.push(`- URL: ${run.url ?? "not found"}`);
    lines.push(`- Response JSON: [${run.responseFile}](./${run.responseFile})`);
    lines.push("");
  }
  if (results.stderr.length > 0) {
    lines.push("## Stderr");
    lines.push("");
    for (const line of results.stderr) {
      lines.push(`- ${line}`);
    }
    lines.push("");
  }
  lines.push("## Notes");
  lines.push("");
  lines.push("- This MCP server is a launcher-style tool server: it returns a diagrams.net URL and also attempts to open that URL in the default browser.");
  lines.push("- It does not save `.drawio` files by itself; the useful output for automation is the returned URL plus the source content you sent.");
  lines.push("- The three exposed tools map directly to the supported content types: Mermaid, CSV import scripts, and native draw.io XML.");
  lines.push("");
  return `${lines.join("\n")}\n`;
}

async function main() {
  const transport = new StdioClientTransport({
    command: serverPath,
    stderr: "pipe",
  });
  const stderrLines = [];

  if (transport.stderr) {
    transport.stderr.on("data", (chunk) => {
      const text = chunk.toString("utf8").trim();
      if (text) {
        stderrLines.push(...text.split(/\r?\n/).filter(Boolean));
      }
    });
  }

  const client = new Client({
    name: "codex-drawio-validation",
    version: "1.0.0",
  });

  await client.connect(transport);

  const toolsResult = await client.listTools();
  const runs = [];

  for (const testCase of cases) {
    const sourcePath = path.join(outDir, testCase.sourceFile);
    const content = await fs.readFile(sourcePath, "utf8");
    const response = await client.callTool({
      name: testCase.tool,
      arguments: {
        ...testCase.arguments,
        content,
      },
    });
    const text = response.content
      .filter((item) => item.type === "text")
      .map((item) => item.text)
      .join("\n");
    const url = extractUrl(text);
    const responseFile = `${testCase.id}.response.json`;
    await fs.writeFile(
      path.join(outDir, responseFile),
      JSON.stringify(
        {
          id: testCase.id,
          tool: testCase.tool,
          arguments: testCase.arguments,
          response,
          url,
        },
        null,
        2,
      ) + "\n",
      "utf8",
    );
    runs.push({
      id: testCase.id,
      tool: testCase.tool,
      sourceFile: testCase.sourceFile,
      responseFile,
      url,
    });
  }

  const results = {
    generatedAt: new Date().toISOString(),
    server: {
      command: serverPath,
      version: "1.1.8",
      serverInfo: client.getServerVersion(),
      capabilities: client.getServerCapabilities(),
    },
    tools: toolsResult.tools.map((tool) => ({
      name: tool.name,
      description: tool.description,
      inputSchema: tool.inputSchema,
    })),
    runs,
    stderr: stderrLines,
  };

  await fs.writeFile(
    path.join(outDir, "drawio_mcp_validation_results.json"),
    JSON.stringify(results, null, 2) + "\n",
    "utf8",
  );
  await fs.writeFile(
    path.join(outDir, "README.md"),
    toMarkdown(results),
    "utf8",
  );

  await client.close();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

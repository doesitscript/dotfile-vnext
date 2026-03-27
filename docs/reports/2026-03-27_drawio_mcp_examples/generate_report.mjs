import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { Client } from "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/drawio-mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js";
import { StdioClientTransport } from "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/drawio-mcp-server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const serverCommand =
  "/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp-server";
const packageJsonPath =
  "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/drawio-mcp-server/package.json";
const pluginSourcePath =
  "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules/drawio-mcp-server/build/plugin/mcp-plugin.js";
const serverArgs = ["--editor", "--extension-port", "3347", "--http-port", "3004"];

const selectedShapes = [
  "umlActor",
  "mxgraph.aws4.vpc",
  "mxgraph.aws4.api_gateway",
  "mxgraph.aws4.ec2",
  "mxgraph.aws4.lambda",
  "mxgraph.aws4.sqs",
  "mxgraph.aws4.dynamodb",
  "mxgraph.aws4.rds",
];

function escapeRegExp(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function extractShape(pluginSource, shapeName) {
  const escapedName = escapeRegExp(shapeName);
  const keyPattern = shapeName.includes(".")
    ? `"${escapedName}"`
    : escapedName;
  const pattern = new RegExp(
    `${keyPattern}:\\s*\\{[\\s\\S]*?category:\\s*"([^"]+)"[\\s\\S]*?style:\\s*"([^"]*)"`,
    "s",
  );
  const match = pluginSource.match(pattern);
  if (!match) {
    return {
      shape_name: shapeName,
      found: false,
    };
  }
  return {
    shape_name: shapeName,
    found: true,
    category_id: match[1],
    style: match[2],
  };
}

function buildAwsAccountExample() {
  return `<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1280" dy="720" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1280" pageHeight="720" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="2" value="Page-1" parent="1" />
    <mxCell id="actor1" value="Developer" style="shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;outlineConnect=0;" vertex="1" parent="2">
      <mxGeometry x="20" y="220" width="60" height="120" as="geometry" />
    </mxCell>
    <mxCell id="account1" value="AWS Account" style="swimlane;startSize=34;rounded=1;container=1;horizontal=0;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#232F3E;fontStyle=1;swimlaneFillColor=default;pointerEvents=0;" vertex="1" parent="2">
      <mxGeometry x="120" y="60" width="920" height="540" as="geometry" />
    </mxCell>
    <mxCell id="apigw1" value="Public API" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#8C4FFF;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.api_gateway;" vertex="1" parent="account1">
      <mxGeometry x="80" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="vpc1" value="VPC" style="swimlane;startSize=30;rounded=1;container=1;horizontal=0;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#8C4FFF;dashed=1;fontStyle=1;pointerEvents=0;" vertex="1" parent="account1">
      <mxGeometry x="220" y="90" width="420" height="330" as="geometry" />
    </mxCell>
    <mxCell id="lambda1" value="Handler" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;" vertex="1" parent="vpc1">
      <mxGeometry x="90" y="80" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="ec21" value="Admin Box" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.ec2;" vertex="1" parent="vpc1">
      <mxGeometry x="90" y="200" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="queue1" value="Jobs" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.sqs;" vertex="1" parent="vpc1">
      <mxGeometry x="250" y="140" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="ddb1" value="State" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#C925D1;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.dynamodb;" vertex="1" parent="account1">
      <mxGeometry x="710" y="160" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="bucket1" value="Bucket (generic)" style="shape=dataStorage;whiteSpace=wrap;html=1;fixedSize=1;fillColor=#FFF2CC;strokeColor=#D6B656;" vertex="1" parent="account1">
      <mxGeometry x="700" y="300" width="120" height="80" as="geometry" />
    </mxCell>
    <mxCell id="edge1" value="calls" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="2" source="actor1" target="apigw1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge2" value="invokes" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="account1" source="apigw1" target="lambda1">
      <mxGeometry relative="1" as="geometry">
        <Array as="points">
          <mxPoint x="220" y="215" />
        </Array>
      </mxGeometry>
    </mxCell>
    <mxCell id="edge3" value="queues" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="vpc1" source="lambda1" target="queue1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge4" value="reads/writes" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="account1" source="lambda1" target="ddb1">
      <mxGeometry relative="1" as="geometry">
        <Array as="points">
          <mxPoint x="530" y="185" />
        </Array>
      </mxGeometry>
    </mxCell>
    <mxCell id="edge5" value="uploads" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;dashed=1;" edge="1" parent="account1" source="ec21" target="bucket1">
      <mxGeometry relative="1" as="geometry">
        <Array as="points">
          <mxPoint x="510" y="365" />
        </Array>
      </mxGeometry>
    </mxCell>
  </root>
</mxGraphModel>
`;
}

function buildAwsQueueExample() {
  return `<?xml version="1.0" encoding="UTF-8"?>
<mxGraphModel dx="1280" dy="720" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1280" pageHeight="720" math="0" shadow="0" adaptiveColors="auto">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    <mxCell id="2" value="Page-1" parent="1" />
    <mxCell id="actor2" value="Customer" style="shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;outlineConnect=0;" vertex="1" parent="2">
      <mxGeometry x="30" y="160" width="60" height="120" as="geometry" />
    </mxCell>
    <mxCell id="api2" value="API Gateway" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#8C4FFF;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.api_gateway;" vertex="1" parent="2">
      <mxGeometry x="150" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="lambda2" value="Submit Job" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;" vertex="1" parent="2">
      <mxGeometry x="310" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="queue2" value="SQS Queue" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#E7157B;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.sqs;" vertex="1" parent="2">
      <mxGeometry x="470" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="ec22" value="Worker EC2" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.ec2;" vertex="1" parent="2">
      <mxGeometry x="640" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="db2" value="RDS" style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#C925D1;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.rds;" vertex="1" parent="2">
      <mxGeometry x="810" y="170" width="90" height="90" as="geometry" />
    </mxCell>
    <mxCell id="e21" value="HTTPS" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="2" source="actor2" target="api2">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e22" value="invoke" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="2" source="api2" target="lambda2">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e23" value="enqueue" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="2" source="lambda2" target="queue2">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e24" value="consume" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="2" source="queue2" target="ec22">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="e25" value="persist" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;" edge="1" parent="2" source="ec22" target="db2">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
  </root>
</mxGraphModel>
`;
}

async function writeJson(name, value) {
  await fs.writeFile(
    path.join(__dirname, name),
    JSON.stringify(value, null, 2) + "\n",
    "utf8",
  );
}

async function main() {
  const packageJson = JSON.parse(await fs.readFile(packageJsonPath, "utf8"));
  const pluginSource = await fs.readFile(pluginSourcePath, "utf8");

  const transport = new StdioClientTransport({
    command: serverCommand,
    args: serverArgs,
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
    name: "codex-drawio-report",
    version: "1.0.0",
  });

  await client.connect(transport);
  const toolsResult = await client.listTools();
  await client.close();

  const runtimeInfo = {
    generated_at: new Date().toISOString(),
    command: serverCommand,
    args: serverArgs,
    package: {
      name: packageJson.name,
      version: packageJson.version,
    },
    server_info: client.getServerVersion(),
    notes: [
      "Tool listing was captured live from a stdio-launched drawio-mcp-server instance.",
      "Interactive shape-library calls require a browser-backed editor session; this report therefore combines live tool discovery with source-backed shape examples.",
    ],
    stderr: stderrLines,
  };

  const toolInventory = {
    ...runtimeInfo,
    tool_count: toolsResult.tools.length,
    tools: toolsResult.tools.map((tool) => ({
      name: tool.name,
      description: tool.description,
      input_schema: tool.inputSchema,
    })),
  };

  const shapeInventory = {
    generated_at: runtimeInfo.generated_at,
    source_file: pluginSourcePath,
    selected_shapes: selectedShapes.map((shapeName) =>
      extractShape(pluginSource, shapeName),
    ),
    notes: [
      "These styles were extracted from the installed drawio-mcp-server 1.8.0 plugin bundle.",
      "No S3-specific AWS shape key surfaced in the installed plugin bundle during this pass, so the examples use VPC/API Gateway/Lambda/EC2/SQS/DynamoDB/RDS plus a generic storage shape for a bucket-like placeholder.",
    ],
  };

  const toolExamples = {
    generated_at: runtimeInfo.generated_at,
    example_calls: [
      { name: "get-shape-categories", arguments: {} },
      {
        name: "get-shapes-in-category",
        arguments: { category_id: "mxgraph.aws4.network" },
      },
      {
        name: "get-shape-by-name",
        arguments: { shape_name: "mxgraph.aws4.lambda" },
      },
      {
        name: "add-cell-of-shape",
        arguments: {
          shape_name: "mxgraph.aws4.api_gateway",
          x: 150,
          y: 170,
          width: 90,
          height: 90,
          text: "Public API",
        },
      },
      {
        name: "create-layer",
        arguments: { name: "Annotations" },
      },
      {
        name: "list-paged-model",
        arguments: {
          page: 0,
          page_size: 25,
          filter: {
            cell_type: "vertex",
          },
        },
      },
      {
        name: "add-edge",
        arguments: {
          source_id: "apigw1",
          target_id: "lambda1",
          text: "invokes",
        },
      },
    ],
  };

  await writeJson("drawio_tools.live.json", toolInventory);
  await writeJson("selected_shape_styles.source.json", shapeInventory);
  await writeJson("tool_call_examples.json", toolExamples);

  await fs.writeFile(
    path.join(__dirname, "aws_account_vpc_example.drawio.xml"),
    buildAwsAccountExample(),
    "utf8",
  );
  await fs.writeFile(
    path.join(__dirname, "aws_queue_worker_example.drawio.xml"),
    buildAwsQueueExample(),
    "utf8",
  );

  const readme = `# drawio-mcp-server examples

Generated: ${runtimeInfo.generated_at}

## What this folder shows

- A live tool inventory from the installed \`${packageJson.name}@${packageJson.version}\`
- Source-backed AWS/UML shape style extraction from the installed plugin bundle
- Example MCP tool-call payloads you can reuse when driving the server
- Two small \`.drawio.xml\` examples you can open in draw.io and design from

## Runtime used

- Command: \`${serverCommand}\`
- Args: \`${serverArgs.join(" ")}\`
- Package version: \`${packageJson.version}\`

## Files

- [drawio_tools.live.json](./drawio_tools.live.json)
  - Live \`listTools()\` capture from the installed server
- [selected_shape_styles.source.json](./selected_shape_styles.source.json)
  - Extracted AWS/UML shape styles from the installed plugin source
- [tool_call_examples.json](./tool_call_examples.json)
  - Reusable MCP call payload examples for shape lookup, layering, inspection, and edge creation
- [aws_account_vpc_example.drawio.xml](./aws_account_vpc_example.drawio.xml)
  - AWS account/VPC sketch using VPC, API Gateway, Lambda, EC2, SQS, and DynamoDB styles, plus a generic storage placeholder for a bucket-like node
- [aws_queue_worker_example.drawio.xml](./aws_queue_worker_example.drawio.xml)
  - Small queue-processing example using API Gateway, Lambda, SQS, EC2, and RDS

## Notes

- The installed server is the interactive \`drawio-mcp-server\` line, not the older open-URL-only package.
- Live tool discovery succeeded in this report.
- Browser-backed shape-library calls were not completed headlessly during this run, so shape examples are grounded in the installed plugin source bundle.
- I did not find an S3-specific AWS key in the installed plugin bundle during this pass. If you want, the next step is a fully interactive browser-backed validation pass against the running editor to confirm whether S3 exists under another library key.
`;

  await fs.writeFile(path.join(__dirname, "README.md"), readme, "utf8");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

# drawio-mcp-server examples

Generated: 2026-03-27T09:28:16.524Z

## What this folder shows

- A live tool inventory from the installed `drawio-mcp-server@1.8.0`
- Source-backed AWS/UML shape style extraction from the installed plugin bundle
- Example MCP tool-call payloads you can reuse when driving the server
- Two small `.drawio.xml` examples you can open in draw.io and design from

## Runtime used

- Command: `/Users/joshc/.nvm/versions/node/v20.20.0/bin/drawio-mcp-server`
- Args: `--editor --extension-port 3347 --http-port 3004`
- Package version: `1.8.0`

## Files

- [drawio_tools.live.json](./drawio_tools.live.json)
  - Live `listTools()` capture from the installed server
- [selected_shape_styles.source.json](./selected_shape_styles.source.json)
  - Extracted AWS/UML shape styles from the installed plugin source
- [tool_call_examples.json](./tool_call_examples.json)
  - Reusable MCP call payload examples for shape lookup, layering, inspection, and edge creation
- [aws_account_vpc_example.drawio.xml](./aws_account_vpc_example.drawio.xml)
  - AWS account/VPC sketch using VPC, API Gateway, Lambda, EC2, SQS, and DynamoDB styles, plus a generic storage placeholder for a bucket-like node
- [aws_queue_worker_example.drawio.xml](./aws_queue_worker_example.drawio.xml)
  - Small queue-processing example using API Gateway, Lambda, SQS, EC2, and RDS

## Notes

- The installed server is the interactive `drawio-mcp-server` line, not the older open-URL-only package.
- Live tool discovery succeeded in this report.
- Browser-backed shape-library calls were not completed headlessly during this run, so shape examples are grounded in the installed plugin source bundle.
- I did not find an S3-specific AWS key in the installed plugin bundle during this pass. If you want, the next step is a fully interactive browser-backed validation pass against the running editor to confirm whether S3 exists under another library key.

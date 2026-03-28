# supergateway

Installs [supergateway](https://github.com/nicholasgriffintn/supergateway) globally via npm. Supergateway bridges MCP servers between transport protocols -- it wraps a stdio-based MCP server and exposes it over SSE (Server-Sent Events) so HTTP clients can connect to it.

## What It Does

1. Sources NVM (via `common/node` dependency)
2. Runs `npm install -g supergateway`

## Dependencies

- `common/node` -- provides NVM + Node.js (pulled in automatically via `meta/main.yml`)

## Supported Platforms

- macOS
- Ubuntu

## Variables

| Variable | Default | Description |
|---|---|---|
| `supergateway_version` | `""` (latest) | Pin to a specific npm version (e.g. `"1.2.3"`) |

## Usage Example

Wrap a stdio MCP server (like mcp-sysoperator) and expose it over SSE on port 3001:

```bash
supergateway --port 3001 --stdio "node /home/joshc/.local/lib/mcp-sysoperator/build/index.js"
```

Test SSE connection:

```bash
curl -N http://localhost:3001/sse
```

Test message POST:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"action": "listFiles", "path": "/"}' \
  http://localhost:3001/message
```

## Ref

https://github.com/nicholasgriffintn/supergateway

# MCP Stdio Proxy Debugging

## Problem

Cursor negotiates the MCP handshake with external MCP servers (ansible, sysoperator),
receives a valid `initialize` response advertising `tools` and `resources` capabilities,
and even calls `tools/list` successfully — but then **does not register the tools** in the
agent's callable tool set. The agent can fetch MCP resources but cannot invoke MCP tools.

This appears to be a Cursor-side bug: it completes the capability negotiation, confirms
the server has tools, and then silently drops them when wiring up the agent.

## What These Proxies Do

Each proxy script interposes between Cursor and the real MCP server using `tee`:

```
Cursor (stdin) ──→ tee ──→ /tmp/<server>-in.log
                     │
                     ▼
              MCP server process
                     │
                     ▼
              tee ──→ /tmp/<server>-out.log ──→ Cursor (stdout)
```

This lets us capture the **exact JSON-RPC messages** flowing in both directions without
modifying either Cursor or the MCP server code.

## Files

| File | Purpose |
|---|---|
| `mcp-proxy-ansible.sh` | Tee proxy for the Red Hat Ansible MCP server |
| `mcp-proxy-sysoperator.sh` | Tee proxy for the sysoperator MCP server |
| `mcp.json.original` | Backup of `.cursor/mcp.json` before proxying |

## Log Locations

All logs are written to `logs/mcp-debug/` in the repo root:

| Log | Contents |
|---|---|
| `mcp-ansible-cursor-to-server.log` | What Cursor sends **to** the Ansible MCP server |
| `mcp-ansible-server-to-cursor.log` | What the Ansible MCP server sends **back** to Cursor |
| `mcp-sysoperator-cursor-to-server.log` | What Cursor sends **to** the sysoperator MCP server |
| `mcp-sysoperator-server-to-cursor.log` | What the sysoperator MCP server sends **back** to Cursor |

Previous session logs are rotated to `*.prev` on each restart.

## What to Look For

After restarting the MCP servers (or reloading Cursor), check the logs:

```bash
cd logs/mcp-debug

# Did Cursor send an initialize request?
grep '"method":"initialize"' mcp-sysoperator-cursor-to-server.log

# Did the server respond with tools capability?
grep '"tools"' mcp-sysoperator-server-to-cursor.log

# Did Cursor ever call tools/list?
grep '"method":"tools/list"' mcp-sysoperator-cursor-to-server.log

# What tools did the server advertise?
grep '"tools/list"' mcp-sysoperator-server-to-cursor.log
```

If `tools/list` **never appears** in the `-in.log`, Cursor isn't even asking for the tool
list after the handshake. If it does appear and the response has tools, Cursor is receiving
them and discarding them.

## Restoring Direct Mode

Copy the backup back over the live config:

```bash
cp bin/debug/mcp.json.original .cursor/mcp.json
```

Then restart the MCP servers in Cursor.

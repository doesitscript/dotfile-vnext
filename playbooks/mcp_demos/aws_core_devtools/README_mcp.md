Windows Installation
For Windows users, the MCP server configuration format is slightly different:

{
  "mcpServers": {
    "awslabs.core-mcp-server": {
      "disabled": false,
      "timeout": 60,
      "type": "stdio",
      "command": "uv",
      "args": [
        "tool",
        "run",
        "--from",
        "awslabs.core-mcp-server@latest",
        "awslabs.core-mcp-server.exe"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_PROFILE": "your-aws-profile",
        "AWS_REGION": "us-east-1",
        "aws-foundation": "true",
        "solutions-architect": "true"
        // Add other roles as needed
      }
    }
  }
}

or docker after a successful docker build -t awslabs/core-mcp-server .:

  {
    "mcpServers": {
      "awslabs.core-mcp-server": {
        "command": "docker",
        "args": [
          "run",
          "--rm",
          "--interactive",
          "--env",
          "FASTMCP_LOG_LEVEL=ERROR",
          "--env",
          "aws-foundation=true",
          "--env",
          "solutions-architect=true",
          "awslabs/core-mcp-server:latest"
        ],
        "env": {},
        "disabled": false,
        "autoApprove": []
      }
    }
  }


  # other implementations: https://awslabs.github.io/mcp/servers/git-repo-research-mcp-server
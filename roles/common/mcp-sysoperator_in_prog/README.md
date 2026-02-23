the build use this image: ghcr.io/ansible/community-ansible-dev-tools:latest
zsh-autoenv
===========
1. Clone the repository
git clone https://github.com/tarnover/mcp-sysoperator.git
cd mcp-sysoperator
2. Install dependencies
npm install
3. Build the server
npm run build
4. Configure MCP settings
Add the Ansible MCP server to your MCP settings configuration file.

For VSCode with Claude extension:

Edit the file at ~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
For Claude Desktop app:

macOS: Edit ~/Library/Application Support/Claude/claude_desktop_config.json
Windows: Edit %APPDATA%\Claude\claude_desktop_config.json
Linux: Edit ~/.config/Claude/claude_desktop_config.json
Add the following to the mcpServers section:

{
  "mcpServers": {
    "sysoperator": {
      "command": "node",
      "args": ["/absolute/path/to/mcp-sysoperator/build/index.js"],
      "env": {}
    }
  }
}
Make sure to replace /absolute/path/to/mcp-sysoperator with the actual path to your installation.

Ref: https://github.com/tarnover/mcp-sysoperator
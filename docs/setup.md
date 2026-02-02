# Manual Setup

Do these steps in your project(s) folder. **Pro tip:** this can be a folder with multiple projects/repositories.

## Cursor

1. Add to `.cursor/mcp.json`:

   ```json
   {
     "mcpServers": {
       "rulekit-mcp": {
         "url": "http://localhost:3627/mcp",
         "transport": { "type": "sse" }
       }
     }
   }
   ```

2. Create `.cursor/rules/rulekit-mcp.mdc`:

   ```markdown
   ---
   alwaysApply: true
   ---

   # Rulekit MCP Server Integration

   When working with the `rulekit-mcp` MCP server, use the `get_mcp_instructions` tool to get detailed instructions on how to use this server effectively.
   ```

## VS Code / GitHub Copilot

1. Add to `.vscode/settings.json`:

   ```json
   {
     "mcp.servers": {
       "rulekit-mcp": {
         "url": "http://localhost:3627/mcp",
         "transport": { "type": "sse" }
       }
     }
   }
   ```

2. Append to `.github/copilot-instructions.md`:

   ```markdown
   ## Rulekit MCP Server Integration

   When working with the `rulekit-mcp` MCP server, use the `get_mcp_instructions` tool to get detailed instructions on how to use this server effectively.
   ```

## JetBrains

1. Add to `.idea/mcp.json`:

   ```json
   {
     "mcpServers": {
       "rulekit-mcp": {
         "url": "http://localhost:3627/mcp",
         "transport": { "type": "sse" }
       }
     }
   }
   ```

2. Create `.aiassistant/rules/rulekit-mcp.md`:

   ```markdown
   # Rulekit MCP Server Integration

   When working with the `rulekit-mcp` MCP server, use the `get_mcp_instructions` tool to get detailed instructions on how to use this server effectively.
   ```

3. In **Settings | Tools | AI Assistant | Project Rules**, set `rulekit-mcp` to **Always** mode.

## Claude Code

1. Add to `.mcp.json` (project root):

   ```json
   {
     "mcpServers": {
       "rulekit-mcp": {
         "type": "http",
         "url": "http://localhost:3627/mcp"
       }
     }
   }
   ```

2. Append to `CLAUDE.md`:

   ```markdown
   ## Rulekit MCP Server Integration

   When working with the `rulekit-mcp` MCP server, use the `get_mcp_instructions` tool to get detailed instructions on how to use this server effectively.
   ```

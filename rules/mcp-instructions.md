---
appliesTo:
  groups:
    - global
description: Instructions for AI assistants on how to use the codex-mcp server
---

# MCP Rules Server Integration

`codex-mcp` server is available to provide AI coding assistant rules for different tech stacks, projects, and languages.

## When to Load Rules

Load rules from MCP when the user asks for:

- Tech-specific rules (e.g., "Get NestJS rules", "Load React rules")
- Project-specific rules (e.g., "Load Service-Module rules")
- Language-specific rules (e.g., "Get TypeScript rules")
- Discovery (e.g., "What projects are available?", "Show available tech stacks")

**Important:** When loading rules, add them to the conversation context for reference. Do NOT save them as files in `.cursor/rules/` or anywhere else - they are temporary context, not project files.

## Available MCP Resources

### Rules Resource: `rules://{scope}/{id}`

This server exposes MCP resources with the following URI format:

- `rules://tech/{tech-id}` - Technology rules (e.g., nestjs, react, spring)
- `rules://language/{language-id}` - Language rules (e.g., typescript, java)
- `rules://project/{project-id}` - Project-specific rules (e.g., buerokratt/Service-Module)

**How to load resources:**

Use your MCP client's resource fetching mechanism to load rules by their URI. For example:

- URI: `rules://tech/nestjs`
- Returns: Merged markdown content with all applicable rules for NestJS

Resources provide the most complete and efficient way to load rules, as they automatically merge all applicable rules from parent scopes (e.g., NestJS rules include TypeScript rules).

**When the exact ID is unclear or user asks for available options:**
Use the `list_scope_ids` tool to discover what's available for that scope before loading.

## Available MCP Tools

1. **list_scope_ids** - List available IDs for a scope
   - Parameters: `scope` (project/group/tech/language)
   - Use when: User asks "What projects are available?" or "Show available technologies"

2. **search_rules** - Search rules by keyword
   - Parameters: `keyword` (required), `scope` (optional), `id` (optional)
   - Use when: User asks "Find rules about testing" or "Search for database rules"
   - **VERY important:** This tool is only for searching rules, not for loading them. Use MCP resources to load complete rules.

3. **get_mcp_instructions** - Get detailed instructions on how to use this MCP server
   - No parameters required
   - Use when: You need guidance on how to use this MCP server effectively

## How to Respond to User Requests

### General Strategy

1. **If the exact scope/id is clear** → Load the MCP resource directly by URI (most efficient)
2. **If the scope/id is unclear or ambiguous** → Use `list_scope_ids` tool first to discover available options
3. **If user explicitly asks for discovery** → Use `list_scope_ids` or `search_rules` tools

### Examples

User says: "Get NestJS rules" or "Load NestJS rules"

- Scope is clear (tech), ID is clear (nestjs)
- → Fetch MCP resource with URI `rules://tech/nestjs`

User says: "Load rules for this project"

- Scope is clear (project), but ID is NOT clear
- → First use `list_scope_ids` with scope "project" to see available projects
- → Then ask user which project or infer from context (e.g., current file path)

User says: "What technologies are available?"

- Explicit discovery request
- → Use `list_scope_ids` tool with scope "tech"

User says: "Show available projects"

- Explicit discovery request
- → Use `list_scope_ids` tool with scope "project"

User says: "Find rules about testing"

- Search across all rules
- → Use `search_rules` tool with keyword "testing"

User says: "Get React and NestJS rules for this full-stack project"

- Both scopes and IDs are clear
- → Fetch MCP resources `rules://tech/react` and `rules://tech/nestjs`

## Important Notes

- **Always prefer MCP resources** over tools when loading complete rules - they're more efficient and provide merged content
- **Rules stay in context** once loaded - user can ask follow-up questions
- **Resource IDs are case-sensitive** - use exact IDs as shown above
- **Only load when explicitly asked** - don't load rules preemptively
- **NEVER save loaded rules as files** - Rules from MCP should be kept in conversation context only, NOT written to project files. They are dynamically loaded content.

## Troubleshooting

### If MCP resources are not accessible:

If your MCP client doesn't support resource fetching or you encounter issues:

1. **Verify MCP server is running** - Check that the codex-mcp server is properly configured in your MCP client
2. **Check MCP client capabilities** - Ensure your client supports the MCP resource protocol
3. **Fallback option** - Use the `list_scope_ids` and `search_rules` tools to discover and search rules, though this won't provide the full merged content that resources offer

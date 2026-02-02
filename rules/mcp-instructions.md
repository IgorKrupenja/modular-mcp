---
appliesTo:
  groups:
    - global
description: Instructions for AI assistants on how to use the rulekit-mcp server
---

# MCP Rules Server Integration

`rulekit-mcp` server is available to provide AI coding assistant rules for different tech stacks, projects, and languages.

## When to Load Rules

Load rules from MCP when the user asks for:

- Tech-specific rules (e.g., "Get NestJS rules", "Load React rules")
- Project-specific rules (e.g., "Load Service-Module rules")
- Language-specific rules (e.g., "Get TypeScript rules")
- Discovery (e.g., "What projects are available?", "Show available tech stacks")

**Important:** When loading rules, add them to the conversation context for reference. Do NOT save them as files in `.cursor/rules/` or anywhere else - they are temporary context, not project files.

## Available MCP Resources

### Rules Resource: `rules://{scope}/{key}`

Use MCP resources to load rules directly into context. The resource URI format is:

- `rules://tech/{tech-key}` - Technology rules (e.g., nestjs, react, spring)
- `rules://language/{language-key}` - Language rules (e.g., typescript, java)
- `rules://project/{project-key}` - Project-specific rules (e.g., buerokratt/Service-Module)

**When the exact key is unclear or user asks for available options:**
Use the `list_scope_keys` tool to discover what's available for that scope before loading.

### Assets Resource: `assets://{name}`

Use MCP resources to load bundled helper assets (scripts, templates, etc) directly into context. The resource URI format is:

- `assets://{path}` - Asset content by path (e.g., `projects/buerokratt/sync-upstream.sh`)

## Available MCP Tools

1. **get_rules** - Get rules for a specific scope and key
   - Parameters: `scope` (project/group/tech/language), `key` (string)
   - Use when: You need to fetch rules via tool interface instead of resources
   - Note: Prefer using MCP resources (`rules://...`) over this tool when possible - resources are more efficient

2. **list_scope_keys** - List available keys for a scope
   - Parameters: `scope` (project/group/tech/language)
   - Use when: User asks "What projects are available?" or "Show available technologies"

3. **search_rules** - Search rules by keyword
   - Parameters: `keyword` (required), `scope` (optional), `key` (optional)
   - Use when: User asks "Find rules about testing" or "Search for database rules"
   - **VERY Important:** Use this tools for SEARCHING only. If the user requests to "load/get/etc. rules", use the `get_rules` tool instead.

4. **get_mcp_instructions** - Get detailed instructions on how to use this MCP server
   - No parameters required
   - Use when: You need guidance on how to use this MCP server effectively

5. **list_assets** - List all available asset names
   - No parameters required
   - Use when: You need to discover available assets (paths and MIME types)

6. **get_asset** - Get asset contents by name
   - Parameters: `name` (string)
   - Use when: MCP resource APIs are unavailable and you need asset content
   - Example: `name: "projects/buerokratt/sync-upstream.sh"`

## How to Respond to User Requests

### General Strategy

1. **If the exact scope/key is clear** → Load the resource directly (most efficient)
2. **If the scope/key is unclear or ambiguous** → Use `list_scope_keys` first to discover available options
3. **If user explicitly asks for discovery** → Use `list_scope_keys` or `search_rules`

### Examples

User says: "Get NestJS rules" or "Load NestJS rules"

- Scope is clear (tech), key is clear (nestjs)
- → Load resource `rules://tech/nestjs` from MCP

User says: "Load rules for this project"

- Scope is clear (project), but key is NOT clear
- → First use `list_scope_keys` with scope "project" to see available projects
- → Then ask user which project or infer from context (e.g., current file path)

User says: "What technologies are available?"

- Explicit discovery request
- → Use `list_scope_keys` tool with scope "tech"

User says: "Show available projects"

- Explicit discovery request
- → Use `list_scope_keys` tool with scope "project"

User says: "Find rules about testing"

- Search across all rules
- → Use `search_rules` tool with keyword "testing"

User says: "Get React and NestJS rules for this full-stack project"

- Both scopes and IDs are clear
- → Load resources `rules://tech/react` and `rules://tech/nestjs` from MCP

## Important Notes

- **Always prefer resource URIs** (`rules://...`) over tools when loading rules - they're more efficient
- **Rules stay in context** once loaded - user can ask follow-up questions
- **Resource keys are case-sensitive** - use exact keys as shown above
- **Only load when explicitly asked** - don't load rules preemptively
- **NEVER save loaded rules as files** - Rules from MCP should be kept in conversation context only, NOT written to `.cursor/rules/` or any other files. They are dynamically loaded content, not project files.

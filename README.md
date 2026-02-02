# Rulekit MCP

A modular MCP (Model Context Protocol) server for sharing AI coding assistant rules for different projects and tech stacks.

## Highlights

<!-- todo add highlights -->

- Lorem ipsum dolor sit amet, consectetur adipiscing elit.

## Setup

### 1. Start the server

```bash
docker compose up -d
```

### 2. Configure your editor

In your project(s) folder, run the command for your editor. **Pro tip:** this can be a folder with multiple projects/repositories.

The script adds MCP server config and a small instruction bootstrap file. It checks for existing configuration and only appends if needed.

**Cursor:**

```bash
curl -sSL https://raw.githubusercontent.com/IgorKrupenja/rulekit-mcp/main/scripts/setup.sh | bash -s -- cursor
```

**VS Code:**

```bash
curl -sSL https://raw.githubusercontent.com/IgorKrupenja/rulekit-mcp/main/scripts/setup.sh | bash -s -- vscode
```

**JetBrains:**

```bash
curl -sSL https://raw.githubusercontent.com/IgorKrupenja/rulekit-mcp/main/scripts/setup.sh | bash -s -- jetbrains
```

**Claude Code:**

```bash
curl -sSL https://raw.githubusercontent.com/IgorKrupenja/rulekit-mcp/main/scripts/setup.sh | bash -s -- claude
```

**Manual install:**

If you do not want to use the script, **you can also set up manually**. See [docs/setup.md](docs/setup.md).

## Prompting

If you followed the setup instructions above, your AI assistant will automatically use the `get_mcp_instructions` tool to learn how to interact with this MCP server. This means you can use natural language prompts like:

- "Get NestJS rules from MCP"
- "Load React rules"
- "What projects are available in MCP?"
- "Show available tech stacks"
- "Find rules about testing in MCP"
- "Load Service-Module rules"
- "Get rules for this project in MCP" (provided you have selected a file belonging to the project)

<!-- todo more examples, e.g. create nest project -->

## Editing rules

The rules are in the `rules/` folder. Rules are loaded fresh on every request, **so no server restart is needed** after you edit a rule.

### Folder Structure

```shell
rules/
├── manifest.yml
├── general.md
├── projects/
│   ├── buerokratt/
│   │   ├── general.md
│   │   ├── css.md
│   │   ├── react.md
│   │   ├── ruuter.md
│   │   ├── sql.md
│   │   ├── sql-restrictions.md
│   │   ├── sync-upstream.sh
│   │   └── Service-Module/
│   │   │   └── rules.md
│   │   │   └── ...
│   │   └── ...
│   └── ...
└── techs/
    ├── css/
    │   └── tailwind/
    │   │   └── rules.md
    │   └── ...
    ├── java/
    │   ├── rules.md
    │   └── spring/
    │   │   └── rules.md
    │   └── ...
    ├── typescript/
    │   ├── nestjs/
    │   │   └── rules.md
    │   ├── react/
    │   │   └── rules.md
    │   ├── rules.md
    │   └── ...
    └── ...
```

### Manifest

[`rules/manifest.yml`](https://github.com/IgorKrupenja/rulekit-mcp/blob/main/rules/manifest.yml#L17) defines available keys (for projects, groups, techs, and languages) and relationships between them. Keys are used for topic-based prompting, e.g. "Get NestJS rules from MCP".

`dependsOn` is used to declare dependencies between keys. E.g. if you decalre that `react` depends on `typescript`, then when you ask for "Get React rules from MCP" you will also get `typescript` rules.

The `defaults.globalGroup` entry is applied on every request unless `USE_GLOBAL_RULES` environment variable is set to `false`.

### Rule format

Rules are Markdown files with frontmatter. Use `appliesTo` in frontmatter to declare which keys the rule applies to. Keys are defined in the [manifest](#manifest).

Example:

```md
---
appliesTo:
  projects:
    - buerokratt/Service-Module
  groups:
    - buerokratt
  techs:
    - react
  languages:
    - typescript
description: Description of the rule
---

## Some rule set

... rule set content ...
```

**⚠️ Important note on context size**. To ensure the MCP server works correctly, merged projects/techs should not exceed:

- Safe < 50 KB
- Warning < 100 KB

This can be checked in CI and with an npm script, see [checks](#checks) below.

### Assets

<!-- todo write good -->

This way you can include larger code examples, helper scripts, etc. One example is the `sync-upstream.sh` script for the Bürokratt projects.

<!-- todo add link to buerokratt script example -->

## Development

### Running the project

```sh
# Install the correct Node version
nvm install
# Install the correct pnpm version
corepack enable pnpm
corepack use
pnpm install
pnpm start
```

After you are done with the code changes, rebuild the image and restart the container:

```sh
docker compose up -d --build --force-recreate
```

You can debug the rules using MCP Inspector too: `pnpm inspect`.

### Checks

#### CI

The following checks run automatically in CI on push and pull requests:

- **format**: Checks code formatting with Prettier
- **lint**: Runs ESLint to check code quality and style
- **lint-markdown**: Lints markdown files (rules and README) using markdownlint
- **typecheck**: Validates TypeScript types without emitting files
- **validate**: Validates rule files (manifest structure + rule frontmatter + rule markdown syntax)
- **check-context-size**: Checks merged projects/techs against safe token limits
- **test**: Runs tests

#### Local

These can also be run manually with npm scripts:

```sh
pnpm format
pnpm lint
pnpm lint:markdown
pnpm typecheck
pnpm validate
pnpm check-context-size
pnpm check-context-size <project-key> <tech-key>
pnpm test
```

### MCP Server Features

The MCP server provides:

- **Resources**:
  - Rules: `rules://{scope}/{key}` (e.g., `rules://project/buerokratt/Service-Module`)
  - Assets: `assets://{path}` (e.g., `assets://projects/buerokratt/sync-upstream.sh`).
- **Tools**:
  - `get_rules` - Get rules for a specific scope and key
  - `get_mcp_instructions` - Get detailed instructions on how to use this MCP server
  - `list_scope_keys` - List available keys for a scope
  - `search_rules` - Search rules by keyword

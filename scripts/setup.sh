#!/bin/bash

# MCP Setup Script for the MCP
# Usage: curl -sSL https://raw.githubusercontent.com/IgorKrupenja/rulekit-mcp/main/scripts/setup.sh | bash -s -- [editor]
# Editors: cursor, vscode, jetbrains, claude

EDITOR=${1:-all}
BASE_URL="http://localhost:3627/mcp"
INSTRUCTION_CONTENT="When working with the \`rulekit-mcp\` MCP server, use the \`get_mcp_instructions\` tool to get detailed instructions on how to use this server effectively."

echo "🚀 Setting up Rulekit MCP (Editor: $EDITOR)..."

# Helper to add MCP server to JSON config if not already present
update_json_file() {
  local file=$1
  local server_key=$2  # e.g., "mcpServers" or "mcp.servers"
  local jq_filter=$3
  local fallback_content=$4

  mkdir -p "$(dirname "$file")"

  if [ -f "$file" ]; then
    if ! command -v jq &>/dev/null; then
      echo "  ❌ Error: $file already exists but you do not have 'jq' installed."
      echo "     Please install 'jq' and run this script again."
      exit 1
    fi

    # Check if rulekit-mcp already exists
    if jq -e ".[\"$server_key\"][\"rulekit-mcp\"] // .${server_key}[\"rulekit-mcp\"]" "$file" &>/dev/null; then
      echo "  ⚠️  $file already contains rulekit-mcp. Skipping."
      return
    fi

    # Add the server
    tmp_file=$(mktemp)
    if jq "$jq_filter" "$file" >"$tmp_file" 2>/dev/null; then
      mv "$tmp_file" "$file"
      echo "  ✅ Updated $file"
    else
      rm "$tmp_file"
      echo "  ❌ Error: Failed to parse $file. Please ensure it is valid JSON."
      exit 1
    fi
  else
    echo "$fallback_content" >"$file"
    echo "  ✅ Created $file"
  fi
}

# Helper to append instruction section to a file if not already present
append_instruction_section() {
  local file=$1
  local heading=$2
  local content=$3

  mkdir -p "$(dirname "$file")"

  if [ -f "$file" ]; then
    if grep -q "^#\+ Rulekit MCP Server Integration" "$file"; then
      echo "  ⚠️  $file already contains Rulekit MCP section. Skipping."
    else
      printf "\n%s\n\n%s\n" "$heading" "$content" >>"$file"
      echo "  ✅ Appended to $file"
    fi
  else
    printf "%s\n\n%s\n" "$heading" "$content" >"$file"
    echo "  ✅ Created $file"
  fi
}

# 1. Cursor Setup
if [[ "$EDITOR" == "cursor" || "$EDITOR" == "all" ]]; then
  echo "  Configuring Cursor..."

  CURSOR_CONFIG='{
  "mcpServers": {
    "rulekit-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".cursor/mcp.json" "mcpServers" ".mcpServers[\"rulekit-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$CURSOR_CONFIG"

  # Cursor uses a dedicated file with frontmatter
  CURSOR_RULES_FILE=".cursor/rules/rulekit-mcp.mdc"
  mkdir -p .cursor/rules
  if [ -f "$CURSOR_RULES_FILE" ]; then
    if grep -q "^#\+ Rulekit MCP Server Integration" "$CURSOR_RULES_FILE"; then
      echo "  ⚠️  $CURSOR_RULES_FILE already contains Rulekit MCP section. Skipping."
    else
      printf "\n# Rulekit MCP Server Integration\n\n%s\n" "$INSTRUCTION_CONTENT" >>"$CURSOR_RULES_FILE"
      echo "  ✅ Appended to $CURSOR_RULES_FILE"
    fi
  else
    cat >"$CURSOR_RULES_FILE" <<EOF
---
alwaysApply: true
---

# Rulekit MCP Server Integration

$INSTRUCTION_CONTENT
EOF
    echo "  ✅ Created $CURSOR_RULES_FILE"
  fi
fi

# 2. VS Code / GitHub Copilot Setup
if [[ "$EDITOR" == "vscode" || "$EDITOR" == "all" ]]; then
  echo "  Configuring VS Code & GitHub Copilot..."

  VSCODE_CONFIG='{
  "mcp.servers": {
    "rulekit-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".vscode/settings.json" "mcp.servers" ".\"mcp.servers\"[\"rulekit-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$VSCODE_CONFIG"

  append_instruction_section ".github/copilot-instructions.md" "## Rulekit MCP Server Integration" "$INSTRUCTION_CONTENT"
fi

# 3. JetBrains Setup (does not support AGENTS.md)
if [[ "$EDITOR" == "jetbrains" || "$EDITOR" == "all" ]]; then
  echo "  Configuring JetBrains..."

  JETBRAINS_CONFIG='{
  "mcpServers": {
    "rulekit-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".idea/mcp.json" "mcpServers" ".mcpServers[\"rulekit-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$JETBRAINS_CONFIG"

  # JetBrains uses a dedicated file like Cursor
  JETBRAINS_RULES_FILE=".aiassistant/rules/rulekit-mcp.md"
  mkdir -p .aiassistant/rules
  if [ -f "$JETBRAINS_RULES_FILE" ]; then
    if grep -q "^#\+ Rulekit MCP Server Integration" "$JETBRAINS_RULES_FILE"; then
      echo "  ⚠️  $JETBRAINS_RULES_FILE already contains Rulekit MCP section. Skipping."
    else
      printf "\n# Rulekit MCP Server Integration\n\n%s\n" "$INSTRUCTION_CONTENT" >>"$JETBRAINS_RULES_FILE"
      echo "  ✅ Appended to $JETBRAINS_RULES_FILE"
    fi
  else
    cat >"$JETBRAINS_RULES_FILE" <<EOF
# Rulekit MCP Server Integration

$INSTRUCTION_CONTENT
EOF
    echo "  ✅ Created $JETBRAINS_RULES_FILE"
  fi
fi

# 4. Claude Code Setup (uses .mcp.json for project-level config)
if [[ "$EDITOR" == "claude" || "$EDITOR" == "all" ]]; then
  echo "  Configuring Claude Code..."

  MCP_JSON_CONFIG='{
  "mcpServers": {
    "rulekit-mcp": {
      "type": "http",
      "url": "'$BASE_URL'"
    }
  }
}'

  update_json_file ".mcp.json" "mcpServers" ".mcpServers[\"rulekit-mcp\"] = {type: \"http\", url: \"$BASE_URL\"}" "$MCP_JSON_CONFIG"

  append_instruction_section "CLAUDE.md" "## Rulekit MCP Server Integration" "$INSTRUCTION_CONTENT"
fi

echo "✅ Setup complete!"

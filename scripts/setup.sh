#!/bin/bash

# MCP Setup Script for Modular MCP
# Usage: curl -sSL https://raw.githubusercontent.com/IgorKrupenja/modular-mcp/main/scripts/setup.sh | bash -s -- [editor]
# Editors: cursor, vscode, jetbrains, claude

EDITOR=${1:-all}
BASE_URL="http://localhost:3627/mcp"
INSTRUCTION_CONTENT="When working with the \`modular-mcp\` MCP server, use the \`get_mcp_instructions\` tool to get detailed instructions on how to use this server effectively."

echo "🚀 Setting up Modular MCP (Editor: $EDITOR)..."

# Helper to merge JSON using jq if available
update_json_file() {
  local file=$1
  local jq_filter=$2
  local fallback_content=$3

  if command -v jq &>/dev/null && [ -f "$file" ]; then
    # Use jq to merge
    tmp_file=$(mktemp)
    if jq "$jq_filter" "$file" >"$tmp_file" 2>/dev/null; then
      mv "$tmp_file" "$file"
      echo "  ✅ Updated $file"
    else
      rm "$tmp_file"
      echo "  ❌ Error: Failed to parse $file. Please ensure it is valid JSON."
      rm "$tmp_file"
      exit 1
    fi
  else
    if [ -f "$file" ]; then
      echo "  ❌ Error: $file already exists but you do not have 'jq' installed."
      echo "     Please install 'jq' and run this script again."
      exit 1
    fi
    # Create new file if it doesn't exist
    mkdir -p "$(dirname "$file")"
    echo "$fallback_content" >"$file"
    echo "  ✅ Created $file"
  fi
}

# 1. Cursor Setup
if [[ "$EDITOR" == "cursor" || "$EDITOR" == "all" ]]; then
  echo "  Configuring Cursor..."

  CURSOR_CONFIG='{
  "mcpServers": {
    "modular-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".cursor/mcp.json" ".mcpServers[\"modular-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$CURSOR_CONFIG"

  mkdir -p .cursor/rules
  cat >.cursor/rules/modular-mcp.mdc <<EOF
---
alwaysApply: true
---

# MCP Rules Server Integration

$INSTRUCTION_CONTENT
EOF
fi

# 2. VS Code / GitHub Copilot Setup
if [[ "$EDITOR" == "vscode" || "$EDITOR" == "all" ]]; then
  echo "  Configuring VS Code & GitHub Copilot..."

  VSCODE_CONFIG='{
  "mcp.servers": {
    "modular-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".vscode/settings.json" ".\"mcp.servers\"[\"modular-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$VSCODE_CONFIG"

  mkdir -p .github
  cat >.github/copilot-instructions.md <<EOF
---
applyTo: "**"
---
# MCP Rules Server Integration

$INSTRUCTION_CONTENT
EOF
fi

# 3. JetBrains Setup
if [[ "$EDITOR" == "jetbrains" || "$EDITOR" == "all" ]]; then
  echo "  Configuring JetBrains..."

  JETBRAINS_CONFIG='{
  "mcpServers": {
    "modular-mcp": {
      "url": "'$BASE_URL'",
      "transport": {
        "type": "sse"
      }
    }
  }
}'

  update_json_file ".idea/mcp.json" ".mcpServers[\"modular-mcp\"] = {url: \"$BASE_URL\", transport: {type: \"sse\"}}" "$JETBRAINS_CONFIG"

  mkdir -p .aiassistant/rules
  cat >.aiassistant/rules/modular-mcp.md <<EOF
# MCP Rules Server Integration

$INSTRUCTION_CONTENT
EOF
  echo "  ⚠️  Note: In JetBrains Settings | Tools | AI Assistant | Project Rules, set 'modular-mcp' to 'Always' mode."
fi

# 4. Claude Code Setup
if [[ "$EDITOR" == "claude" || "$EDITOR" == "all" ]]; then
  echo "  Configuring Claude Code..."
  if command -v claude &>/dev/null; then
    claude mcp add --transport http modular-mcp "$BASE_URL"
    echo "  ✅ Added MCP to Claude Code."
    echo "  Run this to append system prompt: claude --append-system-prompt \"$INSTRUCTION_CONTENT\""
  else
    echo "  ⚠️  'claude' CLI not found. Skipping auto-config, but you can run:"
    echo "  claude mcp add --transport http modular-mcp $BASE_URL"
  fi
fi

echo "✅ Setup complete!"

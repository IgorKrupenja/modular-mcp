import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

import { getAvailableAssets, loadAsset } from '@/utils/assets.ts';
import { getAvailableScopeKeys } from '@/utils/manifest.ts';
import { getMergedRules, searchRulesByKeyword } from '@/utils/rules.ts';
import type { RuleScope } from '@/utils/types.ts';

export function setupTools(server: McpServer): void {
  server.registerTool(
    'get_rules',
    {
      description: 'Get rules for a specific scope and key',
      inputSchema: z.object({
        scope: z.enum(['project', 'group', 'tech', 'language']).describe('Scope type'),
        key: z.string().describe('Scope key'),
      }),
    },
    async (args) => {
      const rules = await getMergedRules({ scope: args.scope, key: args.key });
      return {
        content: [
          {
            type: 'text' as const,
            text: rules,
          },
        ],
      };
    },
  );

  // Tool: Get MCP server usage instructions
  server.registerTool(
    'get_mcp_instructions',
    {
      description: 'Get detailed instructions on how to use this MCP server effectively',
      inputSchema: z.object({}),
    },
    async () => {
      const instructionsPath = join(process.cwd(), 'rules', 'mcp-instructions.md');
      const instructions = await readFile(instructionsPath, 'utf-8');
      return {
        content: [
          {
            type: 'text' as const,
            text: instructions,
          },
        ],
      };
    },
  );

  // Tool: List available keys for a scope
  server.registerTool(
    'list_scope_keys',
    {
      description: 'List all available keys for a scope',
      inputSchema: z.object({
        scope: z.enum(['project', 'group', 'tech', 'language']).describe('Scope type'),
      }),
    },
    async (args) => {
      const keys = await getAvailableScopeKeys(args.scope as RuleScope);

      return {
        content: [
          {
            type: 'text' as const,
            text: `Available ${args.scope} keys:\n\n${keys.map((key) => `- ${key}`).join('\n')}`,
          },
        ],
      };
    },
  );

  // Tool: Search rules by keyword
  server.registerTool(
    'search_rules',
    {
      description: 'Search for rules containing a specific keyword across all scopes',
      inputSchema: z.object({
        keyword: z.string().describe('Keyword to search for'),
        scope: z
          .enum(['project', 'group', 'tech', 'language'])
          .optional()
          .describe('Optional: limit search to a scope'),
        key: z.string().optional().describe('Optional: scope key'),
      }),
    },
    async (args) => {
      if ((args.scope && !args.key) || (!args.scope && args.key)) {
        throw new Error('Both scope and key must be provided together.');
      }

      const text = await searchRulesByKeyword({
        keyword: args.keyword,
        scope: args.scope,
        key: args.key,
      });
      return {
        content: [
          {
            type: 'text' as const,
            text,
          },
        ],
      };
    },
  );

  // Tool: List available asset names
  server.registerTool(
    'list_assets',
    {
      description: 'List all available asset names',
      inputSchema: z.object({}),
    },
    async () => {
      const assets = await getAvailableAssets();
      const assetEntries = Object.entries(assets);

      return {
        content: [
          {
            type: 'text' as const,
            text: assetEntries.length
              ? `Available assets:\n\n${assetEntries
                  .map(([name, { mimeType }]) => `- ${name} (${mimeType})`)
                  .join('\n')}`
              : 'No assets available.',
          },
        ],
      };
    },
  );

  // Tool: Get asset contents by name
  server.registerTool(
    'get_asset',
    {
      description: 'Get asset contents by name',
      inputSchema: z.object({
        name: z.string().describe('Asset name, e.g. projects/buerokratt/sync-upstream.sh'),
      }),
    },
    async (args) => {
      const asset = await loadAsset(args.name);
      return {
        content: [
          {
            type: 'text' as const,
            text: asset.content,
          },
        ],
      };
    },
  );
}

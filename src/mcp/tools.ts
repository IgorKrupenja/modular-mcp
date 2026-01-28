/**
 * MCP Tool Handlers
 *
 * Handles tool-related requests (querying and searching rules)
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

import { loadAsset } from '@/utils/assets.ts';
import { getAvailableScopeIds } from '@/utils/manifest.ts';
import { getMergedRules, isRuleScope, searchRulesByKeyword } from '@/utils/rules.ts';
import type { RuleScope } from '@/utils/types.ts';

/**
 * Set up tool handlers for the MCP server
 */
export function setupTools(server: McpServer): void {
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

  // Tool: List available ids for a scope
  server.registerTool(
    'list_scope_ids',
    {
      description: 'List all available identifiers for a scope',
      inputSchema: z.object({
        scope: z.enum(['project', 'group', 'tech', 'language']).describe('Scope type'),
      }),
    },
    async (args) => {
      const ids = await getAvailableScopeIds(args.scope as RuleScope);

      return {
        content: [
          {
            type: 'text' as const,
            text: `Available ${args.scope} ids:\n\n${ids.map((id) => `- ${id}`).join('\n')}`,
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
        id: z.string().optional().describe('Optional: scope identifier'),
      }),
    },
    async (args) => {
      if ((args.scope && !args.id) || (!args.scope && args.id)) {
        throw new Error('Both scope and id must be provided together.');
      }

      const text = await searchRulesByKeyword({
        keyword: args.keyword,
        scope: args.scope,
        id: args.id,
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

  // Tool: Load a resource by URI
  server.registerTool(
    'load_resource',
    {
      description: 'Load a resource by its URI (e.g., assets://name or rules://scope/id)',
      inputSchema: z.object({
        uri: z.string().describe('Resource URI (e.g., "assets://example.md" or "rules://project/my-project")'),
      }),
    },
    async (args) => {
      const { uri } = args;

      // Parse the URI to determine resource type
      if (uri.startsWith('assets://')) {
        const name = uri.replace('assets://', '');
        if (!name) {
          throw new Error('Asset name is required');
        }
        const asset = await loadAsset(name);
        return {
          content: [
            {
              type: 'text' as const,
              text: asset.content,
            },
          ],
        };
      } else if (uri.startsWith('rules://')) {
        const path = uri.replace('rules://', '');
        const [scope, id] = path.split('/');
        if (!scope || !id) {
          throw new Error('Both scope and id are required in URI (format: rules://scope/id)');
        }
        if (!isRuleScope(scope)) {
          throw new Error(`Invalid scope: ${scope}`);
        }
        const rules = await getMergedRules({ scope, id });
        return {
          content: [
            {
              type: 'text' as const,
              text: rules,
            },
          ],
        };
      } else {
        throw new Error('Invalid URI format. Expected "assets://name" or "rules://scope/id"');
      }
    },
  );
}

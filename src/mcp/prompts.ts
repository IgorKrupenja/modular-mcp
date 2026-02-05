import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

import { getMergedRules } from '@/utils/rules.ts';

export function setupPrompts(server: McpServer): void {
  // Prompt: Get development rules as a system prompt
  server.registerPrompt(
    'development-rules',
    {
      description: 'Get development rules as a system prompt for a scope and key (works with any AI editor)',
      argsSchema: {
        scope: z.enum(['project', 'group', 'tech', 'language']).describe('Scope type'),
        key: z.string().describe('Scope key'),
      },
    },
    async (args) => {
      const rules = await getMergedRules({ scope: args.scope, key: args.key });

      return {
        messages: [
          {
            role: 'user' as const,
            content: {
              type: 'text' as const,
              text: `Here are the development rules for ${args.scope}:${args.key}:\n\n${rules}`,
            },
          },
        ],
      };
    },
  );
}

import { McpServer, ResourceTemplate } from '@modelcontextprotocol/sdk/server/mcp.js';

import { getAvailableAssets, loadAsset } from '@/utils/assets.ts';
import { getMergedRules, getRuleScopeEntries, isRuleScope } from '@/utils/rules.ts';

export function setupResources(server: McpServer): void {
  server.registerResource(
    'assets',
    new ResourceTemplate('assets://{name}', {
      list: async () => {
        const resources = await getAvailableAssets();

        return {
          resources: Object.entries(resources).map(([name, { mimeType }]) => ({
            uri: `assets://${name}`,
            name,
            description: `Bundled asset ${name}`,
            mimeType,
          })),
        };
      },
    }),
    {
      description: 'Bundled helper assets',
    },
    async (uri, variables) => {
      // MCP variables may be string or string[] depending on URI parsing.
      const name = typeof variables.name === 'string' ? variables.name : variables.name?.[0];
      if (!name) {
        throw new Error('Asset name is required');
      }

      const asset = await loadAsset(name);

      return {
        contents: [
          {
            uri: uri.toString(),
            mimeType: asset.mimeType,
            text: asset.content,
          },
        ],
      };
    },
  );

  // Register a resource template for scope-based rules
  server.registerResource(
    'rules',
    new ResourceTemplate('rules://{scope}/{key}', {
      list: async () => {
        const scopeEntries = await getRuleScopeEntries();

        return {
          resources: scopeEntries.flatMap(([scope, keys]) => {
            return keys.map((key) => ({
              uri: `rules://${scope}/${key}`,
              name: `${scope}-${key}`,
              description: `Rules for ${scope} ${key}`,
              mimeType: 'text/markdown',
            }));
          }),
        };
      },
    }),
    {
      description: 'Rules for projects, groups, techs, and languages',
      mimeType: 'text/markdown',
    },
    async (uri, variables) => {
      // MCP variables may be string or string[] depending on URI parsing.
      const scope = typeof variables.scope === 'string' ? variables.scope : variables.scope?.[0];
      const key = typeof variables.key === 'string' ? variables.key : variables.key?.[0];
      if (!scope || !key) {
        throw new Error('Scope and key are required');
      }
      if (!isRuleScope(scope)) {
        throw new Error(`Invalid scope: ${scope}`);
      }

      const rules = await getMergedRules({ scope, key });

      return {
        contents: [
          {
            uri: uri.toString(),
            mimeType: 'text/markdown',
            text: rules,
          },
        ],
      };
    },
  );
}

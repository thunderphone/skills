# ThunderPhone plugin for the Claude directory

The package the Claude plugin directory lists. Its submission's **Plugin path** is
`plugins/thunderphone-claude`, so the directory reads and scans only this folder.

## What it runs and sends

- **MCP server:** the only server is ThunderPhone's remote MCP server,
  `https://api.thunderphone.com/v1/mcp`. The first tool call opens a ThunderPhone
  sign-in, you pick the organization and scopes, and Claude stores the OAuth token.
  Tool calls go to ThunderPhone with that token and act only on that organization.
- **Skills:** instructions for using the MCP tools. They run no scripts, make no
  REST calls and never read a key or token from your machine. Anything that needs
  a secret, such as a vendor key for an import, is entered in the ThunderPhone
  dashboard, never in chat.
- **Confirmation:** test calls, real calls, texts and other billable or outward
  actions ask for your yes first.

To disconnect, open **Organization → API keys → Authorized apps** in the
ThunderPhone dashboard and revoke Claude.

## Source

The skills are copies of `plugins/thunderphone-directory/skills/`, without
`run-campaign`: Claude's MCP tool profile has no campaign tools. Edit the
directory copy, then run `scripts/agent-skills-sync-plugin-tree.sh`;
`scripts/agent-skills-check.py` fails when the two drift, when a skill here
names a tool Claude's profile hides, or when anything here handles a credential.
The REST skill pack at the repository root, which uses an API key, is not part
of this plugin.

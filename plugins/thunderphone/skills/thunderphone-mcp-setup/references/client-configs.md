# MCP client config shapes

Endpoint: `https://api.thunderphone.com/v1/mcp`

Claude Code and the root portable config use `mcpServers`, `type: http`, and
`url`. Cursor also uses `mcpServers`. VS Code uses `servers`. Codex adds the
server with `codex mcp add` and signs in with `codex mcp login`. Claude (web,
desktop, mobile) connects from the connector directory or as a custom connector.
Gemini CLI stores project MCP servers in `.gemini/settings.json`.

None of these configs carries a header: each client signs in with OAuth and
keeps the token in its own credential store.

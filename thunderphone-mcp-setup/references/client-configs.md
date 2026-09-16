# MCP client config shapes

Endpoint: `https://api.thunderphone.com/v1/mcp`

Claude Code and root portable config use `mcpServers`, `type: http`, `url`, and
`headers`. Cursor also uses `mcpServers`. VS Code uses `servers` and
`${env:THUNDERPHONE_API_KEY}`. Codex can store the bearer-token environment
variable through `codex mcp add`. Claude Desktop supports remote custom
connectors through its settings UI. Gemini CLI stores project MCP servers in
`.gemini/settings.json`.

In every client, keep the key in the environment or protected connector
credential field. Never replace a variable reference with a literal key in a
project file.

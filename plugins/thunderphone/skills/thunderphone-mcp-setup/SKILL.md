---
name: thunderphone-mcp-setup
description: Configure or troubleshoot the ThunderPhone MCP server in Claude Code, Codex, Cursor, VS Code, Claude Desktop, or Gemini CLI. Use when someone asks to add https://api.thunderphone.com/v1/mcp, set Bearer authentication, choose MCP versus REST, inspect MCP coverage, or verify a coding-agent connection.
license: MIT
compatibility: Requires an MCP client with Streamable HTTP support, network access, and THUNDERPHONE_API_KEY.
metadata:
  author: thunderphone
  version: "1.0"
---

# Configure the ThunderPhone MCP server

Use OAuth by default for directory clients (https://thunderphone.com/docs/guides/oauth); the API-key configuration below remains an alternative.

1. **Detect the client.** Check the current tool's documented project config:

| Client | Project configuration |
|---|---|
| Claude Code | `.mcp.json` with `mcpServers` |
| Codex | plugin `mcp.json`, or `codex mcp add` |
| Cursor | `.cursor/mcp.json` with `mcpServers` |
| VS Code | `.vscode/mcp.json` with `servers` |
| Claude Desktop | add a remote custom connector in **Settings → Connectors**; use the URL and authorization header below |
| Gemini CLI | `.gemini/settings.json` with `mcpServers` and an HTTP URL/header |
| Windsurf | user `~/.codeium/windsurf/mcp_config.json` with `mcpServers`, `serverUrl`, and `${env:THUNDERPHONE_API_KEY}` headers |

   Do not write several configs unless the project intentionally supports
   several clients. Preserve unrelated servers in an existing file.
2. **Set the credential.** Store the organization key as
   `THUNDERPHONE_API_KEY`. Never paste its value into a committed config. Use the
   environment-variable form supported by that client.
3. **Add the endpoint.** The Streamable HTTP server is
   `https://api.thunderphone.com/v1/mcp` with header
   `Authorization: Bearer ${THUNDERPHONE_API_KEY}`. Copy the checked-in root,
   Cursor, VS Code, or Codex config matching the client. For Claude Code:

```bash
claude mcp add --transport http --scope project --header 'Authorization: Bearer ${THUNDERPHONE_API_KEY}' thunderphone https://api.thunderphone.com/v1/mcp
```

   For Codex:

```bash
codex mcp add thunderphone --url https://api.thunderphone.com/v1/mcp --bearer-token-env-var THUNDERPHONE_API_KEY
```

4. **Restart or reload the client**, then inspect its MCP server/tool list.
   ThunderPhone MCP covers agents, numbers, calls, testing, knowledge,
   tools/webhooks, campaigns, voices, agent imports, and documentation as they
   roll out; call `tools/list` for the live catalog available to this key.
5. **Verify the transport** with a JSON-RPC initialize request when client logs
   are insufficient. A direct probe needs both required headers:

```json request POST /v1/mcp
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-03-26",
    "capabilities": {},
    "clientInfo": {
      "name": "thunderphone-skills-check",
      "version": "1.0"
    }
  }
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/mcp \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
  -H "X-ThunderPhone-Client: skills/thunderphone-mcp-setup@1.0" \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"thunderphone-skills-check","version":"1.0"}}}'
```

```python
import os, requests
payload = {"jsonrpc": "2.0", "id": 1, "method": "initialize",
           "params": {"protocolVersion": "2025-03-26", "capabilities": {},
                      "clientInfo": {"name": "thunderphone-skills-check", "version": "1.0"}}}
r = requests.post("https://api.thunderphone.com/v1/mcp", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "Accept": "application/json, text/event-stream",
             "X-ThunderPhone-Client": "skills/thunderphone-mcp-setup@1.0"}, timeout=30)
r.raise_for_status(); print(r.text)
```

```ts
const r = await fetch("https://api.thunderphone.com/v1/mcp", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", Accept: "application/json, text/event-stream",
    "X-ThunderPhone-Client": "skills/thunderphone-mcp-setup@1.0" },
  body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "initialize", params: {
    protocolVersion: "2025-03-26", capabilities: {},
    clientInfo: { name: "thunderphone-skills-check", version: "1.0" } } }) });
if (!r.ok) throw new Error(await r.text()); console.log(await r.text());
```

6. **Choose MCP or REST per task.** Prefer MCP for interactive discovery and
   agent-assisted workflows across resources. Prefer REST for deterministic CI,
   explicit payload/version control, bulk orchestration, or an operation not yet
   exposed as an MCP tool. The same safety and authorization rules apply.

## CLI setup and stdio alternative

These options complement the direct HTTP configurations above. Node 18.18+ is required.

```bash
npx -y @thunderphone/mcp setup --client cursor --api-key-env THUNDERPHONE_API_KEY
npx thunderphone mcp setup --client codex --scope user --api-key-env THUNDERPHONE_API_KEY
npx -y @thunderphone/mcp setup --client claude-desktop --scope user
```

After installing `@thunderphone/mcp` globally, the equivalent command is
`thunderphone-mcp setup`. Supported clients are `claude-code`, `codex`, `cursor`,
`vscode`, `gemini`, `claude-desktop`, and `windsurf`. Setup preserves unrelated
servers and prints the file written. It detects a single project client when
`--client` is omitted; non-interactive ambiguous detection requires that flag.
Desktop and Windsurf require `--scope user`. Desktop uses the stdio wrapper;
other clients use direct HTTP; supply `--api-key-env` for an API-key variable reference
or omit it for client-managed OAuth. Never pass the key value as an argument.

A stdio client can launch `npx -y @thunderphone/mcp` directly. Authentication is
`THUNDERPHONE_API_KEY`, then the selected CLI credential profile (automatically
refreshed), then OAuth delegated to `mcp-remote`. Set `THUNDERPHONE_PROFILE` or
run `thunderphone login --profile NAME` to use another profile. Direct HTTP
configs do not read the CLI credential store. OAuth paths require
API OAuth support; API-key authentication works independently.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Server is absent after editing | Wrong config scope/name or client was not reloaded | Use the client-specific path, preserve its expected top-level key, and reload. |
| `401` | Environment variable is unavailable to the client or key is invalid | Launch the client from the configured environment and verify the key via REST. |
| Config contains the literal wrong expansion | Client interpolation syntax differs | Use the provided config for that client; do not replace it with shell syntax blindly. |
| Expected tool is missing | Role, server rollout, or cached discovery differs | Refresh tools, confirm role and current MCP docs, then use REST if necessary. |

## Source and safety rules

- Follow the [ThunderPhone MCP guide](https://thunderphone.com/docs/guides/thunderphone-mcp-server.md) and [API introduction](https://thunderphone.com/docs/api-reference/introduction.md).
- Never commit, print, or pass the API key as a literal command argument.
- Read before mutating and ask for authority before external calls, campaigns, deletion, or other material side effects.
- MCP discovery is current evidence; do not invent a tool because a REST endpoint exists.

See [references/client-configs.md](references/client-configs.md).

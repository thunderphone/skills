---
name: thunderphone-mcp-setup
description: Configure or troubleshoot the ThunderPhone MCP server in Claude Code, Codex, Cursor, VS Code, Claude Desktop, or Gemini CLI. Use when someone asks to add https://api.thunderphone.com/v1/mcp, sign in with OAuth, choose MCP versus REST, inspect MCP coverage, or verify a coding-agent connection.
license: MIT
compatibility: Requires an MCP client with Streamable HTTP support and network access. Sign-in is OAuth in the browser.
metadata:
  author: thunderphone
  version: "1.0"
---

# Configure the ThunderPhone MCP server

The server is `https://api.thunderphone.com/v1/mcp` (Streamable HTTP). Clients
sign in with OAuth (https://thunderphone.com/docs/guides/oauth): the first tool
call opens a browser, the user approves one ThunderPhone organization and the
scopes, and the client stores the token itself. No configuration file holds a
credential, and nothing reads one from the user's machine.

1. **Detect the client.** Check the current tool's documented project config:

| Client | Project configuration |
|---|---|
| Claude Code | `.mcp.json` with `mcpServers`, or `claude mcp add` |
| Codex | plugin `mcp.json`, or `codex mcp add` then `codex mcp login thunderphone` |
| Cursor | `.cursor/mcp.json` with `mcpServers` |
| VS Code | `.vscode/mcp.json` with `servers` |
| Claude (web, desktop, mobile) | add ThunderPhone from the connector directory, or a custom connector with the URL above |
| Gemini CLI | `.gemini/settings.json` with `mcpServers` and an HTTP URL |
| Windsurf | user `~/.codeium/windsurf/mcp_config.json` with `mcpServers` and `serverUrl` |

   Do not write several configs unless the project intentionally supports
   several clients. Preserve unrelated servers in an existing file.
2. **Add the endpoint with no headers.** Copy the checked-in root, Cursor,
   VS Code, or Codex config matching the client. For Claude Code:

```bash
claude mcp add --transport http --scope project thunderphone https://api.thunderphone.com/v1/mcp
```

   For Codex:

```bash
codex mcp add thunderphone --url https://api.thunderphone.com/v1/mcp
codex mcp login thunderphone
```

3. **Sign in.** Reload the client and run any ThunderPhone tool, or the
   client's MCP sign-in command (`/mcp` in Claude Code). Approve the
   organization in the browser window that opens.
4. **Inspect the tool list.** ThunderPhone MCP covers agents, numbers, calls,
   testing, knowledge, tools/webhooks, voices, agent imports, and documentation;
   `tools/list` is the live catalog for this connection. Call
   `get_connection_identity` to confirm which organization the token reaches.
5. **Clients without OAuth.** A client that cannot sign in with OAuth can send
   an organization API key as a bearer header instead. The user creates the key
   in the dashboard (Settings → API keys) and enters it in that client's own
   secret or credential field; follow the
   [ThunderPhone MCP guide](https://thunderphone.com/docs/guides/thunderphone-mcp-server.md).
   Never write the key into a project file, a command line, or chat.
6. **Choose MCP or REST per task.** Prefer MCP for interactive discovery and
   agent-assisted workflows across resources. Prefer REST for deterministic CI,
   explicit payload/version control, bulk orchestration, or an operation not yet
   exposed as an MCP tool. The same safety and authorization rules apply.

## CLI setup and stdio alternative

These options complement the direct HTTP configurations above. Node 18.18+ is required.

```bash
npx -y @thunderphone/mcp setup --client cursor
npx -y @thunderphone/mcp setup --client claude-desktop --scope user
```

After installing `@thunderphone/mcp` globally, the equivalent command is
`thunderphone-mcp setup`. Supported clients are `claude-code`, `codex`, `cursor`,
`vscode`, `gemini`, `claude-desktop`, and `windsurf`. Setup preserves unrelated
servers and prints the file written. It detects a single project client when
`--client` is omitted; non-interactive ambiguous detection requires that flag.
Desktop and Windsurf require `--scope user`. Desktop uses the stdio wrapper,
which signs in with `thunderphone login`; other clients use direct HTTP with
client-managed OAuth.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Server is absent after editing | Wrong config scope/name or client was not reloaded | Use the client-specific path, preserve its expected top-level key, and reload. |
| `401` or a sign-in prompt on every call | The OAuth sign-in was not finished, or the organization access was revoked | Run the client's MCP sign-in again and approve the organization. |
| Tools from the wrong organization | The token was approved for another organization | Sign out of the server in the client, sign in again, and pick the right organization. |
| Expected tool is missing | Role, server rollout, or cached discovery differs | Refresh tools, confirm role and current MCP docs, then use REST if necessary. |

## Source and safety rules

- Follow the [ThunderPhone MCP guide](https://thunderphone.com/docs/guides/thunderphone-mcp-server.md) and [API introduction](https://thunderphone.com/docs/api-reference/introduction.md).
- Never ask for, print, commit, or pass a ThunderPhone API key; OAuth needs none.
- Read before mutating and ask for authority before external calls, campaigns, deletion, or other material side effects.
- MCP discovery is current evidence; do not invent a tool because a REST endpoint exists.

See [references/client-configs.md](references/client-configs.md).

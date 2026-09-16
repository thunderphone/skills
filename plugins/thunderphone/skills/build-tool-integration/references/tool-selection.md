# Tool selection

| Need | Use |
|---|---|
| One bounded HTTP operation | API connection in `/v1/integrations` |
| Several discoverable operations from one server | Remote MCP server in `/v1/mcp-servers` |
| Notify your system after a ThunderPhone event | Signed webhook endpoint |
| Per-call facts without side effects | Call variables |

Every mutating tool should document authorization, validation, idempotency,
timeout, success evidence, and rollback or safe failure behavior.

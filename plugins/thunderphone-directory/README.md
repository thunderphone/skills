# ThunderPhone directory plugin (ChatGPT / Codex)

The package submitted to the OpenAI plugin directory: the remote MCP server with OAuth (`mcp.json`) and, from
1.1.0, a skills bundle (`skills/<name>/SKILL.md`, discovered from the package root).

Build the upload with:

```bash
cd agent-skills/plugins/thunderphone-directory && zip -r ../thunderphone-directory.zip plugin.json mcp.json assets skills
```

## Skills

These skills are written for the MCP tools, not for REST, and are their own source: they are not mirrored from
the pack in `agent-skills/<name>/` (those use `THUNDERPHONE_API_KEY` and REST calls, which a ChatGPT user does
not have). `scripts/agent-skills-check.py` checks them in CI: frontmatter, no credential handling or REST calls,
and every backticked tool, argument or result name must exist in `api/orgs/mcp_tools.py` (or the handlers and
link code beside it), so renaming a tool fails the check instead of a reviewer's chat.

Rules for adding one: the user never types a password, API key or other secret into chat (send them to the
dashboard page instead), billable or outward actions say they need the user's yes, and agents are never set up to
collect payment card numbers, government ID numbers or health information.

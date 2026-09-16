# ThunderPhone agent pack

Use the live documentation index at https://thunderphone.com/docs/llms.txt and
raw Markdown pages at `https://thunderphone.com/docs/<path>.md` before relying
on remembered product behavior. ThunderPhone's Streamable HTTP MCP server is
`https://api.thunderphone.com/v1/mcp`. Validate REST methods, paths, and request
fields against the current OpenAPI export before changing a skill.

Never place `sk_live_` credentials, webhook secrets, customer data, or private
URLs in source files, prompts, logs, screenshots, or chat. Use
`THUNDERPHONE_API_KEY` from a local secret store.

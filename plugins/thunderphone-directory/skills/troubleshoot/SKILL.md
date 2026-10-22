---
name: troubleshoot
description: Find out why something in ThunderPhone is not working, from evidence: a number that does not ring through, a campaign that does not call, a webhook that does not arrive, or an agent that behaves wrongly. Use when someone reports a problem or asks for a person.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Troubleshoot

Base every claim on what a tool returns, and name the evidence.

| Problem | Start with |
|---|---|
| Calls to a number fail | `check_phone_number` with the number as dialed |
| A campaign does not call | `check_campaign` |
| A webhook did not arrive | `list_webhook_deliveries` |
| "Can it do X?" or "what is the limit?" | `get_agent_capabilities`, `get_account_limits`, `search_docs` |
| An agent says the wrong thing | `get_call_insights`, then `test_in_text` |

- Run the check again after the user changes anything.
- A setting change the user asks for goes on the draft first; deploy after a yes.
- Use `escalate_to_human` for a suspected bug, a billing question or when the user
  asks for a person. Summarize the problem without call content or caller
  details. Use `request_feature` when ThunderPhone cannot do something yet,
  after asking what the user needs it for.

Docs: https://thunderphone.com/docs/guides/issues

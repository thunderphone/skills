---
name: migrate-from-retell
description: Move Retell agents to ThunderPhone without sharing a Retell key in chat. Use when someone asks to migrate or import from Retell, review what an import mapped, or finish an import.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Migrate from Retell

1. **Start in the dashboard.** Call `start_agent_import` with platform `retell`
   and give the user its `web_url`. They enter their Retell API key there,
   never in chat. If they paste a key into the chat, do not use it, and suggest
   they rotate it.
2. **Follow the import** with `get_agent_import`. Show each Retell agent
   with its mapped name, voice, tier and warnings. The warnings name what did
   not carry over; plan those with the user.
3. **Finish after a yes** with `commit_agent_import`, choosing `item_ids` when the
   user wants only some. It runs in the background; check `get_agent_import`
   again for the new agent ids.
4. **Test before switching traffic.** Run `test_in_text` and `test_my_agent` on
   each new agent, then move numbers only when the user is happy.

Docs: https://thunderphone.com/docs/guides/import-agents

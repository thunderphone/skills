---
name: add-knowledge
description: Give a ThunderPhone agent facts to answer from: create a knowledge base, add text or a public page, attach it to the agent and confirm the agent can find the facts. Use when someone asks to add FAQs, hours, prices, policies or a website to an agent.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Add knowledge to an agent

1. **Collect the facts** the agent should answer from. Leave out secrets and
   personal data about real people.
2. **Create or reuse a knowledge base** with `list_knowledge_bases` and
   `create_knowledge_base`.
3. **Add content** with `add_knowledge_document` (text or Markdown) or
   `import_knowledge_url` (a public page the user has the right to use).
4. **Attach it** with `update_agent` `knowledge_base_ids`. The list replaces the
   current one, so read `get_agent` first and keep what is already attached.
5. **Confirm retrieval** with `search_knowledge` for two or three questions a
   caller would ask, and `test_in_text` with a caller who asks them.
6. **Deploy after a yes** with `deploy_agent`.

Docs: https://thunderphone.com/docs/guides/knowledge-base

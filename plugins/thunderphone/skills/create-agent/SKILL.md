---
name: create-agent
description: Create, configure, update, deploy, or discard a ThunderPhone voice agent. Use when someone asks to build an agent, choose Spark versus Bolt versus Storm, select a language or voice, call POST /v1/agents, or understand draft and deployed revisions.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY and an organization with access to the selected model and voice.
metadata:
  author: thunderphone
  version: "1.0"
---

# Create a ThunderPhone agent

1. **Select a tier.** Use current prices from the pricing guide, not cached
   estimates.

| Tier | `product` values | Current base rate | Choose it for |
|---|---|---:|---|
| Spark | `spark` | 2¢/minute | Structured, narrow calls where cost is the priority. |
| Bolt | `bolt` | 5¢/minute | General production calls that need stronger reasoning. |
| Storm | `storm-base`, `storm-base-with-ack`, `storm-extra`, `storm-extra-with-ack` | 9¢/minute | Complex conversations and the highest capability. |

2. **Resolve real options.** Call `GET /v1/voices` and use its returned voice ID.
   Check the supported-languages guide before choosing `language`. Do not invent
   a voice ID, locale, or product string.
3. **Write the prompt** with `thunderphone-prompt-builder`. Keep policy and facts
   general; do not script caller-response branches.
4. **Create the agent.** `name`, `prompt`, and `voice` are required. The create
   response is deployed revision 1. Valid product values are listed in
   [references/agent-fields.md](references/agent-fields.md).

```json request POST /v1/agents
{
  "name": "Dental receptionist",
  "prompt": "You are the receptionist for the dental practice. Help callers with scheduling and practice information. Use the caller's language when supported. Keep spoken responses concise.",
  "voice": "${VOICE_ID}",
  "product": "bolt",
  "primary_language": "en-US"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agents \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/create-agent@1.0" \
  --data-binary @agent.json
```

```python
import os, requests

payload = {"name": "Dental receptionist", "prompt": os.environ["AGENT_PROMPT"],
           "voice": os.environ["VOICE_ID"], "product": "bolt", "primary_language": "en-US"}
r = requests.post("https://api.thunderphone.com/v1/agents", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/create-agent@1.0"}, timeout=30)
r.raise_for_status()
agent = r.json()
print(agent["id"])
```

```ts
const response = await fetch("https://api.thunderphone.com/v1/agents", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/create-agent@1.0" },
  body: JSON.stringify({ name: "Dental receptionist", prompt: process.env.AGENT_PROMPT,
    voice: process.env.VOICE_ID, product: "bolt", primary_language: "en-US" }),
});
if (!response.ok) throw new Error(await response.text());
console.log((await response.json()).id);
```

5. **Edit deliberately.** `PATCH /v1/agents/{agent_id}` creates or updates a
   draft. Inspect it, then `POST /v1/agents/{agent_id}/deploy`. Use
   `POST /v1/agents/{agent_id}/discard-draft` to abandon unshipped changes.
6. **Verify.** Fetch `GET /v1/agents/{agent_id}` and confirm the deployed and
   draft state matches the intended revision. Then run the `test-agent` skill.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| `400` with field errors | Unsupported product, language, voice, or malformed prompt | Use `GET /v1/voices`, the language guide, and the response's field errors. |
| `403` | Organization lacks access or a policy gate applies | Check organization access; do not downgrade around a stated gate silently. |
| Draft changes do not affect calls | Draft was not deployed | Review the draft, then call the deploy endpoint. |
| Existing behavior disappeared | A full replacement omitted fields | Prefer `PATCH` for scoped edits and reread the agent before deploying. |

## Source and safety rules

- Confirm fields in the [agents API reference](https://thunderphone.com/docs/api-reference/agents.md).
- Confirm tier rates in [pricing](https://thunderphone.com/docs/guides/pricing.md).
- Use [supported languages](https://thunderphone.com/docs/guides/supported-languages.md) and the live voices endpoint.
- Never fabricate IDs, credentials, voices, prices, or successful deployment evidence.
- Treat deployment as a behavior change; test the exact deployed revision.

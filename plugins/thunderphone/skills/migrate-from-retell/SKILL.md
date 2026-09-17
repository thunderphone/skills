---
name: migrate-from-retell
description: Import and validate Retell AI agents in ThunderPhone. Use when someone asks to migrate from Retell, create a Retell agent-import job, review response-engine or flow mappings, identify manual tool and number work, commit selected items, or run parity tests before cutover.
license: MIT
compatibility: Requires a ThunderPhone organization-admin API key and authorized Retell API access or a permitted exported payload.
metadata:
  author: thunderphone
  version: "1.0"
---

# Migrate from Retell

1. **Inventory the source.** Export agents, response engines or flow states,
   numbers, tools, knowledge, webhooks, credentials, traffic, and test cases.
   Record the source revision and unresolved ownership before any import.
2. **Choose `api_key` or `paste` mode.** Use direct access only with an
   authorized source credential. Keep that credential in the protected request
   flow; never put it in logs, prompts, or committed JSON.
3. **Create the job** with `POST /v1/agent-imports`, `source: retell`, and the
   selected auth mode.

```json request POST /v1/agent-imports
{
  "source": "retell",
  "auth_mode": "paste",
  "payload": "${EXPORTED_AGENT_JSON}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agent-imports \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/migrate-from-retell@1.0" --data-binary @retell-import.json
```

```python
import json, os, requests
with open("retell-import.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/agent-imports", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/migrate-from-retell@1.0"}, timeout=60)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/agent-imports", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/migrate-from-retell@1.0" },
  body: await readFile("retell-import.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

4. **Poll and edit review items.** Use `GET /v1/agent-imports/{public_id}`, then
   `PATCH /v1/agent-imports/{public_id}/items/{item_id}` for selection, name,
   voice, product, or prompt choice.
5. **Check mapping and gaps.** General/global prompts, flow state content,
   supported tools, transfer/end/DTMF, voice, language, model, knowledge,
   voicemail, silence, keywords, and duration can map. Numbers, webhooks,
   credentials, custom engines, SMS tools, and vendor MCP settings need manual
   review. See [references/retell-mapping.md](references/retell-mapping.md).
6. **Commit reviewed items** with
   `POST /v1/agent-imports/{public_id}/commit`; poll to terminal and record the
   created IDs. Delete an abandoned uncommitted job explicitly.
7. **Run matched side-by-side tests** with `test-agent`. Verify every flow
   transition, DTMF/tool action, knowledge result, transfer, language, audio,
   and end condition. Traffic cutover and source retirement are separate,
   approval-gated work with rollback.
8. **Use live comparison data** from
   `https://thunderphone.com/data/voice-ai-price-index.json`; never invent or
   freeze a competitor rate in the skill.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Response engine is incomplete | Custom engine or flow construct is unsupported | Preserve the source and rewrite the behavior as reviewed prompt/tool logic. |
| DTMF or tool action differs | Vendor action schema did not map exactly | Rebuild and test the action with explicit inputs and success evidence. |
| Import auth fails | Retell access or auth mode is invalid | Use a correctly scoped credential or permitted paste payload. |
| Tests are not comparable | Source and destination scenarios/config differ | Freeze the case set and record both revisions and environments. |

## Source and safety rules

- Use [import agents](https://thunderphone.com/docs/guides/import-agents.md) and the [agent-import API](https://thunderphone.com/docs/api-reference/agent-imports.md).
- Protect source credentials and preserve unmodified source assets until cutover is verified.
- Do not claim feature parity from a successful commit alone.
- Keep traffic changes, number moves, and credential revocation outside the review import.

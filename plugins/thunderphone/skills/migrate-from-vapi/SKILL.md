---
name: migrate-from-vapi
description: Import and validate Vapi assistants in ThunderPhone. Use when someone asks to migrate from Vapi, create a Vapi agent-import job, choose imported items, review mapped prompts or tools, identify manual migration gaps, commit an import, or run side-by-side tests.
license: MIT
compatibility: Requires a ThunderPhone organization-admin API key and either authorized Vapi API access or a permitted exported payload.
metadata:
  author: thunderphone
  version: "1.0"
---

# Migrate from Vapi

1. **Inventory before writing.** Export the assistants, numbers, tools,
   knowledge, server URLs, credentials, squads/workflows, traffic, and test
   cases in scope. Record the source revision and owner. Do not switch traffic.
2. **Choose auth mode.** Use `api_key` when the import worker may read Vapi
   directly, or `paste` for an authorized exported payload. Put source
   credentials in the protected request flow, never in a prompt or file.
3. **Create an import job** with `POST /v1/agent-imports` using `source: vapi`
   and the chosen auth mode.

```json request POST /v1/agent-imports
{
  "source": "vapi",
  "auth_mode": "paste",
  "payload": "${EXPORTED_AGENT_JSON}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agent-imports \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/migrate-from-vapi@1.0" \
  --data-binary @vapi-import.json
```

```python
import json, os, requests
with open("vapi-import.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/agent-imports", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/migrate-from-vapi@1.0"}, timeout=60)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/agent-imports", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/migrate-from-vapi@1.0" },
  body: await readFile("vapi-import.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

4. **Poll and review.** Poll `GET /v1/agent-imports/{public_id}` until review is
   ready. Inspect every item; use
   `PATCH /v1/agent-imports/{public_id}/items/{item_id}` to select it and correct
   its name, voice, product, or prompt choice.
5. **Check mapping and gaps.** Prompt, first message, voice, language, model,
   supported tools, transfer/end behavior, knowledge, voicemail, silence, and
   duration can map. Numbers, server URLs, credentials, squads/workflows, and
   unsupported tools need an explicit manual plan. See
   [references/vapi-mapping.md](references/vapi-mapping.md).
6. **Commit only reviewed items** with
   `POST /v1/agent-imports/{public_id}/commit`. Poll the job until terminal and
   record each created ThunderPhone agent ID. Delete an unneeded job with
   `DELETE /v1/agent-imports/{public_id}` before commit.
7. **Test side by side.** Use `test-agent` with the same scenarios against the
   source and imported behavior. Compare task outcome, prompt facts, tools,
   transfers, knowledge, language, audio, and timing. Move phone traffic only
   under a separate approved cutover with rollback.
8. **Compare current pricing from data.** Use
   `https://thunderphone.com/data/voice-ai-price-index.json`; do not copy old or
   invented competitor prices into the migration plan.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Import cannot read Vapi | Source key lacks scope, is expired, or auth mode is wrong | Use authorized access through the protected flow or a permitted export. |
| Item is not selectable | Discovery or mapping failed | Read the item error and make a manual plan; do not invent mapped fields. |
| Tools behave differently | Vendor-specific schema or server behavior did not map | Rebuild a narrow ThunderPhone integration and test success/failure cases. |
| Imported call differs from source | Manual assets, deployed revision, or runtime semantics differ | Reconcile the mapping checklist and rerun matched scenarios. |

## Source and safety rules

- Follow [import agents](https://thunderphone.com/docs/guides/import-agents.md) and the [agent-import API](https://thunderphone.com/docs/api-reference/agent-imports.md).
- Never log source credentials or treat a discovered item as a committed agent.
- Do not switch phone traffic, delete source assets, or revoke credentials during import review.
- Use current source exports and current price-index data; do not invent parity.

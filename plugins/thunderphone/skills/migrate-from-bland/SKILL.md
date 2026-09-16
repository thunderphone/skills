---
name: migrate-from-bland
description: Import and validate Bland AI pathways or agents in ThunderPhone. Use when someone asks to migrate from Bland, create a Bland agent-import job, review pathway-node mappings, identify number or webhook gaps, commit selected imports, or compare source and ThunderPhone calls before cutover.
license: MIT
compatibility: Requires a ThunderPhone organization-admin API key and authorized Bland API access or a permitted exported payload.
metadata:
  author: thunderphone
  version: "1.0"
---

# Migrate from Bland

1. **Inventory the source.** Export pathways/agents, nodes, prompts, numbers,
   tools, webhooks, credentials, traffic, and test cases. Record source versions
   before changing either platform.
2. **Choose a protected import mode.** Use `api_key` only with authorized Bland
   access, or `paste` with a permitted export. Never persist source credentials
   in the import file or conversation.
3. **Create the job** at `POST /v1/agent-imports` with `source: bland`.

```json request POST /v1/agent-imports
{
  "source": "bland",
  "auth_mode": "paste",
  "payload": {}
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agent-imports \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/migrate-from-bland@1.0" --data-binary @bland-import.json
```

```python
import json, os, requests
with open("bland-import.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/agent-imports", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/migrate-from-bland@1.0"}, timeout=60)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/agent-imports", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/migrate-from-bland@1.0" },
  body: await readFile("bland-import.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

4. **Poll and review items.** Read `GET /v1/agent-imports/{public_id}` until the
   item list is ready. Select and correct items with
   `PATCH /v1/agent-imports/{public_id}/items/{item_id}`.
5. **Review mapping.** Prompt, first message, language, model, voice, supported
   tools, pathway-node content, and maximum duration can map. Owned numbers,
   webhooks, credentials, and unsupported pathway behavior need manual work.
   See [references/bland-mapping.md](references/bland-mapping.md).
6. **Commit reviewed selections** with
   `POST /v1/agent-imports/{public_id}/commit`, poll to terminal, and record all
   created agent IDs. Delete an unwanted job before commit.
7. **Test matching paths.** Use `test-agent` to traverse the same source pathway
   cases and ThunderPhone outcomes. Compare facts, branch outcomes, tools,
   transfer/end behavior, language, audio, and error recovery. Keep live number
   cutover separate and reversible.
8. **Use the current price index** at
   `https://thunderphone.com/data/voice-ai-price-index.json`; do not invent
   comparison figures.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Pathway nodes collapse incorrectly | Source graph has unsupported or ambiguous semantics | Reconstruct the intent as general prompt/tool rules and test every path. |
| Agent imports without its number | Numbers are separate manual assets | Provision/connect and verify the number in a separate cutover plan. |
| Source webhooks stop working | Vendor endpoint assumptions were copied incompletely | Rebuild signed ThunderPhone webhooks and test deliveries before cutover. |
| Commit creates only some agents | Some review items were unselected or invalid | Inspect item states and errors; do not repeat the whole import blindly. |

## Source and safety rules

- Use [import agents](https://thunderphone.com/docs/guides/import-agents.md) and [agent imports](https://thunderphone.com/docs/api-reference/agent-imports.md).
- Never expose source credentials or infer phone-number transfer from agent creation.
- Preserve source configuration and traffic until side-by-side evidence and rollback exist.
- Treat pathway conversion as behavior migration, not text copying.

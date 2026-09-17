---
name: migrate-from-elevenlabs
description: Import and validate ElevenLabs conversational agents in ThunderPhone. Use when someone asks to migrate from ElevenLabs Agents, create an ElevenLabs import job, review voice or knowledge mappings, identify client-tool or MCP gaps, commit selected items, or run side-by-side calls before cutover.
license: MIT
compatibility: Requires a ThunderPhone organization-admin API key and authorized ElevenLabs API access or a permitted exported payload.
metadata:
  author: thunderphone
  version: "1.0"
---

# Migrate from ElevenLabs

1. **Inventory the source.** Export conversational agents, prompts, first
   messages, voices, LLM settings, tools, knowledge, numbers, secrets, traffic,
   and test cases. Record the source version and content owners.
2. **Choose import mode.** Use authorized `api_key` discovery or a permitted
   `paste` payload. Keep the source credential in the protected API flow and out
   of prompts, JSON files, output, and logs.
3. **Create the job** at `POST /v1/agent-imports` with
   `source: elevenlabs`.

```json request POST /v1/agent-imports
{
  "source": "elevenlabs",
  "auth_mode": "paste",
  "payload": "${EXPORTED_AGENT_JSON}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agent-imports \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/migrate-from-elevenlabs@1.0" --data-binary @elevenlabs-import.json
```

```python
import json, os, requests
with open("elevenlabs-import.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/agent-imports", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/migrate-from-elevenlabs@1.0"}, timeout=60)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/agent-imports", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json",
    "X-ThunderPhone-Client": "skills/migrate-from-elevenlabs@1.0" },
  body: await readFile("elevenlabs-import.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

4. **Poll and review items.** Fetch `GET /v1/agent-imports/{public_id}` until
   ready; use `PATCH /v1/agent-imports/{public_id}/items/{item_id}` to select and
   correct each candidate.
5. **Review mapping.** Prompt, first message, language, LLM choice, voice,
   webhook tools, supported system tools, knowledge, silence, and maximum
   duration can map. Numbers, secret values, client-side tools, MCP servers, and
   unsupported vendor capabilities need manual work. See
   [references/elevenlabs-mapping.md](references/elevenlabs-mapping.md).
6. **Commit only reviewed items** with
   `POST /v1/agent-imports/{public_id}/commit`; poll to terminal and record each
   created ID. Discard an uncommitted job with `DELETE /v1/agent-imports/{public_id}`.
7. **Run side-by-side tests.** Use identical scenarios for source and
   ThunderPhone. Compare tool and knowledge evidence, transfer/end behavior,
   language, pronunciation, interruption, audio, and latency. Create a separate
   approved plan for numbers, traffic, and source retirement.
8. **Read current comparison data** from
   `https://thunderphone.com/data/voice-ai-price-index.json`; do not publish
   invented or stale rates.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Voice does not map | Source voice is unavailable or incompatible | Select a real voice returned by `GET /v1/voices` and evaluate it in audio. |
| Client tool disappears | Browser/client-executed tools are not server tools | Rebuild an authorized server integration or keep the client layer explicitly. |
| Knowledge answers differ | Source documents or retrieval behavior did not transfer fully | Import permitted sources, run direct search, then test spoken answers. |
| MCP capability is missing | Remote MCP servers are manual assets | Register them through `/v1/mcp-servers`, review discovered tools, and attach deliberately. |

## Source and safety rules

- Use [import agents](https://thunderphone.com/docs/guides/import-agents.md) and the [agent-import API](https://thunderphone.com/docs/api-reference/agent-imports.md).
- Never expose source secrets or assume a source voice exists in ThunderPhone.
- Keep source agents and traffic intact until matched tests and rollback are complete.
- Separate transcript similarity from audio, latency, connection, and tool evidence.

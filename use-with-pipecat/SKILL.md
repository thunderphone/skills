---
name: use-with-pipecat
description: Connect Pipecat to the ThunderPhone Realtime endpoint. Use when someone asks for pipecat-thunderphone, ThunderPhoneRealtimeLLMService, an OpenAI Realtime-compatible Pipecat service, package installation, saved agent_id configuration, or Pipecat voice-session troubleshooting.
license: MIT
compatibility: Requires Python, pipecat-ai 1.8 or newer, pipecat-thunderphone, THUNDERPHONE_API_KEY, and network/audio transports selected by the application.
metadata:
  author: thunderphone
  version: "1.0"
---

# Use ThunderPhone with Pipecat

1. **Install the documented adapter.** Use `pip install pipecat-thunderphone` in
   a clean environment. Confirm the resolved `pipecat-ai` version is 1.8 or
   newer; do not mix incompatible transport examples from older releases.
2. **Select agent mode.** Prefer a saved deployed ThunderPhone agent for shared
   prompt, voice, tools, knowledge, and testing. Use inline session config only
   when the application must own those fields.
3. **Store the credential** as `THUNDERPHONE_API_KEY`. Never embed it in client
   JavaScript, recordings, or pipeline logs.
4. **Create the service.** Import `ThunderPhoneRealtimeLLMService` from the
   installed adapter and pass the API key plus the documented saved `agent_id`
   or inline session options. Wire the service between the application's chosen
   input/output transports as shown in the Pipecat guide.
5. **Use the OpenAI Realtime protocol** at
   `wss://api.thunderphone.com/v1/realtime`. Let the adapter manage event and
   audio framing; do not combine REST call fields with realtime session fields.
6. **Inspect server-side sessions** during backend diagnosis with
   `POST /v1/realtime/sessions` only when the integration requires explicit
   session creation.

```json request POST /v1/realtime/sessions
{
  "agent_id": 12
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/realtime/sessions \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/use-with-pipecat@1.0" \
  --data-binary @realtime-session.json
```

```python
import json, os, requests
with open("realtime-session.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/realtime/sessions", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/use-with-pipecat@1.0"}, timeout=30)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/realtime/sessions", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/use-with-pipecat@1.0" },
  body: await readFile("realtime-session.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

7. **Verify end to end.** Test connection, two-way audio, interruptions, tool
   calls, language switching, teardown, and error recovery. Correlate client
   events with ThunderPhone call/session records.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Import fails | Adapter or compatible Pipecat version is missing | Install `pipecat-thunderphone` and verify the environment's dependency versions. |
| WebSocket returns unauthorized | Key is missing/invalid or auth is sent in the wrong place | Let the adapter use `THUNDERPHONE_API_KEY`; do not expose it to browser code. |
| Audio connects but behavior is stale | Saved agent draft was not deployed or wrong agent ID is used | Read the agent, deploy the intended revision, and reconnect. |
| Duplicate audio or events | Two services/transports own the same stream | Keep one audio path and one lifecycle owner per session. |

## Source and safety rules

- Follow [use with Pipecat](https://thunderphone.com/docs/guides/use-with-pipecat.md) and the [Realtime API](https://thunderphone.com/docs/api-reference/realtime.md).
- Keep the API key server-side and redact event payloads before logging.
- Do not claim latency or audio quality without a real audio run.
- Pin compatible packages for production and retest before upgrades.

See [references/pipecat-checklist.md](references/pipecat-checklist.md).

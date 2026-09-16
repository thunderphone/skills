---
name: use-with-openai-realtime
description: Point an OpenAI Realtime-compatible client at ThunderPhone. Use when someone asks for the ThunderPhone Realtime WebSocket URL, session.update events, saved agent_id versus inline config, endpoint swapping, server-side authentication, or migration from an OpenAI Realtime client.
license: MIT
compatibility: Requires an OpenAI Realtime protocol client, THUNDERPHONE_API_KEY, and a server-side WebSocket environment for production credentials.
metadata:
  author: thunderphone
  version: "1.0"
---

# Use the OpenAI Realtime protocol

1. **Keep the protocol, change the endpoint.** Connect the existing client to
   `wss://api.thunderphone.com/v1/realtime`. ThunderPhone implements the OpenAI
   Realtime event model so the integration can keep its session, audio, and
   response event flow.
2. **Authenticate server-side.** Prefer `Authorization: Bearer` during the
   WebSocket handshake. The `api_key` query parameter exists for clients that
   cannot set headers, but it is easier to leak in URLs and logs; avoid it when
   headers are available.
3. **Choose a configuration owner.** Pass `agent_id` for a saved deployed agent,
   or send supported inline fields in `session.update`. Do not split ownership
   accidentally: a saved agent should remain the authority for its prompt,
   voice, tools, and knowledge.
4. **Preserve event ordering.** Wait for session confirmation before streaming
   audio; respect response lifecycle events; close and release buffers on every
   terminal path.
5. **Use REST session creation only when needed** through
   `POST /v1/realtime/sessions`.

```json request POST /v1/realtime/sessions
{
  "agent_id": 12
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/realtime/sessions \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/use-with-openai-realtime@1.0" \
  --data-binary @realtime-session.json
```

```python
import json, os, requests
with open("realtime-session.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/realtime/sessions", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/use-with-openai-realtime@1.0"}, timeout=30)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/realtime/sessions", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json",
    "X-ThunderPhone-Client": "skills/use-with-openai-realtime@1.0" },
  body: await readFile("realtime-session.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

6. **Verify the migration.** Test connection, input audio, response audio,
   interruption/cancel, tools, language, error events, reconnect strategy, and
   clean close. Compare payloads against the current ThunderPhone Realtime
   reference rather than assuming every vendor extension is portable.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| WebSocket handshake is unauthorized | Bearer header is absent/invalid | Load `THUNDERPHONE_API_KEY` server-side and verify it through REST. |
| Key appears in proxy logs | Query-parameter authentication was used | Move auth to the handshake header and rotate an exposed key. |
| Session accepts events but behavior differs | Unsupported vendor extension or conflicting saved/inline settings | Reduce to documented events and select one configuration owner. |
| Audio continues after cancel | Client does not handle response lifecycle and buffer cleanup | Process cancel/completion events and stop playback immediately. |

## Source and safety rules

- Use the [Realtime API reference](https://thunderphone.com/docs/api-reference/realtime.md) and [agents reference](https://thunderphone.com/docs/api-reference/agents.md).
- Keep long-lived organization keys out of browsers, URLs, and client logs.
- Do not assume an extension outside the documented protocol is supported.
- A successful handshake does not prove audio, interruption, latency, or tool behavior.

See [references/realtime-migration.md](references/realtime-migration.md).

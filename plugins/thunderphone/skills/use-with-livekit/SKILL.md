---
name: use-with-livekit
description: Connect LiveKit Agents to ThunderPhone Realtime. Use when someone asks for the ThunderPhone LiveKit plugin, the current GitHub fork install, livekit-agents compatibility, an OpenAI Realtime endpoint swap, saved agent_id sessions, or LiveKit voice-agent troubleshooting.
license: MIT
compatibility: Requires Python, livekit-agents 1.8 or newer, the current ThunderPhone plugin fork, THUNDERPHONE_API_KEY, and a configured LiveKit project.
metadata:
  author: thunderphone
  version: "1.0"
---

# Use ThunderPhone with LiveKit

1. **Install the current source honestly.** The published package name is
   `livekit-plugins-thunderphone`, but the current documented install comes from
   the LiveKit Agents fork branch:

```bash
pip install "git+https://github.com/kolchinski/agents@add-thunderphone-plugin#subdirectory=livekit-plugins/livekit-plugins-thunderphone"
```

   Require `livekit-agents` 1.8 or newer and pin a reviewed commit for a
   production lockfile. Do not imply the fork is an upstream release.
2. **Keep both systems' credentials server-side.** Load LiveKit credentials and
   `THUNDERPHONE_API_KEY` from the runtime secret store.
3. **Choose saved or inline configuration.** A saved deployed agent centralizes
   prompt, voice, tools, and knowledge. Inline configuration is appropriate only
   when the LiveKit worker intentionally owns those settings.
4. **Construct the ThunderPhone plugin** following the guide, then pass it as
   the realtime model in the LiveKit agent session. The service speaks the
   OpenAI Realtime protocol at `wss://api.thunderphone.com/v1/realtime`.
5. **Diagnose server-side session creation** through
   `POST /v1/realtime/sessions` when the plugin flow requires it.

```json request POST /v1/realtime/sessions
{
  "agent_id": 12
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/realtime/sessions \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/use-with-livekit@1.0" \
  --data-binary @realtime-session.json
```

```python
import json, os, requests
with open("realtime-session.json", encoding="utf-8") as f: payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/realtime/sessions", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/use-with-livekit@1.0"}, timeout=30)
r.raise_for_status(); print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const r = await fetch("https://api.thunderphone.com/v1/realtime/sessions", { method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/use-with-livekit@1.0" },
  body: await readFile("realtime-session.json", "utf8") });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

6. **Verify end to end.** Join a controlled room and test publish/subscribe,
   two-way audio, interruption, tools, language switching, participant leave,
   worker restart, and session cleanup. Correlate both LiveKit and ThunderPhone
   identifiers without logging tokens.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Package cannot be found or lacks plugin | Upstream package has not caught up with the fork | Install the documented fork path and pin a reviewed commit. |
| Worker joins but model is unauthorized | ThunderPhone key is absent or invalid | Load the server-side environment variable and verify with a read-only API call. |
| Agent behavior is stale | Wrong saved agent or undeployed draft | Confirm agent ID and deploy the intended revision. |
| Room survives after agent failure | Lifecycle cleanup is incomplete | Close the realtime model and audio/session resources on shutdown paths. |

## Source and safety rules

- Follow [use with LiveKit](https://thunderphone.com/docs/guides/use-with-livekit.md) and the [Realtime API](https://thunderphone.com/docs/api-reference/realtime.md).
- State that the current install is a fork until the official guide changes.
- Keep all API and room tokens server-side and out of logs.
- Verify audio and lifecycle behavior in a real room before a readiness claim.

See [references/livekit-checklist.md](references/livekit-checklist.md).

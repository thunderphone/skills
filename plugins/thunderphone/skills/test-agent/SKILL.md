---
name: test-agent
description: Test, grade, debug, and improve a ThunderPhone agent in a closed loop. Use when someone asks to generate scenarios, execute test runs, call /v1/simulations, use legacy test calls, inspect transcripts or grades, fix a prompt after failures, or decide whether an agent is ready to deploy.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY and a configured agent; audio test calls may incur usage.
metadata:
  author: thunderphone
  version: "1.0"
---

# Test an agent in a closed loop

1. **Name the behaviors.** Define pass criteria for greeting, task completion,
   facts, language, tools, handoff, consent, interruptions, recovery, and call
   ending. Separate text, audio, latency, connection, and legal claims.
2. **Generate candidate scenarios** with
   `POST /v1/agents/{agent_id}/test-scenarios/generate`. Review them; add edge
   cases and remove scenarios that do not match the business.
3. **Execute the saved set** with
   `POST /v1/agents/{agent_id}/test-runs/execute`, then poll
   `GET /v1/agents/{agent_id}/test-runs/{batch_id}`.

```json request POST /v1/agents/{agent_id}/test-runs/execute
{
  "channel": "web",
  "scenario_ids": [311, 312],
  "consent_to_charge": true
}
```

```bash
curl --fail-with-body -X POST "https://api.thunderphone.com/v1/agents/$AGENT_ID/test-runs/execute" \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/test-agent@1.0" \
  --data-binary @test-run.json
```

```python
import json, os, requests

with open("test-run.json", encoding="utf-8") as f:
    payload = json.load(f)
url = f"https://api.thunderphone.com/v1/agents/{os.environ['AGENT_ID']}/test-runs/execute"
r = requests.post(url, json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/test-agent@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const body = await readFile("test-run.json", "utf8");
const response = await fetch(`https://api.thunderphone.com/v1/agents/${process.env.AGENT_ID}/test-runs/execute`, {
  method: "POST", headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/test-agent@1.0" }, body,
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

4. **Use the right execution surface.** `POST /v1/simulations` is the canonical
   simulation API. `POST /v1/test-calls` remains available for older test-call
   workflows. Use real controlled audio calls for ASR, pronunciation, pacing,
   interruption, telephony, latency, and end-of-call evidence.
5. **Read evidence, not only scores.** Inspect failed criteria, transcript turns,
   tool inputs/results, timing, call status, and audio where relevant. A text
   transcript cannot establish what was audible.
6. **Fix the smallest general rule.** Prefer deleting, clarifying, or
   generalizing a prompt principle. Do not add a caller-response script for each
   failure. Fix tool contracts or knowledge sources at their source.
7. **Rerun the same scenarios**, then add a regression case. Compare the exact
   agent revision and configuration used by both runs.

## What a good pass looks like

- Every required criterion passes on the intended deployed revision.
- No high-impact failure is hidden by an average score.
- Tools show verifiable success and safe failure behavior.
- Audio-specific claims have audio evidence; connection and latency claims have telemetry.
- The regression scenario fails before the fix and passes after it.
- A separate controlled test covers production integrations and phone routing.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Batch never reaches terminal state | Worker or dependency is delayed | Poll with backoff and inspect the batch error before rerunning. |
| Test passes but live call fails | Simulation omitted audio, carrier, or live integration behavior | Add an end-to-end controlled call and inspect live telemetry. |
| Each fix creates another exception | Prompt is accumulating scripts | Replace branches with a general principle and verified facts. |
| Results cannot be compared | Agent revision or scenario set changed silently | Record revision, scenario IDs, configuration, and batch ID. |

## Source and safety rules

- Follow [test agents](https://thunderphone.com/docs/guides/test-agents.md) and [simulate a call](https://thunderphone.com/docs/guides/simulate-a-call.md).
- Confirm API behavior in [test calls](https://thunderphone.com/docs/api-reference/test-calls.md) and [test scenarios](https://thunderphone.com/docs/api-reference/test-scenarios.md).
- Do not use real customer data or unconsented recipients in tests.
- Do not infer audio, ASR, latency, connection, tool, or legal success from synthetic text alone.

See [references/test-matrix.md](references/test-matrix.md).

---
name: run-campaign
description: Create, load, start, pause, cancel, monitor, or troubleshoot a ThunderPhone outbound campaign. Use when someone asks about campaign CRUD, contact CSV or JSON imports, calling windows, consent_to_charge, campaign actions, stats, compliance controls, or high-volume outbound calling.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY, an outbound-capable number, a deployed agent, balance, and required calling attestations.
metadata:
  author: thunderphone
  version: "1.0"
---

# Run an outbound campaign

1. **Establish the legal and operational basis.** Document audience, purpose,
   consent/lawful basis, suppression handling, caller identity, recording rules,
   time zones, and permitted calling windows. Do not infer consent from a list.
2. **Validate the agent and number.** Use a tested deployed agent and an
   outbound-capable `from_number`. Check balance and
   `GET /v1/outbound-tcpa-confirmation` before loading production contacts.
3. **Create the campaign.** `POST /v1/campaigns` requires a name, agent, source
   number, and daily start/end window. Keep the campaign paused while loading
   and reviewing contacts.

```json request POST /v1/campaigns
{
  "name": "May win-back",
  "agent": 12,
  "from_number": "${FROM_NUMBER}",
  "timezone": "America/Los_Angeles",
  "daily_window_start": "09:00",
  "daily_window_end": "17:00"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/campaigns \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/run-campaign@1.0" \
  --data-binary @campaign.json
```

```python
import json, os, requests

with open("campaign.json", encoding="utf-8") as f:
    payload = json.load(f)
r = requests.post("https://api.thunderphone.com/v1/campaigns", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/run-campaign@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
import { readFile } from "node:fs/promises";
const body = await readFile("campaign.json", "utf8");
const response = await fetch("https://api.thunderphone.com/v1/campaigns", {
  method: "POST", headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/run-campaign@1.0" }, body,
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

4. **Load contacts.** Use `POST /v1/campaigns/{campaign_id}/contacts` with CSV or
   JSON. The documented import limit is 5,000 contacts per request. Normalize
   E.164 numbers, time zones, required variables, and suppression state before
   upload. Deduplicate outside the campaign too.
5. **Review the dry state.** Read `GET /v1/campaigns/{campaign_id}` and sample
   contacts. Confirm windows, agent, number, variable mapping, counts, and stop
   conditions.
6. **Start explicitly.** Call `POST /v1/campaigns/{campaign_id}/start` with
   `consent_to_charge: true` only after an authorized operator approves the
   reviewed batch. The action endpoint also supports `pause` and `cancel`.
7. **Monitor.** Poll `GET /v1/campaigns/{campaign_id}/stats`, reconcile signed
   call events, watch balance and failure rate, and pause on unexpected behavior.
8. **Verify.** Begin with a small controlled contact set. Inspect audio,
   transcripts, outcomes, opt-outs, time-window behavior, and stats before
   increasing volume.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Campaign will not start | Missing attestation, balance, contacts, or charge consent | Read the error, resolve the named gate, and review before retrying. |
| Contacts are rejected | Invalid number, missing required column, or import too large | Normalize and validate; split imports at the documented limit. |
| Calls occur at the wrong local time | Window was applied without reliable recipient time zone | Supply verified time-zone data or hold ambiguous contacts. |
| Failure rate rises | Agent, carrier, number, or contact data is unhealthy | Pause first, inspect samples and telemetry, then fix the cause. |

## Source and safety rules

- Follow [outbound campaigns](https://thunderphone.com/docs/guides/outbound-campaigns.md), [campaign API](https://thunderphone.com/docs/api-reference/campaigns.md), and [outbound calling laws](https://thunderphone.com/docs/guides/outbound-calling-laws.md).
- Never start a campaign without explicit authority for its reviewed audience and spend.
- Honor suppression, opt-out, identity, calling-window, and recording requirements.
- Do not claim delivery or conversation success from a queued/contact count.

See [references/campaign-gates.md](references/campaign-gates.md).

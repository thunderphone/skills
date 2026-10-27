---
name: run-campaign
description: Run a consent-based ThunderPhone outbound campaign to people who agreed to be called (appointment reminders, callbacks, follow-ups) - create it, load contacts, start, pause, stop, monitor, or troubleshoot. Use when someone asks about campaign setup, contact CSV or JSON imports, calling windows, consent and compliance controls, consent_to_charge, campaign actions, or stats.
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
3. **Create the campaign.** `POST /v1/campaigns` requires a name, agent, and a
   source number (`from_number`) or a pool of them (`from_numbers`), plus a daily
   start/end window. For more than a few dozen calls a day, use a pool of local
   numbers: each contact is called from the number it was last called from, else
   one with its area code, else one in its time zone, else the least used, and
   `max_calls_per_number_per_day` (default 75) keeps each number under carrier
   spam thresholds. Contacts wait, never fail, when every number is at its limit;
   `blocked_reason` says so. New campaigns call in each contact's local time
   (`window_timezone_mode: "contact"`, by area code) and spread retries across
   days and times of day (`retry_strategy: "spread"`). `double_dial: true` redials
   once, 30-60 seconds after a ring-out, without using an attempt. Keep the
   campaign paused while loading and reviewing contacts.

```json request POST /v1/campaigns
{
  "name": "May win-back",
  "agent": 12,
  "from_numbers": ["${FROM_NUMBER}", "${SECOND_FROM_NUMBER}"],
  "max_calls_per_number_per_day": 75,
  "window_timezone_mode": "contact",
  "retry_strategy": "spread",
  "double_dial": true,
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

   Optional: text each contact a few minutes before the first call
   (text-then-call). The MCP `create_campaign` tool does not take these fields
   yet, so set them with `PATCH /v1/campaigns/{campaign_id}`. The sender must be
   an SMS-capable number on the customer's own Twilio or Telnyx account (never
   a ThunderPhone number), US local numbers need approved A2P 10DLC, and every
   contact must have consented to texts as well as calls. A blank template uses
   the default; `pre_call_sms_lead_minutes` is 1-60.

```json
{
  "pre_call_sms_enabled": true,
  "pre_call_sms_from_number": "${SMS_FROM_NUMBER}",
  "pre_call_sms_template": "Hi {{first_name}}, this is {{org_name}}. We'll call you in a few minutes from {{call_from_number}}. Reply STOP to opt out of texts.",
  "pre_call_sms_lead_minutes": 2
}
```

   Only first attempts are texted; a failed or skipped text never blocks the
   call. Read a `pre_call_sms_sender_not_ready` entry in `warnings` (contacts are
   called without a text until it clears) and each contact's `pre_call_sms`
   outcome in `GET /v1/campaigns/{campaign_id}`.
4. **Load contacts.** Use `POST /v1/campaigns/{campaign_id}/contacts` with CSV or
   JSON. Imports are capped per request; split larger lists (the API reference
   gives the current limit). Every contact must have agreed to be called. Normalize
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

## Deliverability checklist

Carriers label numbers as spam from how they call. Before a large campaign:

- Use a pool of local numbers sized so daily calls per number stay under
  `max_calls_per_number_per_day`; number health flags over 50 calls a day.
- Keep `window_timezone_mode: "contact"` and `retry_strategy: "spread"`.
- Set the agent to leave a voicemail (`voicemail_action` `prompt` or
  `message`, not `hangup`) and give each number an inbound agent so
  callbacks reach someone.
- Register caller names and Twilio numbers for spam filters on Phone
  Numbers, and turn on Text before calling (`pre_call_sms_enabled`) for
  contacts who agreed to texts.
- Watch `GET /v1/phone-numbers/health` while it runs. Retire a number that
  gets labeled; never add fresh numbers to hide it.

See [get outbound calls answered](https://thunderphone.com/docs/guides/outbound-deliverability.md).

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Campaign will not start | Missing attestation, balance, contacts, or charge consent | Read the error, resolve the named gate, and review before retrying. |
| Contacts are rejected | Invalid number, missing required column, or import too large | Normalize and validate; split imports at the documented limit. |
| Calls occur at the wrong local time | The campaign uses `window_timezone_mode: "campaign"`, or contacts lack a US/Canadian area code | Use `"contact"`; split contacts without an area code into a campaign with their timezone. |
| Running but not dialing, `blocked_reason` set | Every pool number reached its daily limit | Wait, add numbers to the pool while paused, or raise `max_calls_per_number_per_day`. |
| Failure rate rises | Agent, carrier, number, or contact data is unhealthy | Pause first, inspect samples and telemetry, then fix the cause. |

## Source and safety rules

- Follow [outbound campaigns](https://thunderphone.com/docs/guides/outbound-campaigns.md), [campaign API](https://thunderphone.com/docs/api-reference/campaigns.md), and [outbound calling laws](https://thunderphone.com/docs/guides/outbound-calling-laws.md).
- Never start a campaign without explicit authority for its reviewed audience and spend.
- Honor suppression, opt-out, identity, calling-window, and recording requirements.
- Do not claim delivery or conversation success from a queued/contact count.

See [references/campaign-gates.md](references/campaign-gates.md).

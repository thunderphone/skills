---
name: place-outbound-calls
description: Place, monitor, or troubleshoot an outbound ThunderPhone call. Use when someone asks about POST /v1/call, TCPA confirmation, insufficient balance, caller and recipient numbers, call variables, idempotency, polling status, transcripts, or when to use a campaign.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY, an outbound-capable number, a deployed agent, balance, and required consent attestations.
metadata:
  author: thunderphone
  version: "1.0"
---

# Place an outbound call

1. **Confirm authority and consent.** Identify the recipient, purpose, local
   time, applicable calling/recording rules, and the evidence supporting the
   call. Do not infer consent. Check `GET /v1/outbound-tcpa-confirmation`.
   Recording the confirmation requires an authenticated organization admin in
   the dashboard; an API key cannot self-attest around the gate.
2. **Validate resources.** The `from_number` must support outbound calls. Use a
   deployed `agent_id`, supply a complete inline `config`, or omit both to use
   the number's `outbound_agent`; omission returns `400` if none is configured.
   Optional `max_hold_seconds` overrides the hold timeout for this call. Check
   balance before a production batch.
3. **Create an idempotency key** for each intended call so a retry cannot create
   a second call. Send per-call facts in `variables`, not instructions.
4. **Place one controlled call.** `POST /v1/call` requires `from_number` and
   `to_number`; it accepts `agent_id`, `variables`, and `idempotency_key`.

```json request POST /v1/call
{
  "from_number": "${FROM_NUMBER}",
  "to_number": "${TO_NUMBER}",
  "agent_id": 12,
  "variables": {},
  "max_hold_seconds": 120,
  "idempotency_key": "${IDEMPOTENCY_KEY}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/call \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/place-outbound-calls@1.0" \
  --data "$(jq -n --arg from "$FROM_NUMBER" --arg to "$TO_NUMBER" --argjson agent "$AGENT_ID" --arg key "$IDEMPOTENCY_KEY" '{from_number:$from,to_number:$to,agent_id:$agent,idempotency_key:$key}')"
```

```python
import os, requests

payload = {"from_number": os.environ["FROM_NUMBER"], "to_number": os.environ["TO_NUMBER"],
           "agent_id": int(os.environ["AGENT_ID"]), "idempotency_key": os.environ["IDEMPOTENCY_KEY"]}
r = requests.post("https://api.thunderphone.com/v1/call", json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/place-outbound-calls@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
const response = await fetch("https://api.thunderphone.com/v1/call", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json",
    "X-ThunderPhone-Client": "skills/place-outbound-calls@1.0" },
  body: JSON.stringify({ from_number: process.env.FROM_NUMBER, to_number: process.env.TO_NUMBER,
    agent_id: Number(process.env.AGENT_ID), idempotency_key: process.env.IDEMPOTENCY_KEY }),
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

5. **Interpret acceptance correctly.** A `201` means initiation was accepted,
   not that a person answered or the conversation succeeded. A `202` can mean
   the provider outcome is not yet known. Preserve the returned call ID.
6. **Poll and inspect.** Use `GET /v1/calls/{call_id}` until terminal, then
   retrieve `GET /v1/calls/{call_id}/transcript`. Use webhooks for scale.
7. **Switch to campaigns for volume.** Use the `run-campaign` skill for contact
   imports, calling windows, pause/cancel controls, and aggregate statistics.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| `403` names TCPA confirmation | Organization gate has not been completed by an admin | Complete the reviewed dashboard attestation; do not automate around it. |
| `402` insufficient balance | Organization cannot fund the call | Top up through an authorized billing flow, then retry with the same idempotency key only if no call exists. |
| Number rejected | Number lacks outbound capability or format is invalid | Read the number record and use E.164 formatting. |
| Duplicate calls | Retry used a new or missing idempotency key | Persist one key per intended call and reconcile the first result. |

## Source and safety rules

- Follow [place outbound calls](https://thunderphone.com/docs/guides/place-outbound-calls.md), [outbound calling laws](https://thunderphone.com/docs/guides/outbound-calling-laws.md), and [recording consent laws](https://thunderphone.com/docs/guides/recording-consent-laws.md).
- Confirm fields and statuses in [outbound calls](https://thunderphone.com/docs/api-reference/outbound-calls.md) and [calls](https://thunderphone.com/docs/api-reference/calls.md).
- Never infer consent, disguise caller identity, or represent initiation as completion.
- Do not include sensitive data in variables unless the conversation requires it.

See [references/outbound-readiness.md](references/outbound-readiness.md).

---
name: handle-inbound-calls
description: Configure and verify inbound calls for a ThunderPhone agent. Use when someone asks to route a number to an agent, receive inbound calls, inject call variables, use dynamic call configuration, personalize greetings, or debug why an incoming call reaches the wrong behavior.
license: MIT
compatibility: Requires a deployed agent and an inbound-capable phone number.
metadata:
  author: thunderphone
  version: "1.0"
---

# Handle inbound calls

1. **Confirm prerequisites.** Fetch the agent with `GET /v1/agents/{agent_id}`
   and the number with `GET /v1/phone-numbers/{phone_number_id}`. The agent must
   be deployed and the number must be inbound-capable.
2. **Attach the inbound agent** with
   `PATCH /v1/phone-numbers/{phone_number_id}`. Preserve unrelated number
   settings from the read response.

```json request PATCH /v1/phone-numbers/{phone_number_id}
{
  "inbound_agent_id": "${AGENT_ID}"
}
```

```bash
curl --fail-with-body -X PATCH "https://api.thunderphone.com/v1/phone-numbers/$PHONE_NUMBER_ID" \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/handle-inbound-calls@1.0" \
  --data "$(jq -n --arg id "$AGENT_ID" '{inbound_agent_id:$id}')"
```

```python
import os, requests

url = f"https://api.thunderphone.com/v1/phone-numbers/{os.environ['PHONE_NUMBER_ID']}"
r = requests.patch(url, json={"inbound_agent_id": os.environ["AGENT_ID"]},
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/handle-inbound-calls@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
const response = await fetch(`https://api.thunderphone.com/v1/phone-numbers/${process.env.PHONE_NUMBER_ID}`, {
  method: "PATCH",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json",
    "X-ThunderPhone-Client": "skills/handle-inbound-calls@1.0" },
  body: JSON.stringify({ inbound_agent_id: process.env.AGENT_ID }),
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

3. **Choose the context mechanism.** Use stable prompt facts for universal
   behavior. Use call variables for per-call facts such as an account-safe
   display name or appointment type. Use dynamic call config only when a
   trusted service must choose behavior at call time.
4. **Constrain dynamic values.** Define expected keys, defaults, allowed size,
   and whether missing data should continue or hand off. Treat caller-controlled
   values as data, never instructions. Do not inject secrets or sensitive data
   that the agent does not need.
5. **Handle the incoming event.** If subscribed to `telephony.incoming`, verify
   its webhook signature before using its data. Do not delay the call on a slow
   optional integration.
6. **Verify.** Read the number again, call it from an external line, and confirm
   the deployed agent, greeting, variables, language behavior, tools, transfer,
   recording/consent behavior, and completion webhook.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Number rings without the expected agent | Assignment points elsewhere or the edit was not saved | Read the number and patch the correct deployed agent ID. |
| Draft prompt is ignored | Inbound calls use the deployed revision | Review and deploy the draft. |
| Variable text changes instructions | Untrusted data was interpolated into instruction space | Put values in a delimited facts section and tell the agent they are data only. |
| Calls fail when config service is slow | Dynamic configuration is on the critical path without a fallback | Add a bounded timeout and safe default or handoff. |

## Source and safety rules

- Follow [handle inbound calls](https://thunderphone.com/docs/guides/handle-inbound-calls.md), [call variables](https://thunderphone.com/docs/guides/call-variables.md), and [dynamic call config](https://thunderphone.com/docs/guides/dynamic-call-config.md).
- Verify incoming events with [webhook signatures](https://thunderphone.com/docs/guides/verify-webhook-signatures.md).
- Do not put secrets into call variables or trust caller-controlled text as instructions.
- A successful assignment response does not prove a live call path; place a test call.

See [references/inbound-checklist.md](references/inbound-checklist.md).

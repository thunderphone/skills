---
name: get-phone-number
description: Buy, import, provision, label, or attach a phone number in ThunderPhone. Use when someone asks for a ThunderPhone-managed number, bring-your-own-carrier SIP setup, VoIP connection search, inbound or outbound agent assignment, number limits, porting, or regulatory requirements.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY; carrier and jurisdiction requirements vary.
metadata:
  author: thunderphone
  version: "1.0"
---

# Get and configure a phone number

1. **Choose the source.** Use a ThunderPhone-managed number for a quick inbound
   setup. Use a VoIP connection when retaining a carrier or when outbound
   capability must come from that carrier. SIP credentials and porting remain
   carrier-specific.
2. **Check capacity.** Call `GET /v1/phone-numbers/limits` before provisioning.
   Do not assume the default organization cap applies to this account.
3. **Provision a managed number.** `POST /v1/phone-numbers` accepts an optional
   `area_code`. Managed numbers are for inbound calls.

```json request POST /v1/phone-numbers
{
  "area_code": "${AREA_CODE}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/phone-numbers \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/get-phone-number@1.0" \
  --data "$(jq -n --arg area "$AREA_CODE" '{area_code:$area}')"
```

```python
import os, requests

r = requests.post("https://api.thunderphone.com/v1/phone-numbers",
    json={"area_code": os.environ["AREA_CODE"]},
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/get-phone-number@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
const response = await fetch("https://api.thunderphone.com/v1/phone-numbers", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/get-phone-number@1.0" },
  body: JSON.stringify({ area_code: process.env.AREA_CODE }),
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

4. **Or connect a carrier.** Create `POST /v1/voip-connections`, test with
   `POST /v1/voip-connections/test`, then use the connection's
   `available-numbers`, `search-numbers`, `provision-number`, or
   `import-numbers` endpoint. Read carrier-specific instructions before
   transmitting SIP credentials.
5. **Attach agents.** Update the number with
   `PATCH /v1/phone-numbers/{phone_number_id}` using `inbound_agent_id` and,
   where the number supports it, `outbound_agent_id`.
6. **Verify.** Fetch `GET /v1/phone-numbers/{phone_number_id}`. Confirm source,
   capabilities, status, label, and agent assignments. Place a controlled test
   call in every direction the number will support.
7. **Escalate human work.** Number porting, emergency-address requirements,
   identity verification, regional registrations, and carrier contracts need a
   human owner. Do not represent a regulatory step as complete from an API
   response alone.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Limit response blocks purchase | Organization is at its number cap | Reuse or release a number, or request a reviewed limit change. |
| No inventory for area code | Managed inventory is unavailable | Try an approved alternative or connect a carrier; do not fabricate inventory. |
| Imported number cannot place calls | Carrier/SIP or outbound assignment is incomplete | Verify the VoIP connection, capability, and `outbound_agent_id`. |
| Incoming call has no agent | No deployed inbound agent is attached | Deploy the agent and patch `inbound_agent_id`. |

## Source and safety rules

- Follow [get a phone number](https://thunderphone.com/docs/guides/get-a-phone-number.md) and [bring your own numbers](https://thunderphone.com/docs/guides/bring-your-own-numbers.md).
- Confirm fields in the [phone-number](https://thunderphone.com/docs/api-reference/phone-numbers.md) and [VoIP connection](https://thunderphone.com/docs/api-reference/voip-connections.md) references.
- Never expose SIP credentials or claim unverified inbound/outbound capability.
- Keep porting and regulatory decisions with an authorized human.

See [references/number-paths.md](references/number-paths.md) for the workflow map.

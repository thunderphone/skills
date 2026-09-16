---
name: setup-api-key
description: Set up, rotate, verify, or troubleshoot a ThunderPhone API key. Use when someone asks where ThunderPhone keys live, how to configure THUNDERPHONE_API_KEY, how to authenticate a REST request, or why an API request returns 401 or 403.
license: MIT
compatibility: Requires a ThunderPhone organization and HTTPS access to api.thunderphone.com.
metadata:
  author: thunderphone
  version: "1.0"
---

# Set up a ThunderPhone API key

1. **Choose the creation path.** In the dashboard, open **Organization → Keys**.
   To automate key creation, use `POST /v1/developer/api-keys` with an existing
   organization-admin key. A key cannot bootstrap its own first credential.

```json request POST /v1/developer/api-keys
{
  "name": "production"
}
```
2. **Store the value once.** Put the `sk_live_...` value in a secret manager or
   protected environment variable named `THUNDERPHONE_API_KEY`. Never paste it
   into source, chat, shell history, screenshots, logs, or a committed `.env`.
3. **Send both standard headers.** Every request made from this pack identifies
   its source with `X-ThunderPhone-Client: skills/setup-api-key@1.0`.
4. **Verify the credential** with a read-only agents request.

```bash
curl --fail-with-body https://api.thunderphone.com/v1/agents \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "X-ThunderPhone-Client: skills/setup-api-key@1.0"
```

```python
import os, requests

r = requests.get(
    "https://api.thunderphone.com/v1/agents",
    headers={
        "Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
        "X-ThunderPhone-Client": "skills/setup-api-key@1.0",
    },
    timeout=30,
)
r.raise_for_status()
print(len(r.json()))
```

```ts
const response = await fetch("https://api.thunderphone.com/v1/agents", {
  headers: {
    Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "X-ThunderPhone-Client": "skills/setup-api-key@1.0",
  },
});
if (!response.ok) throw new Error(`${response.status}: ${await response.text()}`);
console.log((await response.json()).length);
```

5. **Rotate without downtime.** Create the replacement, update and verify every
   consumer, then delete the old key with `DELETE /v1/developer/api-keys/{key_id}`.
   Ask before revoking a key if its consumers are unknown.

## Verify

The agents request should return `200`. Confirm that logs contain the client
header but never the bearer value.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| `401` | Missing, malformed, revoked, or wrong-environment key | Read the value from the intended secret store and retain the `Bearer ` prefix. |
| `403` | Valid key lacks the required organization role or an account gate applies | Use an organization-admin key for key management; inspect the response for the named gate. |
| HTML or DNS error | Wrong host | Use `https://api.thunderphone.com`, not the dashboard host. |
| Key appears in output | Unsafe debugging | Stop, redact the output, rotate the exposed key, and remove it from persisted history. |

## Source and safety rules

- Treat the API response and [API-key guide](https://thunderphone.com/docs/guides/api-keys.md) as authoritative.
- Confirm key-management fields in the [developer API-key reference](https://thunderphone.com/docs/api-reference/developer-api-keys.md).
- Do not fabricate a key, log one, or ask a user to paste one into chat.
- Use placeholders for resource IDs and inspect each write response before the next write.

See [references/authentication.md](references/authentication.md) for the header
contract and a safe rotation checklist.

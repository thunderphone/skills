---
name: setup-webhooks
description: Create, test, verify, rotate, or troubleshoot ThunderPhone webhook endpoints. Use when someone asks for call events, incoming or complete notifications, webhook signing secrets, X-ThunderPhone-Signature verification, HMAC code in Python or TypeScript, retries, or duplicate delivery handling.
license: MIT
compatibility: Requires THUNDERPHONE_API_KEY and a public HTTPS receiver that can retain the raw request body.
metadata:
  author: thunderphone
  version: "1.0"
---

# Set up signed webhooks

1. **Choose events.** Subscribe only to required event families. Common choices
   include `telephony.incoming`, `telephony.complete`, tool and turn events,
   `web.*`, `voice.*`, `call.graded`, `issue.reported`, `test-call.completed`,
   and `alert.triggered`. Confirm exact values in the events reference.
2. **Create an HTTPS receiver.** Preserve the exact raw request bytes. Parse JSON
   only after signature verification. Return a fast success and queue slower
   work.
3. **Create the endpoint** with `POST /v1/developer/webhook-endpoints`. Capture
   the signing secret once into a secret manager; the create response does not
   make it safe to log.

```json request POST /v1/developer/webhook-endpoints
{
  "label": "Production call events",
  "url": "https://example.com/thunderphone/hook",
  "events": ["telephony.incoming", "telephony.complete"]
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/developer/webhook-endpoints \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/setup-webhooks@1.0" \
  --data-binary @webhook-endpoint.json
```

4. **Verify every delivery.** Compute HMAC-SHA256 over the raw bytes and compare
   it with `X-ThunderPhone-Signature` in constant time.

```python
import hashlib, hmac, os

def verify_thunderphone(raw_body: bytes, signature: str) -> bool:
    expected = hmac.new(os.environ["THUNDERPHONE_WEBHOOK_SECRET"].encode(),
                        raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

```ts
import { createHmac, timingSafeEqual } from "node:crypto";

export function verifyThunderPhone(rawBody: Buffer, signature: string): boolean {
  const expected = createHmac("sha256", process.env.THUNDERPHONE_WEBHOOK_SECRET!)
    .update(rawBody).digest("hex");
  const received = Buffer.from(signature, "utf8");
  const wanted = Buffer.from(expected, "utf8");
  return received.length === wanted.length && timingSafeEqual(received, wanted);
}
```

5. **Make processing idempotent.** Deduplicate with the delivery/event ID. Store
   the event before performing side effects. Accept retries without repeating
   external writes.
6. **Test the endpoint** using
   `POST /v1/developer/webhook-endpoints/{endpoint_id}/test`, then trigger one
   real controlled event.
7. **Verify.** Confirm valid events pass, a changed byte or signature fails, the
   receiver returns quickly, and retrying the same event creates one effect.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Every signature fails | JSON was parsed/reserialized before hashing or wrong secret is loaded | Hash raw bytes and confirm the endpoint-specific secret. |
| Valid request crashes timing-safe compare | Encodings or lengths differ | Decode consistently and reject unequal lengths before comparison. |
| Duplicate side effects | Delivery was treated as exactly-once | Persist a delivery key and make consumers idempotent. |
| Test passes but real events do not | Wrong event selection or environment endpoint | Read the endpoint record and trigger the exact subscribed event. |

## Source and safety rules

- Use [webhook endpoints](https://thunderphone.com/docs/webhooks/endpoints.md), [events](https://thunderphone.com/docs/webhooks/events.md), and [signature verification](https://thunderphone.com/docs/guides/verify-webhook-signatures.md).
- Never log the endpoint signing secret, authorization header, or unredacted sensitive payload.
- Reject before parsing or acting when signature verification fails.
- A test delivery proves reachability, not every production event path.

See [references/webhook-checklist.md](references/webhook-checklist.md).

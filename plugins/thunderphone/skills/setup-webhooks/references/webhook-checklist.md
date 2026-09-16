# Webhook deployment checklist

- Public HTTPS URL with the intended environment and path.
- Raw request body is available before JSON middleware mutates it.
- Endpoint-specific signing secret is in a secret manager.
- `X-ThunderPhone-Signature` is verified with HMAC-SHA256 and constant time.
- Invalid signatures return a failure before side effects.
- Delivery IDs are deduplicated durably.
- Receiver acknowledges quickly and moves slow work to a queue.
- Test delivery and one real subscribed event have been observed.

Sources: [overview](https://thunderphone.com/docs/webhooks/overview.md),
[call complete](https://thunderphone.com/docs/webhooks/call-complete.md).

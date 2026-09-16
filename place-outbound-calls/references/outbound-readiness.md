# Outbound readiness

Before `POST /v1/call`, confirm:

- a documented purpose and lawful basis for contacting this recipient;
- time-zone and calling-window compliance;
- the organization's TCPA confirmation is complete;
- the source number is outbound-capable and presents the intended identity;
- the agent revision is deployed and tested;
- balance is sufficient;
- the idempotency key is persisted before the request;
- status and signed completion events will be reconciled.

A successful initiation response is not proof of answer, consent, transcript
quality, or task completion.

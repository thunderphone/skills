# Agent creation reference

Required on `POST /v1/agents`: `name`, `prompt`, `voice`.

Supported product identifiers in the API schema:

- `spark`
- `bolt`
- `storm-base`
- `storm-base-with-ack`
- `storm-extra`
- `storm-extra-with-ack`

Creation deploys the initial revision. Later writes create a draft; explicitly
deploy or discard that draft. Resolve voice IDs through `GET /v1/voices`.

Sources: [agents](https://thunderphone.com/docs/api-reference/agents.md),
[build an agent](https://thunderphone.com/docs/guides/build-an-agent.md),
[voice library](https://thunderphone.com/docs/guides/voice-library.md).

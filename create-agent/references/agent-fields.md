# Agent creation reference

Required on `POST /v1/agents`: `name`, `prompt`, `voice`.

Product: send `bolt` for every new agent and tune it with `intelligence`
(`core`, `pro`), `audio_tier` (`lite`, `standard`, `plus`) and `endpointing`
(`faster`, `fast`, `normal`, `patient`). The older product values `spark`,
`storm-base`, `storm-base-with-ack`, `storm-extra` and `storm-extra-with-ack`
are still accepted for existing integrations.

Creation deploys the initial revision. Later writes create a draft; explicitly
deploy or discard that draft. Resolve voice IDs through `GET /v1/voices`.

Sources: [agents](https://thunderphone.com/docs/api-reference/agents.md),
[build an agent](https://thunderphone.com/docs/guides/build-an-agent.md),
[voice library](https://thunderphone.com/docs/guides/voice-library.md).

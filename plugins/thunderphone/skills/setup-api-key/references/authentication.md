# Authentication reference

- Base URL: `https://api.thunderphone.com`
- Organization API keys start with `sk_live_`.
- Authentication header: `Authorization: Bearer <key>`
- Skill telemetry header: `X-ThunderPhone-Client: skills/<skill>@<version>`
- Dashboard path: **Organization → Keys**
- API collection: `GET /v1/developer/api-keys`
- Create: `POST /v1/developer/api-keys`
- Revoke: `DELETE /v1/developer/api-keys/{key_id}`

Rotation order: create, update consumers, verify consumers, revoke. Never print
either credential during the overlap.

Sources: [API keys](https://thunderphone.com/docs/guides/api-keys.md),
[developer API-key reference](https://thunderphone.com/docs/api-reference/developer-api-keys.md).

# Number workflow map

## ThunderPhone-managed

1. `GET /v1/phone-numbers/limits`
2. `POST /v1/phone-numbers`
3. `PATCH /v1/phone-numbers/{phone_number_id}`
4. Controlled inbound test

## Carrier / SIP

1. `POST /v1/voip-connections`
2. `POST /v1/voip-connections/test`
3. Search, provision, or import through the connection-specific endpoint
4. `POST /v1/phone-numbers/{phone_number_id}/verify-voip`
5. Attach inbound and outbound agents, then test both directions

ThunderPhone-managed numbers are inbound-only. A connected-carrier number's
capabilities depend on the carrier and verified connection.

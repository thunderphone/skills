---
name: get-phone-number
description: Get a phone number for a ThunderPhone agent: buy a ThunderPhone number or bring the user's own carrier, then route it to an agent. Use when someone asks for a number, wants an agent to answer calls, or wants to use their Twilio, Telnyx or SIP numbers.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Get a phone number

## A ThunderPhone number

1. Check `get_phone_number_limits` and `get_billing_summary`.
2. Tell the user the monthly price, then `provision_phone_number` with the area
   code they want.
3. Route it with `update_phone_number` `inbound_agent_id`.

## The user's own carrier

The carrier password is entered in the ThunderPhone dashboard, never in chat.

1. Send the user to the dashboard's VoIP connections page to start a guided setup
   (`get_voip_setup_session` returns the link).
2. Follow it with `get_voip_setup_session` and answer its questions with
   `answer_voip_setup_question`. Passwords, the server address, the username,
   test-call consent and signing ThunderPhone in to the provider account are
   answered in the setup wizard only.
3. When it is connected, save it with `save_voip_setup` after the user's yes,
   then bring numbers in with `import_voip_numbers` and route them.

If calls to a number fail, run `check_phone_number` and explain what its result
shows.

Docs: https://thunderphone.com/docs/guides/get-a-phone-number

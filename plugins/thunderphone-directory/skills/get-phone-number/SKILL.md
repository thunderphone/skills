---
name: get-phone-number
description: Get a phone number for a ThunderPhone agent: buy a ThunderPhone number or bring the user's own carrier, then route it to an agent. Use when someone asks for a ThunderPhone number, wants a ThunderPhone agent to answer calls, or wants to bring their Twilio, Telnyx or SIP numbers into ThunderPhone.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.1"
---

# Get a phone number

## A ThunderPhone number

1. Check `get_phone_number_limits` and `get_billing_summary`. The free test
   credit pays the first month of one number per account while $1 of it is
   left (the user then adds funds within 7 days to keep it); otherwise the
   prepaid balance must cover the first month's price. If it doesn't, say so
   and give the `add_funds_url` from the result (it takes a card too) before anything else;
   a small top-up is enough.
2. Tell the user the monthly price and get their yes, then
   `provision_phone_number` with the area code they want. It first returns a
   preview and a `confirmation_token` and buys nothing: show the user the
   preview and send the token back only after their yes. For what calls will cost a minute, use the
   preview's `agent_prices` or the agent's `price` (`get_agent`): it says
   whether the phone line is included. Don't add a per-minute part yourself.
3. Route it with `update_phone_number` `inbound_agent_id`.

For a toll-free number ("an 800 number"): when `search_toll_free_numbers` is
listed, ThunderPhone sells them. Search with `starts_with` (888) or `contains`
(letters like FLOWERS), let the user pick one, then `provision_phone_number`
with `toll_free` true and that `number`. Before their yes, tell them what the
preview says: callers pay nothing and they pay each incoming minute at its
rate, no 911, no business name shown, no texts for now. When it isn't listed,
ThunderPhone doesn't sell them yet: a toll-free number from their own carrier
connects below.

To keep a number customers already know, the simplest way is call forwarding
from their current line to the ThunderPhone number, set up with their carrier.
New ThunderPhone numbers take calls but cannot call out until outbound calling
is approved: give the `outbound_request_url` from `list_phone_numbers` or
`get_account_limits` (see the call-a-person skill).

## The user's own carrier

The carrier password is entered in ThunderPhone itself, never in chat.

1. Send the user to the carrier setup in ThunderPhone to start a guided setup
   (`get_voip_setup_session` returns the link as `web_url`).
2. Follow it with `get_voip_setup_session`. Show the user each question the
   setup returns and pass on their answer with `answer_voip_setup_question`;
   never answer for them. Passwords, the server address, the username,
   test-call consent and signing ThunderPhone in to the provider account are
   answered in the setup wizard only.
3. When it is connected, save it with `save_voip_setup` after the user's yes,
   then bring numbers in with `import_voip_numbers` and route them.

If calls to a number fail, run `check_phone_number` and explain what its result
shows.

Docs for the user: https://thunderphone.com/docs/guides/get-a-phone-number

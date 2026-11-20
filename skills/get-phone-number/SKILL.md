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

To keep a number customers already know, the simplest way is call forwarding
from their current line to the ThunderPhone number, set up with their carrier.
New ThunderPhone numbers take calls but cannot call out until outbound calling
is approved: give the `outbound_request_url` from `list_phone_numbers` or
`get_account_limits` (see the call-a-person skill).

## A number in another country

ThunderPhone numbers outside the US need paperwork for the phone company
there: a few typed details, an address and one or two documents (such as a
recent bill or a company registration).

Where this chat has these tools:

1. "Can I get a number in X?": answer from `get_number_options_abroad`. It
   says whether ThunderPhone sells numbers there, the price, what sending an
   order takes and from which balance (`when_sent`), what an incoming minute
   adds (`incoming`), and what is asked, step by step. Say the price, those
   lines, and one sentence on what is asked.
2. Gather the typed steps in the conversation (who the number is for and its
   name, the details it lists with a `key`, the address) and save them with
   `save_number_order_details`. Pass only what the user said.
3. Give the user the `web_url` it returns (or the one from
   `start_number_order_abroad`): they add the documents in ThunderPhone, from
   a phone photo or a PDF. If they already started an order for that country,
   the link carries on with it.
4. Once nothing is left, the order is sent from ThunderPhone or with
   `send_number_order`. Its first call sends nothing and returns the price,
   what sending takes, the refund promise and the number's notices with a
   `confirmation_token`: show the user exactly that and send the token back
   only after their yes. If the price or what pays it changed, it previews
   again instead of charging.
5. `list_number_orders` says where an order is; give the `web_url` of one that
   needs the user. Never promise a date.

Documents, photos of them and ID numbers are added in ThunderPhone, not in
chat; no tool takes one. Nothing is charged before the order is sent; sending
takes the first month and setup, and all of it comes back if the phone company
turns the order down or it is cancelled before approval.
Where ThunderPhone doesn't sell numbers in the country, or this chat has none
of these tools, bring the user's own carrier (below).

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

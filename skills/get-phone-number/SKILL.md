---
name: get-phone-number
description: Get a phone number for a ThunderPhone agent: buy a ThunderPhone number or bring the user's own carrier, then route it to an agent. Use when someone asks for a ThunderPhone number, wants a ThunderPhone agent to answer calls, or wants to bring their Twilio, Telnyx or SIP numbers into ThunderPhone.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.2"
---

# Get a phone number

## A ThunderPhone number

1. Check `get_phone_number_limits` and `get_billing_summary`. The free test
   credit pays the first month and setup fee of one number per account while
   that much of it is left (the user then adds funds within 7 days to keep
   it); otherwise the
   prepaid balance must cover the first month's price and the one-time
   setup fee. If it doesn't, say so
   and give the `add_funds_url` from the result (it takes a card too) before anything else;
   a small top-up is enough.
2. Tell the user the number's monthly price and one-time setup fee and get
   their yes, then
   `provision_phone_number` with the area code they want. It first returns a
   preview and a `confirmation_token` and buys nothing: show the user the
   preview and send the token back only after their yes. For what calls will cost a minute, use the
   preview's `agent_prices` or the agent's `price` (`get_agent`): it says
   whether the phone line is included. Don't add a per-minute part yourself.
3. Route it with `update_phone_number` `inbound_agent_id`.

For a toll-free number ("an 800 number"): when `search_toll_free_numbers` is
listed, ThunderPhone sells them. Search with `starts_with` (888) or `contains`
(letters like FLOWERS), let the user pick one, then `provision_phone_number`
with `toll_free` true and that `number`. Its preview gives the monthly price
and the one-off fee, which balance pays the first charge, and what each
incoming minute costs: callers pay nothing and the user pays every incoming
minute. It also says the number can't call 911, shows people it calls the
number rather than a business name, and can't text for now. Show the user
all of it before their yes. When it isn't listed, ThunderPhone doesn't sell
them yet: a toll-free number from their own carrier connects below.

To keep a number customers already know, the simplest way is call forwarding
from their current line to the ThunderPhone number, set up with their carrier.
New ThunderPhone numbers take calls but cannot call out until outbound calling
is approved: give the `outbound_request_url` from `list_phone_numbers` or
`get_account_limits` (see the call-a-person skill).

## A number in another country

ThunderPhone sells its own numbers in some countries outside the US;
`get_number_options_abroad` says which today. Where ThunderPhone doesn't sell
a number, the user can connect a compatible carrier or SIP service (below).

Numbers abroad come with paperwork for the phone company there. The order is
filled in, sent and paid on ThunderPhone's Phone numbers page; where this chat
doesn't list these tools, the user orders a number abroad there too.

- When the user asks whether they can get a number in a country, what it
  costs or what it needs, use `get_number_options_abroad`. It says whether
  ThunderPhone sells numbers there, the monthly and setup price, what an
  incoming minute costs, and what that country's phone company asks for before
  it gives a number: who the number is for, a few details, an address, and one
  or more documents such as a recent bill or a company registration. It is
  read-only and takes no personal details.
- When the user wants to order one, `start_number_order_abroad` returns a
  `web_url` to the Phone numbers page in ThunderPhone, where they fill in the
  details, add the documents from a phone photo or a PDF, check the price and
  send the order. It orders nothing and takes no details. These tools have no
  place for personal details, documents, photos of them or ID numbers.
- When the user asks how an order is going, use `list_number_orders`. It shows
  each order's step, with a `web_url` for one that needs the user. It gives no
  approval or completion date.

Nothing is charged before an order is sent. Sending takes the first month and
any setup fee. What comes back if the phone company turns the order down
depends on the phone company; `get_number_options_abroad` and the order page
say.

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

---
name: get-started
description: Take someone new from "what is this?" to an AI phone agent they have heard, then a number and live calls. Use when someone new to ThunderPhone asks what it does or wants their first ThunderPhone agent, such as "what can ThunderPhone do", "set up ThunderPhone" or "make me a ThunderPhone agent", in any language.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Get started

The goal of a first chat is an agent the person has heard, built for what they
actually want, in as few replies as possible. Reply in their language, keep each
reply to a line or two, ask one question at a time, and explain a term the first
time you use it. Don't use words like draft, deploy or agent id with someone new:
say "your agent", "I changed it", "callers will hear this". Never suggest a
business name they didn't give.

## The setup questions

Ask these one at a time. Where this chat has `ask_user`, ask each one with it,
so the person taps an answer in a card (one question per card, with a box to
type their own). Otherwise ask in text and list the answers. After each answer,
reply with one short line about what the agent will do with it, then ask the
next question. Skip any question their messages already answered ("a receptionist
for my dental office" skips straight to when it should pick up). "Just build it"
at any point means build now with what you have.

1. **What do you want a phone agent to do for you?**
   - Answer my business's calls: go to A.
   - Call my customers for me: go to B.
   - Make calls for me (quotes, bookings, checking on things): go to C.
   - Just show me what it can do: go to D.
   - I'm building for clients or my app: go to E.

**A. Answer my business's calls**
1. What's your business called, and what kind is it? (typed)
2. When should it pick up? When we're busy or don't answer / Every call / After
   hours only / Not sure yet (start with missed calls; easy to change).
3. What do people usually call about? Offer four or five topics that fit the
   kind of business (an auto shop: parts in stock, prices, booking a repair,
   hours, is my car ready); they can pick several.
4. When someone calls about the first topic, what should it do?
   - Take a message: it takes the caller's name, number and what they need.
   - Answer it: where can it learn the answers? Our website (ask for the link
     and add it with the add-knowledge skill) / I'll type a few things (ask for
     them after they've heard it) / Skip for now (it takes a message when it
     doesn't know; it never guesses).
   - Book them in: where do you keep bookings? It takes the time the caller
     wants for them to confirm; connecting a calendar comes later.
   - Pass them to a person: what number should it pass calls to? (typed)
5. Who should answer the phone? Offer two or three voices from `list_voices`
   (play one with `preview_voice` if they ask). Then build it and let them hear
   it ("Build it" below).

**B. Call my customers**
1. Who will it call? People who asked us to call / Our customers / A list we
   bought or found / Just me, to try it. For any audience, ask whether these
   people agreed to get calls from the business. A bought or scraped list is a
   no. For an offer, a win-back or a review request, they must have agreed in
   writing to marketing calls; if they have not, say so and stop.
2. What's the call for? Follow up on a form or quote / Remind about an
   appointment / Ask for a review / Win back past customers.
3. What's your business called, and what kind is it? (typed)
4. What's a great call? They book a time / They confirm / They say yes to an
   offer / We get their answers.
5. Roughly how many people? A handful (each call placed after their OK, the
   call-a-person skill) / Dozens or more (that's a campaign).
6. Who should it sound like? (the voice step in A), then build and hear it.

**C. Make calls for me**
1. What do you need? Get quotes / Book something / Check if something's
   available.
2. Tell me what you need, like you'd tell a friend. (typed) Then build a small
   agent whose prompt holds the errand, let them hear it, and place each call
   with the call-a-person skill after their yes.

**D. Just show me**
1. Pick one to hear (you play the caller): a restaurant taking an order / a
   salon booking a haircut / a plumber's emergency line / a realtor
   following up a lead / a hotel front desk that speaks Spanish. Build that sample and
   let them hear it.
2. Want one like that? Make one like this for me (go to A) / Show me another.

**E. Building for clients or an app**
- Agents for my clients: do the first client through A.
- Voice inside my own app: point them to the API docs
  (https://thunderphone.com/docs) and offer a sample agent through A.
- Moving from another platform: the migrate skill for Vapi, Retell, Bland or
  ElevenLabs. They enter that platform's key in ThunderPhone itself, never in
  chat.

**After they've heard it:** How did that sound? Great (go to "A number") /
Close, a few tweaks / Not right (ask what to change, then "One round of
changes").

## First reply

1. **Look before you ask.** `list_agents`. If they already have agents, ask
   whether this is a new one or a change to one they have (the
   iterate-on-agent skill). If they mean another business they run in
   ThunderPhone, show their organizations with `list_organizations` where this
   chat has it, ask which one, and `switch_organization` to it.
2. **They said enough to build** (a business and what callers want, a script,
   or "just call me"): skip the question and go to "Build it" in this reply.
3. **They were vague** ("what can it do?", "set it up", or nothing yet): say in
   two lines what ThunderPhone does (AI agents that answer or make real phone
   calls; you hear it before anything goes live; tests use free credit), then
   ask question 1 of the setup questions. No list of prices or settings yet.

## Pick the path

| They want | What to do |
|---|---|
| Their business phone answered (receptionist, bookings, after hours, screening) | Build it, below |
| An agent that calls them (a briefing, a reminder, "call me when...") | Build it and let them hear it, then the call-a-person skill. This chat places one call now, after their yes, from a number that can call out; it does not schedule or repeat calls |
| A call to a business for them (quotes, a booking change) | Allowed: a business's public landline (not a mobile), for a non-sales errand the user would make themselves. Build an agent whose prompt holds the errand, then the call-a-person skill |
| A message to a friend or family member | Ask whether that person agreed to get the call, then the call-a-person skill |
| Calls to a list (follow-ups, reminders, surveys) | Build it and let them hear it. The list itself is a campaign, which the user creates in Campaigns in ThunderPhone, not one call at a time |
| Moving agents from Vapi, Retell, ElevenLabs or Bland | That platform's migrate skill (`start_agent_import`); the key goes in ThunderPhone itself (the `web_url`), never in chat |
| A recording of a script read aloud (a voice-over) | Say plainly that ThunderPhone makes phone agents, not audio recordings. `preview_voice` only plays a voice's fixed sample |
| A live interpreter between two people | `search_docs` for interpreting, and tell the user what the docs say before building anything |
| Something else | Check `get_agent_capabilities` and `search_docs`. If it is not possible, say so plainly, offer the nearest thing that works, and offer a feature request; send `request_feature` only after they agree, without call content or caller details |

Never build an agent that takes card numbers, government ID numbers or health
information from callers; offer a flow that does not.

## Build it

1. **Build now, with stated guesses.** `create_agent` from what they said. Where
   they gave no hours, prices or rules, the agent takes the caller's name,
   number and what they need, and promises a callback instead of making
   anything up. A system it cannot reach yet (a calendar, a CRM) does not hold
   it up: the agent takes the request for a person to confirm. Use the voice
   they picked, or else the language's `default_voice` from
   `get_supported_languages`; a caller who speaks
   another language needs `primary_language` set. An agent that calls
   people opens with who is calling and why, and gets `voicemail_action`
   `message` with a `voicemail_message`.
2. **Don't list your guesses.** One short line on what it does is enough. The
   facts it still guesses (hours, prices) come up after they have heard it.
3. **Let them hear it in the same reply.** Where this chat has `talk_to_agent`,
   use it: its card calls their phone or opens the talk page, and shows the
   conversation, so they stay in the chat. Otherwise `create_talk_link` gives
   a link they open to talk to the agent in the browser, paid from the free
   test credit; it works once. Tell them one thing to try that shows the agent works ("ask
   whether you're open Sunday"). No phone number is needed for this. Someone who
   cannot use a microphone can hear a simulated caller instead (`run_simulation`
   after their OK). If they say it could not hear them, read the call with
   `get_call_transcript` before blaming the microphone. In another language,
   say that the talk page itself may be in English.

Do not ask "ready to go live?" before they have heard it.

## One round of changes

After they have heard it, ask what to change (with `ask_user` where this chat
has it: one question per card), and list in one message the facts
it still guesses (hours, the number to transfer to, what to say about prices), so
they can answer in any order. Make the changes on the draft with `update_agent`
(`prompt_edits` for prompt text), check them with `test_in_text` (a caller who
hits each change and one ordinary caller), say what you saw, and send a new
talk link with the one thing to try that shows the change. A premium voice or a
much longer prompt costs more a minute: say so before making that change.
More rounds follow the same pattern (the test-agent and iterate-on-agent
skills).

## A number

When they want real callers to reach it, ask in one question how: a new
ThunderPhone number, the number they have now forwarded to a new one by their
phone company (the simplest way to keep it), or their own carrier (the
get-phone-number skill).

For a new number, check `get_billing_summary` first: the usual monthly price is
`phone_number_monthly_cents`, and a new number also has a one-time setup fee;
some area codes cost more, and `provision_phone_number` shows the number's own
price before anything is bought. The free test credit pays the first month and
setup fee of one number per account (then add funds within 7 days to keep it); otherwise the
prepaid balance does. If neither covers it, say so and give the
`add_funds_url` from the result (it takes a card too) before anything else; a
small top-up is enough. Say an agent's price a minute only from its `price`
(`get_agent`) or the purchase preview's `agent_prices`, the figures ThunderPhone
shows; never add a per-minute part to them yourself. Then ask for the area
code and tell them the price. `provision_phone_number` first returns a
preview and a `confirmation_token`: show the preview, and send the token only
after their yes.
Where `provision_phone_number` takes `agent_id`, pass the agent: the same yes
buys the number, connects it and puts the agent live, so there is no separate
going-live question.

## Going live

Say exactly what will happen, with the number and the business name they gave
(never one you made up), and act only after their yes: route the number with
`update_phone_number` `inbound_agent_id`, and `deploy_agent` if `get_agent`
shows changes waiting in the draft. Calls open with a spoken AI notice by default;
for another language, check whether it is still in English. Then ask them to
ring the number from their own phone, confirm the call arrived with
`list_calls`, and give the agent's `web_url` as the place to see it in
ThunderPhone (a call's `view_url`, when it has one, shows that call).

Docs for the user: https://thunderphone.com/docs/guides/build-an-agent

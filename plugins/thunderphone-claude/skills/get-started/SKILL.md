---
name: get-started
description: Take someone new from "what is this?" to an AI phone agent they have heard, then a number and live calls. Use right after ThunderPhone is connected or installed, and for first-time or vague asks such as "what can thunderphone do", "set up thunderphone", "help me get started", "how does this work" or "make me a phone agent", in any language.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Get started

The goal of a first chat is an agent the person has heard, built for what they
actually want, in as few replies as possible. Reply in their language, keep each
reply short, ask one question at a time, and explain a term the first time you
use it. Read the method in `thunderphone://guides/working-with-thunderphone`.

## First reply

1. **Look before you ask.** `list_agents`. If they already have agents, ask
   whether this is a new one or a change to one they have (the
   iterate-on-agent skill).
2. **They said enough to build** (a business and what callers want, a script,
   or "just call me"): skip the question and go to "Build it" in this reply.
3. **They were vague** ("what can it do?", "set it up", or nothing yet): say in
   two lines what ThunderPhone does (AI agents that answer or make real phone
   calls; you hear it in your browser before anything goes live; tests use free
   credit), then ask the one question: what should it do for you? Give three
   examples that fit what they said, such as answer my shop's phone and take
   messages, call me with a reminder, or call a business for me. No list of
   setup questions, prices or settings yet.

## Pick the path

| They want | What to do |
|---|---|
| Their business phone answered (receptionist, bookings, after hours, screening) | Build it, below |
| An agent that calls them (a briefing, a reminder, "call me when...") | Build it and let them hear it, then the call-a-person skill. Say early what works: one call now, after their yes, from a number that can call out. A call cannot be scheduled, repeated daily or held until a task finishes, and the agent has no memory of earlier calls and no web search |
| A call to a business for them (quotes, a booking change) | Allowed: a business line. Build an agent whose prompt holds the errand, then the call-a-person skill |
| A message to a friend or family member | Ask whether that person agreed to get the call, then the call-a-person skill |
| Calls to a list (follow-ups, reminders, surveys) | Build it and let them hear it. The list itself is a campaign (the run-campaign skill where campaign tools are available, otherwise the ThunderPhone dashboard), not one call at a time |
| Moving agents from Vapi, Retell, ElevenLabs or Bland | That platform's migrate skill (`start_agent_import`); the key goes in the dashboard, never in chat |
| A recording of a script read aloud (a voice-over) | Not a phone agent: the dashboard's Voices page makes the audio. `preview_voice` only plays a short sample |
| A live interpreter between two people | `search_docs` for interpreting first, and build only if that does not fit |
| Something else | Check `get_agent_capabilities` and `search_docs`. If it is not possible, say so plainly, offer the nearest thing that works, and `request_feature` after asking what they need it for |

Never build an agent that takes card numbers, government ID numbers or health
information from callers; offer a flow that does not.

## Build it

1. **Build now, with stated guesses.** `create_agent` from what they said. Where
   they gave no hours, prices or rules, the agent takes the caller's name,
   number and what they need, and promises a callback instead of making
   anything up. A system it cannot reach yet (a calendar, a CRM) does not hold
   it up: the agent takes the request for a person to confirm. Pick a standard
   voice that fits (`list_voices`); a caller who speaks another language needs
   `primary_language` set (`get_supported_languages`). An agent that calls
   people opens with who is calling and why, and gets `voicemail_action`
   `message` with a `voicemail_message`.
2. **Say what you assumed** in two to four short lines (for example: it takes
   messages, does not quote prices, assumes Central time). Those lines are
   where they correct you.
3. **Let them hear it in the same reply.** `create_talk_link` gives a link they
   open to talk to the agent in the browser, paid from the free test credit; it
   works once. Tell them one thing to try that shows the agent works ("ask
   whether you're open Sunday"). No phone number is needed for this. Someone who
   cannot use a microphone can hear a simulated caller instead (`run_simulation`
   after their OK). If they say it could not hear them, read the call with
   `get_call_transcript` before blaming the microphone. In another language,
   say that the talk page itself may be in English.

Do not ask "ready to go live?" before they have heard it.

## One round of changes

After they have heard it, ask what to change, and list in one message the facts
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

For a new number, check `get_billing_summary` first: the monthly price is
`phone_number_monthly_cents`, and the number is paid from the prepaid balance,
not the free test credit. If the balance does not cover it, say so and give the
billing link before anything else; a small top-up is enough. Then ask for the
area code, tell them the price, and buy with `provision_phone_number` only after
their yes: buying charges at once.

## Going live

Say exactly what will happen ("calls to (512) 555-0142 will reach the Happy Paws
agent") and act only after their yes: route the number with
`update_phone_number` `inbound_agent_id`, and `deploy_agent` if `get_agent`
shows changes waiting in the draft. Every call opens with a spoken AI notice;
for another language, check whether it is still in English. Then ask them to
ring the number from their own phone, confirm the call arrived with
`list_calls`, and give the agent's `web_url` as the place to see it in the
dashboard.

Docs: https://thunderphone.com/docs/guides/build-an-agent

---
name: create-agent
description: Build a ThunderPhone AI phone agent from a plain-language brief and leave it as a draft that is ready to test. Use when someone asks to create a receptionist, booking, intake, support or outbound agent, pick a voice or language, or set up how the agent handles transfers, voicemail and silence.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.1"
---

# Create an agent

1. **Build first, ask after.** With a business type and a name you can build a
   testable draft: do it, say what you assumed, and ask the rest afterwards.
   Ask up front only for what a first call gets wrong without it, usually the
   city (for the time zone and hours). Ask one question at a time.
2. **Check what is possible.** Use `get_agent_capabilities` and
   `get_supported_languages` instead of guessing, and look at the account with
   tools, not from memory of an earlier chat. Use the language's
   `default_voice` when the result has one; call `list_voices` only when the
   user asks about voices, and `preview_voice` when they want to hear one.
3. **Say what a choice costs.** Some voices and longer prompts raise the price a
   minute (`get_billing_summary` has the prices). Tell the user before you
   switch to a voice that costs more, not when the deploy fails.
4. **Write the prompt** for the ear: short sentences, one question at a time,
   no lists read aloud, and never a made-up fact (it takes a message instead).
   The first line greets with the business name; it never opens with what it
   can't do. `review_prompt` checks a prompt against ThunderPhone's style rules.
   Put behavior that a setting controls in the setting, not in prompt text:
   `endpointing`, `tool_start_line`, `silence_checkins_enabled`,
   `language_switching`, `voicemail_action`, `transfer_destinations`. An agent
   that will call people needs an opening that says who is calling and why, and
   `voicemail_action` `message` with a `voicemail_message` that does the same:
   without it the agent makes up a voicemail from an inbound script ("returning
   your call").
5. **Create it** with `create_agent`. A new agent has no phone number, so it
   takes no calls. Do not call `deploy_agent` until the user has heard or seen a
   test, and never ask "ready to go live?" before that.
6. **Let them hear it.** Offer to let the user talk to the agent right away.
   Where this chat has `talk_to_agent`, use it: its card calls their phone or
   opens the talk page and shows the conversation. Otherwise
   `create_talk_link` gives a link they open in a browser to talk to it, paid
   from the free test credit. The link works once. If the user says the agent
   could not hear them, read the call with `get_call_transcript` before
   suggesting a microphone problem: the page can warn about the microphone
   while the agent heard every word. If they would rather hear a scripted
   caller, with their OK call `run_simulation` with a `scenario_prompt` for a
   typical caller (made-up name and details, never real personal or health
   information) and `consent_to_charge` set to true, poll `get_simulation`
   until it is completed, then give them its `view_url` when the result has
   one, otherwise its recording link to play soon (it expires), and a line on
   how the call went. Mention the `web_url` from the result as the place to see
   and edit the agent in ThunderPhone, then offer the next step: more tests (the
   test-agent skill).
7. **Callers who speak another language** hear the agent in that language, but
   check what the opening AI notice and any recording notice say, and tell the
   user if they are still in English.

## Never

- Never set up an agent that collects payment card numbers, government ID
  numbers or health information from callers. Suggest a separate compliant flow.
- Never ask the user for passwords or API keys. Integration credentials are
  entered in ThunderPhone itself (the agent's `web_url`).

Docs: https://thunderphone.com/docs/guides/build-an-agent

---
name: create-agent
description: Build a ThunderPhone AI phone agent from a plain-language brief and leave it as a draft that is ready to test. Use when someone asks to create a receptionist, booking, intake, support or outbound agent, pick a voice or language, or set up how the agent handles transfers, voicemail and silence.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Create an agent

1. **Understand the job.** Ask what the agent is for, who calls, what a good call
   ends with and what it must never do. Ask one question at a time and stop once
   you can build something testable. Read the method in
   `thunderphone://guides/working-with-thunderphone`.
2. **Check what is possible.** Use `get_agent_capabilities`,
   `get_supported_languages` and `list_voices` instead of guessing. Use
   `preview_voice` when the user wants to hear a voice.
3. **Write the prompt** in the house style (`thunderphone://guides/prompt-style`).
   Put behavior that a setting controls in the setting, not in prompt text:
   `endpointing`, `tool_start_line`, `silence_checkins_enabled`,
   `language_switching`, `voicemail_action`, `transfer_destinations`.
4. **Create it** with `create_agent`. A new agent has no phone number, so it
   takes no calls. Do not call `deploy_agent` until the user has seen a test.
5. **Let them hear it.** Offer to let the user hear the agent right away. With
   their OK (a simulated call is paid from the free test credit first), call
   `run_simulation` with a `scenario_prompt` for a typical caller (made-up
   name and details, never real personal or health information) and
   `consent_to_charge` set to true, poll `get_simulation` until it is
   completed, then give them its recording link to play and a line on how the
   call went. If they would rather talk to it themselves, `create_talk_link`
   gives a link they open in a browser. Mention the `web_url` from the result
   as the place to see and edit the agent in the dashboard, then offer the next
   step: more tests (the test-agent skill).

## Never

- Never set up an agent that collects payment card numbers, government ID
  numbers or health information from callers. Suggest a separate compliant flow.
- Never ask the user for passwords or API keys. Integration credentials are
  entered in the ThunderPhone dashboard.

Docs: https://thunderphone.com/docs/guides/build-an-agent

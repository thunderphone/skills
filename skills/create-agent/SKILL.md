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
5. **Hand over** the `web_url` from the result and offer the next step: test it
   (the test-agent skill).

## Never

- Never set up an agent that collects payment card numbers, government ID
  numbers or health information from callers. Suggest a separate compliant flow.
- Never ask the user for passwords or API keys. Integration credentials are
  entered in the ThunderPhone dashboard.

Docs: https://thunderphone.com/docs/guides/build-an-agent

# ThunderPhone export to Pipecat

Verified as of 2026-11-10 against the Pipecat pages linked below. Pipecat is
a framework: the result is a Python program the user runs, built as a
[pipeline](https://docs.pipecat.ai/pipecat/learn/pipeline) of a transport,
speech-to-text, a language model with its context, and text-to-speech. This
file names Pipecat concepts and links their pages; read each page for the
current API before writing code.

The user chooses the
[speech-to-text](https://docs.pipecat.ai/pipecat/learn/speech-to-text),
[language-model](https://docs.pipecat.ai/pipecat/learn/llm), and
[text-to-speech](https://docs.pipecat.ai/pipecat/learn/text-to-speech)
services. The export does not say what ThunderPhone runs. Do not guess.

## Mapping

| From the export | On Pipecat |
|---|---|
| `prompt.md` | The system message of the LLM context ([context management](https://docs.pipecat.ai/pipecat/learn/context-management)). Append any `reusable_instructions` from `agent.json` that `prompt.md` does not already contain. |
| `{{name}}` and `{{name\|default}}` variables in the instructions | Fill them in your own code before the pipeline starts. `call_setup_webhook_url` in `agent.json` is the endpoint ThunderPhone asked for these values before an inbound call; call it from your code if the user wants to keep it. |
| `inbound_speak_order`, `outbound_speak_order` (`agent_first` or `caller_first`) | For `agent_first`, start the first bot turn when the call connects. For `caller_first`, wait for the caller. ThunderPhone keeps the opening line in the instructions, so there is no separate greeting field to copy. |
| `primary_language`, `additional_languages` | The language options of the services the user picks. |
| `integrations[]`: `spec.function` (`name`, `description`, `parameters`), `endpoint_url`, `endpoint_method`, `headers[].key` | One function per integration ([function calling](https://docs.pipecat.ai/pipecat/learn/function-calling)), with the same name, description, and parameter schema, whose handler sends the HTTP request to the same endpoint with the same method and returns the response as the result. A `FunctionSchema` lets you copy `parameters` as written. Read header values from the environment. |
| `integrations[].request_format` | The body shape the user's endpoint expects on `POST`, `PUT`, and `PATCH`. `standard`: the arguments as the JSON body. `vapi`: Vapi's `tool-calls` server message. `retell`: `{"name", "call", "args"}`. `GET` and `DELETE` send the arguments as query parameters. Build the same shape in the handler; the shapes are in [function tools](https://thunderphone.com/docs/tools/overview.md). |
| `integrations[].spec.timeout`, `spec.wait_mode` | The function-call timeout (function calling page). For `hold`, write the wait yourself. |
| `integrations[].trigger` `call_start` with `call_start_arguments` | Call the endpoint in your own code when the call connects and add the result to the context. |
| `mcp_servers[]` | Pipecat's [MCP client](https://docs.pipecat.ai/api-reference/server/utilities/mcp/mcp), or a function per MCP tool. |
| `transfer_destinations[]` (`name`, `number`) | A function that takes the destination name and transfers to its number through the telephony provider the user picks: [Daily PSTN](https://docs.pipecat.ai/pipecat/telephony/daily-pstn) covers dial-in, dial-out, and transfers. The [Twilio](https://docs.pipecat.ai/pipecat/telephony/twilio-websockets), [Telnyx](https://docs.pipecat.ai/pipecat/telephony/telnyx-websockets), and [Plivo](https://docs.pipecat.ai/pipecat/telephony/plivo-websockets) WebSocket integrations carry the audio only: the Twilio page checked does not describe transfers, so transfer through the carrier's own API. Keep the numbers out of the instructions, as ThunderPhone does. `warm_transfer_style` and `warm_only` have no ready-made equivalent; build the warm leg or tell the user it becomes a cold transfer. |
| `system_tool_settings.end_call` | A function that ends the pipeline after the goodbye ([pipeline termination](https://docs.pipecat.ai/pipecat/learn/pipeline-termination)); in Flows, an `end_conversation` action. Left out of the export's setting, ThunderPhone has it on. |
| `system_tool_settings.send_keypad_input` | Keypad tones through the transport or carrier the user picks. Left out, ThunderPhone has it on for outbound calls only. |
| `steps` (`start_step`, `steps[]`) | [Pipecat Flows](https://docs.pipecat.ai/pipecat/flows/introduction): one node per step. `prompt.md` is the `role_message`; the step's `instructions` are the node's `task_messages`; `say` is a `tts_say` action in `pre_actions`; `tools` and `collect` become the node's `functions`. A `when` transition is a [function](https://docs.pipecat.ai/pipecat/flows/functions) whose handler returns the next node; a `condition` or `always` transition is decided in the handler's code. `global_when` steps are functions you add to every node. |
| `handoffs[]` (`agent_id`, `when`) | A function that moves to a node built from the other agent's own export. Flows has no separate agent-handoff concept on the pages checked, so say this to the user. |
| Step `voice`, `language_voices` | Switch the text-to-speech voice in your own code when the node or language changes. |
| `knowledge/` | The Pipecat docs checked have no general retrieval page. Put short content in the system message, or load the files into the user's own store and expose a lookup function. |
| `voicemail_action`, `voicemail_message` | [Voicemail detection](https://docs.pipecat.ai/pipecat/fundamentals/voicemail), then hang up, speak the message, or let the bot decide, to match `hangup`, `message`, or `prompt`. Replace `{agent_name}` and `{org_name}` in the message yourself. |
| `silence_checkins_enabled`, `silence_interval_seconds`, `silence_max_checkins`, `silence_hangup_seconds`, `silence_final_message` | [Detecting idle users](https://docs.pipecat.ai/pipecat/fundamentals/detecting-user-idle): `user_idle_timeout` and an `on_user_turn_idle` handler that checks in, counts, and ends the call. |
| `max_call_duration_seconds`, `ring_duration_seconds`, `max_hold_seconds` | Timers in your own code, or the carrier's settings. |
| `voice` | A voice the user picks from their text-to-speech service. `voice` is a ThunderPhone catalog name, or `elevenlabs:<voice_id>` or `custom:<id>`; nothing guarantees a match elsewhere. |
| `consent_announcement_enabled`, `consent_announcement_text`, `intro_clip` | Speak the announcement first, or play a recording, before the bot's first turn. The user owns the legal wording. |
| `extraction_fields`, `outcome_labels`, `call_summary_enabled` | Post-call work in your own code, on the transcript you keep. |
| `numbers.json` | The telephony setup for the provider the user picks ([telephony overview](https://docs.pipecat.ai/pipecat/telephony/overview)). Numbers move last. |
| `webhooks.json` | Send the events the user's receiver needs from your own code. ThunderPhone's event payloads and signatures are not produced by Pipecat. |

## Does not carry over

- ThunderPhone model settings: `product`, `intelligence`, `audio_tier`, `endpointing`, `thinking_level`, `faster_replies_enabled`, the `acknowledgement_*` fields, `additional_audio_context`. Tune turn-taking in Pipecat instead.
- Built-in email and SMS (`send_email_*`, `send_sms_*`, `sms_followup_*`) and `calculator_enabled`. Rebuild each as a function on the user's own provider if the instructions use it.
- Call grading, outcome labels, summaries, and extracted data, unless rebuilt.
- `X-ThunderPhone-Signature` and the other `X-ThunderPhone-*` headers on tool requests. If the user's endpoint verifies them, it needs a new check.
- `do_not_call_detection_enabled` and the organization's opt-out list, `words` pronunciations, `background_track`, typing sounds, `filler_phrases_enabled`, `tool_start_line`, `business_hours`, split testing, the web widget.
- `draft_*` fields. Ignore them; `prompt.md` and the non-draft fields are the live agent.

## Test

Run the conversations from step 6 of the skill against the Pipecat bot before
any number moves. [Pipecat Evals](https://docs.pipecat.ai/pipecat/evals/overview)
runs scripted and simulated scenarios.

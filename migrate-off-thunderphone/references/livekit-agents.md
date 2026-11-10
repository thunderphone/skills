# ThunderPhone export to LiveKit Agents

Verified as of 2026-11-10 against the LiveKit pages linked below. LiveKit
Agents is a framework: the result is a Python or Node.js program the user
runs, plus SIP telephony the user configures. This file names LiveKit concepts
and links their pages; read each page for the current API before writing code.

The user chooses the speech-to-text, language-model, and text-to-speech
providers for the session ([models](https://docs.livekit.io/agents/models/)).
The export does not say what ThunderPhone runs. Do not guess.

## Mapping

| From the export | On LiveKit Agents |
|---|---|
| `prompt.md` | The `instructions` of an `Agent` ([agent sessions](https://docs.livekit.io/agents/logic/sessions/)). Append any `reusable_instructions` from `agent.json` that `prompt.md` does not already contain. |
| `{{name}}` and `{{name\|default}}` variables in the instructions | Fill them in your own code before the session starts. `call_setup_webhook_url` in `agent.json` is the endpoint ThunderPhone asked for these values before an inbound call; call it from your code if the user wants to keep it. |
| `inbound_speak_order`, `outbound_speak_order` (`agent_first` or `caller_first`) | For `agent_first`, generate a reply when the agent becomes active (`on_enter`, [agents and handoffs](https://docs.livekit.io/agents/logic/agents-handoffs/)). For `caller_first`, do not. ThunderPhone keeps the opening line in the instructions, so there is no separate greeting field to copy. |
| `primary_language`, `additional_languages` | The language options of the providers the user picks. |
| `integrations[]`: `spec.function` (`name`, `description`, `parameters`), `endpoint_url`, `endpoint_method`, `headers[].key` | One [function tool](https://docs.livekit.io/agents/logic/tools/definition/) per integration, with the same name, description, and parameter schema, whose body sends the HTTP request to the same endpoint with the same method. Read header values from the environment. |
| `integrations[].request_format` | The body shape the user's endpoint expects on `POST`, `PUT`, and `PATCH`. `standard`: the arguments as the JSON body. `vapi`: Vapi's `tool-calls` server message. `retell`: `{"name", "call", "args"}`. `GET` and `DELETE` send the arguments as query parameters. Build the same shape in the tool body; the shapes are in [function tools](https://thunderphone.com/docs/tools/overview.md). |
| `integrations[].spec.timeout`, `spec.wait_mode` | A timeout on the HTTP request. For `hold`, write the wait yourself. |
| `integrations[].trigger` `call_start` with `call_start_arguments` | Call the tool in your own code when the session starts and add the result to the chat context. |
| `mcp_servers[]` | Check LiveKit's [tools](https://docs.livekit.io/agents/logic/tools/) pages for MCP support; otherwise write a function tool per MCP tool. |
| `transfer_destinations[]` (`name`, `number`) | A function tool that takes the destination name and transfers to its number. Cold transfer: [call forwarding](https://docs.livekit.io/telephony/features/transfers/cold/) (`TransferSIPParticipant`; the SIP provider must allow transfers through SIP REFER). `warm_transfer_style` and `warm_only`: [agent-assisted transfer](https://docs.livekit.io/telephony/features/transfers/warm/). Keep the numbers out of the instructions, as ThunderPhone does. |
| `system_tool_settings.end_call` | LiveKit's prebuilt [end-call tool](https://docs.livekit.io/agents/prebuilt/tools/end-call-tool/). Left out of the export's setting, ThunderPhone has it on. |
| `system_tool_settings.send_keypad_input` | [DTMF](https://docs.livekit.io/telephony/features/dtmf/). Left out, ThunderPhone has it on for outbound calls only. |
| `steps` (`start_step`, `steps[]`) | A [workflow](https://docs.livekit.io/agents/logic/workflows/): one agent or [task](https://docs.livekit.io/agents/logic/tasks/) per step, with the step's `instructions` after the shared `prompt.md`. `say` is spoken on entry. `tools` limits the function tools on that agent. `collect` becomes a task that returns those values. A `when` transition is a function tool that returns the next agent; a `condition` or `always` transition is code. `global_when` steps are tools every agent carries. A new LiveKit agent starts with fresh history unless you pass the chat context on; ThunderPhone keeps the transcript across steps and handoffs, so pass it. |
| `handoffs[]` (`agent_id`, `when`) | A handoff to another `Agent`, built from that agent's own export. Pass the chat context. The agent handed to brings its own instructions, steps, tools, and voice; the other call settings stay those of the agent the call started on. |
| Step `voice`, `language_voices` | A text-to-speech override on that agent. |
| `knowledge/` | [External data and RAG](https://docs.livekit.io/agents/logic/external-data/): load the files into the user's own store and expose a lookup function tool, or put short content in the instructions. |
| `voicemail_action`, `voicemail_message` | [Answering machine detection](https://docs.livekit.io/telephony/features/answering-machine-detection/), then hang up, speak the message, or let the agent decide, to match `hangup`, `message`, or `prompt`. Replace `{agent_name}` and `{org_name}` in the message yourself. |
| `silence_checkins_enabled`, `silence_interval_seconds`, `silence_max_checkins`, `silence_hangup_seconds`, `silence_final_message` | The session's `user_away_timeout` and a handler for the away state that checks in, counts, and ends the call ([agent sessions](https://docs.livekit.io/agents/logic/sessions/)). |
| `max_call_duration_seconds`, `ring_duration_seconds`, `max_hold_seconds` | Timers in your own code. The pages above list no session option for a maximum call length. |
| `voice` | A voice the user picks from their text-to-speech provider. `voice` is a ThunderPhone catalog name, or `elevenlabs:<voice_id>` or `custom:<id>`; nothing guarantees a match elsewhere. |
| `consent_announcement_enabled`, `consent_announcement_text`, `intro_clip` | Speak the announcement first, or play a recording, before the agent's first turn. The user owns the legal wording. |
| `extraction_fields`, `outcome_labels`, `call_summary_enabled` | Post-call work in your own code, on the session's transcript. |
| `numbers.json` | [SIP trunks](https://docs.livekit.io/telephony/start/sip-trunk-setup/) and a [dispatch rule](https://docs.livekit.io/telephony/accepting-calls/dispatch-rule/) for inbound; an [outbound trunk](https://docs.livekit.io/telephony/making-calls/outbound-trunk/) for outbound. Numbers move last. |
| `webhooks.json` | Send the events the user's receiver needs from your own code. ThunderPhone's event payloads and signatures are not produced by LiveKit. |

## Does not carry over

- ThunderPhone model settings: `product`, `intelligence`, `audio_tier`, `endpointing`, `thinking_level`, `faster_replies_enabled`, the `acknowledgement_*` fields, `additional_audio_context`. Tune turn-taking with LiveKit's [turn detection](https://docs.livekit.io/agents/logic/turns/).
- Built-in email and SMS (`send_email_*`, `send_sms_*`, `sms_followup_*`) and `calculator_enabled`. Rebuild each as a function tool on the user's own provider if the instructions use it.
- Call grading, outcome labels, summaries, and extracted data, unless rebuilt.
- `X-ThunderPhone-Signature` and the other `X-ThunderPhone-*` headers on tool requests. If the user's endpoint verifies them, it needs a new check.
- `do_not_call_detection_enabled` and the organization's opt-out list, `words` pronunciations, `background_track`, typing sounds, `filler_phrases_enabled`, `tool_start_line`, `business_hours`, split testing, the web widget.
- `draft_*` fields. Ignore them; `prompt.md` and the non-draft fields are the live agent.

## Test

Run the conversations from step 6 of the skill against the LiveKit agent
before any number moves. LiveKit documents its own test tools in the
[agents docs](https://docs.livekit.io/agents/).

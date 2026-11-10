# ThunderPhone export to Vapi

Verified as of 2026-11-10. Field names are the ones ThunderPhone's own Vapi
importer reads from Vapi payloads, checked against Vapi's
[create assistant](https://docs.vapi.ai/api-reference/assistants/create) and
[create tool](https://docs.vapi.ai/api-reference/tools/create) references.
Create the assistant with the user's Vapi private key
(`POST https://api.vapi.ai/assistant`) or in the Vapi dashboard, and check
Vapi's reference for a field's current shape before sending it.

The user chooses `model.provider` and `model.model`, the `transcriber`, and
the `voice`. The export does not say what ThunderPhone runs. Do not guess.

## Mapping

| From the export | On Vapi |
|---|---|
| `agent.json` `name` | `name` |
| `prompt.md` | `model.messages`: one `{"role": "system", "content": …}` message. Append any `reusable_instructions` from `agent.json` that `prompt.md` does not already contain. |
| `{{name}}` and `{{name\|default}}` variables | Vapi variables: `{{name}}`, with a default written as `{{name \| default: "value"}}`. Pass values per call as `variableValues`. `call_setup_webhook_url` in `agent.json` is the endpoint ThunderPhone asked for these values before an inbound call; Vapi has its own server request for per-call values, in its own format; see Vapi's docs. |
| `inbound_speak_order`, `outbound_speak_order` (`agent_first` or `caller_first`) | `firstMessageMode`: `assistant-speaks-first` with a `firstMessage`, `assistant-speaks-first-with-model-generated-message`, or `assistant-waits-for-user`. Vapi has one setting for both directions; if the two orders differ, make one assistant per direction and tell the user. |
| The opening line | ThunderPhone keeps it in the instructions. Either leave it there and use `assistant-speaks-first-with-model-generated-message`, or move it to `firstMessage` and delete it from the system message so it is not said twice. |
| `primary_language`, `additional_languages` | `transcriber.language`, and the voice's language options. |
| `integrations[]` with `request_format` `vapi` | A `function` tool: `function.name`, `function.description`, `function.parameters` from `spec.function`, and `server.url` from `endpoint_url`. Vapi posts its `tool-calls` message, which is the shape this endpoint already expects. Header values go in `server.headers` or a Vapi credential. |
| `integrations[]` with `request_format` `standard` | An `apiRequest` tool: `name`, `description`, `url`, `method`, `headers`, and `body` (the parameter schema). The endpoint expects the arguments alone as the JSON body, or as query parameters on `GET` and `DELETE`; confirm how Vapi sends them for the method in use. |
| `integrations[]` with `request_format` `retell` | No Vapi tool sends Retell's `{"name", "call", "args"}` body. Use an `apiRequest` tool only if the endpoint also accepts plain arguments; otherwise the user changes the endpoint or adds a small adapter. Say so. |
| `integrations[].spec.timeout`, `spec.wait_mode`, `trigger` `call_start` | No direct equivalent in the fields checked. Tell the user. |
| `mcp_servers[]` | Vapi's `mcp` tool type. |
| `transfer_destinations[]` (`name`, `number`) | A `transferCall` tool with one entry per destination in `destinations`: `type` `number` with `number`, or `type` `sip` with `sipUri`, and `description` saying when to use it. The instructions refer to destinations by name; keep those names in `description`. Warm-transfer settings (`warm_transfer_style`, `warm_only`, `answerer`) have no field in the payloads checked; see Vapi's transfer docs. |
| `system_tool_settings.end_call` | An `endCall` tool. Left out of the export's setting, ThunderPhone has it on. |
| `system_tool_settings.send_keypad_input` | A `dtmf` tool. Left out, ThunderPhone has it on for outbound calls only. |
| `steps` (`start_step`, `steps[]`) | Vapi has no step feature inside one assistant. Either fold the steps into the system message and say so (ThunderPhone renders them as one prompt with `POST /v1/agents/steps/flatten`, sending the export's `prompt` and `steps`; nothing is saved), or build a Squad with one assistant per step. |
| `handoffs[]` (`agent_id`, `when`) | A Squad: one member per agent, each built from that agent's own export, with `assistantDestinations` (`type` `assistant`, `assistantName`, `description` from `when`). Or a `handoff` tool with the same destinations. |
| `knowledge/` | Upload the files to Vapi and attach them through a `query` tool (`knowledgeBases`). See Vapi's knowledge base docs for the current shape. |
| `voicemail_action`, `voicemail_message` | `voicemailDetection` and `voicemailMessage`. Replace `{agent_name}` and `{org_name}` in the message yourself. |
| `silence_checkins_enabled`, `silence_interval_seconds`, `silence_max_checkins`, `silence_final_message` | `messagePlan.idleMessages`, or `hooks` on `customer.speech.timeout` that say a line and then end the call. |
| `silence_hangup_seconds` | `silenceTimeoutSeconds` |
| `max_call_duration_seconds` | `maxDurationSeconds`. Set it explicitly: Vapi's default is 600 seconds, and `null` on ThunderPhone means no per-agent limit. |
| `voice` | `voice.provider` and `voice.voiceId`, chosen by the user. `voice` is a ThunderPhone catalog name, or `elevenlabs:<voice_id>` or `custom:<id>`; nothing guarantees a match elsewhere. |
| `consent_announcement_enabled`, `consent_announcement_text` | Vapi does not play it for you. Put it at the start of `firstMessage`. The user owns the legal wording. |
| `background_track` | `backgroundSound`, from Vapi's own choices. |
| `extraction_fields`, `outcome_labels`, `call_summary_enabled` | Vapi's post-call analysis. Rebuild each field there; nothing converts it. |
| `numbers.json` | A Vapi phone number with `assistantId` set. A number on the user's own carrier is imported into Vapi with that carrier's credentials. Numbers move last. |
| `webhooks.json` | The assistant's `server.url` and `serverMessages`, such as `end-of-call-report`. Vapi's payloads and signatures differ from ThunderPhone's, so the receiver changes. |

## Does not carry over

- ThunderPhone model settings: `product`, `intelligence`, `audio_tier`, `endpointing`, `thinking_level`, `faster_replies_enabled`, the `acknowledgement_*` fields, `additional_audio_context`.
- Built-in email and SMS (`send_email_*`, `send_sms_*`, `sms_followup_*`) and `calculator_enabled`. Rebuild each as a Vapi tool if the instructions use it.
- Call grading, outcome labels, summaries, and extracted data, unless rebuilt in Vapi's analysis.
- `X-ThunderPhone-Signature` and the other `X-ThunderPhone-*` headers on tool requests. If the user's endpoint verifies them, it needs a new check.
- `ring_duration_seconds`, `max_hold_seconds`, `wait_on_hold`, `intro_clip`, `do_not_call_detection_enabled` and the organization's opt-out list, `words` pronunciations, typing sounds, `filler_phrases_enabled`, `tool_start_line`, `business_hours`, split testing, the web widget.
- `draft_*` fields. Ignore them; `prompt.md` and the non-draft fields are the live agent.

## Test

Run the conversations from step 6 of the skill against the Vapi assistant
before any number moves, using Vapi's own test calls.

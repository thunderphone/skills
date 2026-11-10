# ThunderPhone export to Retell

Verified as of 2026-11-10. Field names are the ones ThunderPhone's own Retell
importer reads from Retell payloads, checked against Retell's
[create agent](https://docs.retellai.com/api-references/create-agent),
[create Retell LLM](https://docs.retellai.com/api-references/create-retell-llm),
[create conversation flow](https://docs.retellai.com/api-references/create-conversation-flow),
and [create knowledge base](https://docs.retellai.com/api-references/create-knowledge-base)
references. Create everything with the user's Retell key or in the Retell
dashboard, and check Retell's reference for a field's current shape before
sending it.

A Retell agent points at a response engine through `response_engine`: a
Retell LLM (`type` `retell-llm`, `llm_id`) for a single-prompt agent, or a
conversation flow (`type` `conversation-flow`, `conversation_flow_id`) for an
agent with steps. Build the engine first, then the agent.

The user chooses the engine's model and the agent's `voice_id`. The export
does not say what ThunderPhone runs. Do not guess.

## Mapping

| From the export | On Retell |
|---|---|
| `agent.json` `name` | `agent_name` |
| `prompt.md` | Retell LLM `general_prompt`, or a conversation flow's `global_prompt`. Append any `reusable_instructions` from `agent.json` that `prompt.md` does not already contain. |
| `{{name}}` and `{{name\|default}}` variables | Retell dynamic variables: `{{name}}`, with defaults in `default_dynamic_variables`. `call_setup_webhook_url` in `agent.json` is the endpoint ThunderPhone asked for these values before an inbound call; Retell has its own inbound webhook on the phone number, in its own format. |
| `inbound_speak_order`, `outbound_speak_order` (`agent_first` or `caller_first`) | `start_speaker`: `agent` or `user`. Retell has one setting for both directions; if the two orders differ, make one agent per direction and tell the user. |
| The opening line | ThunderPhone keeps it in the instructions. Either leave it there and leave `begin_message` unset, so the model generates the first line, or move it to `begin_message` and delete it from the prompt so it is not said twice. |
| `primary_language`, `additional_languages` | `language`: one locale or a list, from Retell's fixed set. |
| `integrations[]` with `request_format` `retell` | A `custom` tool: `name`, `description`, `url`, `method`, `parameters`, `headers`. Retell sends `{"name", "call", "args"}`, which is the shape this endpoint already expects. |
| `integrations[]` with `request_format` `standard` | A `custom` tool with `args_at_root` set to `true`, so the arguments are the body. |
| `integrations[]` with `request_format` `vapi` | No Retell tool sends Vapi's `tool-calls` message. The user changes the endpoint or adds a small adapter. Say so. |
| `integrations[].spec.timeout` | `timeout_ms` on the tool. |
| `integrations[].spec.wait_mode`, `trigger` `call_start` | No direct equivalent in the fields checked. In a conversation flow, a `function` node at the start can run the tool first. Tell the user. |
| `mcp_servers[]` | Retell's `mcp` tool type, or `mcps` on a conversation flow. |
| `transfer_destinations[]` (`name`, `number`) | One `transfer_call` tool per destination: `name` and `description` from the destination name, `transfer_destination` (`type` `predefined`, `number`), and `transfer_option` (`type` `cold_transfer` or `warm_transfer`). A `{{variable}}` number stays a dynamic variable. Retell documents no SIP-header or return-to-contact-center equivalent in the fields checked. |
| `system_tool_settings.end_call` | An `end_call` tool. Left out of the export's setting, ThunderPhone has it on. |
| `system_tool_settings.send_keypad_input` | A `press_digit` tool. Left out, ThunderPhone has it on for outbound calls only. |
| `steps` (`start_step`, `steps[]`) | A conversation flow: `start_node_id` from `start_step`, one `conversation` node per step. The step's `instructions` are the node's `instruction` (`type` `prompt`); a step with only a `say` line uses `type` `static_text`. A `when` transition is an edge with a `prompt` `transition_condition` and a `destination_node_id`; a `condition` transition is an `equation` condition; `always` is the node's `always_edge`. `collect` is an `extract_dynamic_variables` node; `on_enter_tool` is a `function` node before the step; `global_when` is the node's `global_node_setting` condition. A node holds one instruction, so a step with both `say` and `instructions` needs the line written into the prompt. |
| `handoffs[]` (`agent_id`, `when`) | An `agent_swap` tool or node pointing at a Retell agent built from the other agent's own export, with `when` as its `description`. |
| `knowledge/` | A Retell knowledge base (`knowledge_base_name`, `knowledge_base_files`, `knowledge_base_texts`, `knowledge_base_urls`), then its id in the engine's `knowledge_base_ids`. Retell's reference limits one request to 25 files of 50 MB each. |
| `voicemail_action`, `voicemail_message` | `voicemail_option.action`: `type` `hangup`, `static_text` with `text` for a fixed message, or `prompt`. Replace `{agent_name}` and `{org_name}` in the message yourself. |
| `silence_hangup_seconds`, and the check-in settings | `end_call_after_silence_ms` (at least 10,000). Retell's `reminder_trigger_ms` and `reminder_max_count` take the place of ThunderPhone's check-ins; `silence_final_message` and a transfer as the final action have no field in the payloads checked. |
| `max_call_duration_seconds` | `max_call_duration_ms`. Retell allows 60,000 to 7,200,000 (two hours); ThunderPhone allows up to six hours or no limit, so tell the user if the value has to come down. |
| `ring_duration_seconds` | `ring_duration_ms` (5,000 to 300,000). |
| `voice` | `voice_id`, chosen by the user from Retell's voices. `voice` is a ThunderPhone catalog name, or `elevenlabs:<voice_id>` or `custom:<id>`; nothing guarantees a match elsewhere. |
| `consent_announcement_enabled`, `consent_announcement_text` | Retell does not play it for you. Put it at the start of `begin_message`. The user owns the legal wording. |
| `words` | `pronunciation_dictionary` (`word`, `alphabet`, `phoneme`) for entries that have an `ipa` value, and `boosted_keywords` for terms the agent must hear. |
| `extraction_fields`, `call_summary_enabled`, `outcome_labels` | `post_call_analysis_data`. Rebuild each field there; nothing converts it. |
| `numbers.json` | A Retell phone number with its inbound and outbound agent set. A number on the user's own carrier is connected through Retell's custom telephony. Numbers move last. |
| `webhooks.json` | The agent's `webhook_url`. Retell's payloads and signatures differ from ThunderPhone's, so the receiver changes. |

Retell marks `states` on a Retell LLM as deprecated. Use a conversation flow
for an agent with steps.

## Does not carry over

- ThunderPhone model settings: `product`, `intelligence`, `audio_tier`, `endpointing`, `thinking_level`, `faster_replies_enabled`, the `acknowledgement_*` fields, `additional_audio_context`.
- Built-in email and SMS (`send_email_*`, `send_sms_*`, `sms_followup_*`) and `calculator_enabled`. Rebuild each as a Retell tool if the instructions use it.
- Call grading, outcome labels, summaries, and extracted data, unless rebuilt in Retell's post-call analysis.
- `X-ThunderPhone-Signature` and the other `X-ThunderPhone-*` headers on tool requests. If the user's endpoint verifies them, it needs a new check.
- `max_hold_seconds`, `wait_on_hold`, `intro_clip`, `background_track`, `do_not_call_detection_enabled` and the organization's opt-out list, typing sounds, `filler_phrases_enabled`, `tool_start_line`, `business_hours`, split testing, the web widget.
- `draft_*` fields. Ignore them; `prompt.md` and the non-draft fields are the live agent.

## Test

Run the conversations from step 6 of the skill against the Retell agent
before any number moves, using Retell's own test tools. Publish the agent
version the number will answer with.

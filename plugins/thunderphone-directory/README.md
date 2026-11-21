# ThunderPhone directory plugin (ChatGPT / Codex)

The package submitted to the OpenAI plugin directory: the remote MCP server with OAuth (`mcp.json`) and, from
1.1.0, a skills bundle (`skills/<name>/SKILL.md`, discovered from the package root).

## 1.3.1: the same experience as the Claude plugin

1.3.1 matches the Claude plugin (`../thunderphone-claude`, 1.3.1): the same skills, and on the server the same
1.3 experience (setup questions with tap answers, the talk-to-your-agent card, two-step calls and texts, a number
bought, connected and put live with one yes, free voice samples, simple pages for links). ChatGPT keeps the campaign
tools and `test_integration` that OpenAI approved; Claude's profile drops them at Anthropic's request.

The server side is `api/orgs/mcp_profiles.py` `CHATGPT` (ChatGPT's connector, redirecting to chatgpt.com, and
Codex). Off, those connections get the 1.1 surface OpenAI approved, byte for byte.

How OpenAI's portal takes tool changes (learned 2026-11-20): it scans the server daily, and on Rescan, through the
portal's own connection, which is ThunderPhone org 6 in production. Every changed tool that passes its checks is
published to live ChatGPT at once, and the others keep their earlier version ("Earlier version published") until
OpenAI reviews them by hand ("Request manual review"). The 11-20 scan of 1.3 held `create_agent`, `update_agent`
and `provision_phone_number` and published the rest, two-step `place_call` and `send_sms` included. So the server
must switch for everyone at the rescan, not for the portal's organization alone. Three settings:

- `CHATGPT_PLUGIN_V13`: 1.3 for every ChatGPT and Codex connection.
- `CHATGPT_PLUGIN_V13_HELD_TOOLS`: the tools the scan held. Everyone else keeps their published definition and
  behaviour (a one-step `provision_phone_number`, for one) until OpenAI approves them.
- `CHATGPT_PLUGIN_V13_ORG_IDS`: the organizations that see 1.3 in full, held tools included: the portal's (6) and
  the review sandbox (172), so the scan and the reviewers see what is being reviewed.

Rollout: set all three on the prod API (`CHATGPT_PLUGIN_V13=true`,
`CHATGPT_PLUGIN_V13_HELD_TOOLS=create_agent,update_agent,provision_phone_number`, `CHATGPT_PLUGIN_V13_ORG_IDS=6,172`),
then Rescan in the portal, check the MCPs tab shows only the held tools as "Earlier version published", and add any
other tool it held to the list. Then "Request manual review" on the MCPs tab and "Submit for review" for the 1.3.1
package. After OpenAI approves, clear `CHATGPT_PLUGIN_V13_HELD_TOOLS`. To undo before that, set
`CHATGPT_PLUGIN_V13=false` and Rescan, which puts the 1.1 surface back.

`test_mcp_chatgpt_profile` pins the 1.3 tool list by hash. It is built from Claude's 1.3 surface, so a Claude-side
edit changes it, and the next daily scan sends the change to ChatGPT. Update the hash only together with a
ChatGPT rescan. The demo recording (`review.demo_recording_url`) still shows 1.1; record a new one in ChatGPT
before submitting. Alex owns the submission.

For the next submission: `provision_phone_number`'s description still says "$1 a month" (kept byte for byte in
`mcp_profiles._CHATGPT_SUBMITTED_NUMBER_DESCRIPTION` since US numbers moved to per-number prices); switch it to
Claude's description and update the pinned hash at that submission.

## Try asking

- "Set up something to answer my business phone."
- "Build an agent that calls me, and let me hear it first."
- "Move my receptionist over from my current voice AI platform."

Build the upload with:

```bash
cd agent-skills/plugins/thunderphone-directory && zip -r ../thunderphone-directory.zip plugin.json mcp.json assets skills
```

## Skills

These skills are written for the MCP tools, not for REST, and are their own source: they are not mirrored from
the pack in `agent-skills/<name>/` (those use `THUNDERPHONE_API_KEY` and REST calls, which a ChatGPT user does
not have). `scripts/agent-skills-check.py` checks them in CI: frontmatter, no credential handling or REST calls,
and every backticked tool, argument or result name must exist in `api/orgs/mcp_tools.py` (or the handlers and
link code beside it), so renaming a tool fails the check instead of a reviewer's chat.

Rules for adding one: the user never types a password, API key or other secret into chat (send them to the
ThunderPhone page a result's `web_url` opens instead), billable or outward actions say they need the user's yes, and agents are never set up to
collect payment card numbers, government ID numbers or health information.

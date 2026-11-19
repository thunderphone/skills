# ThunderPhone directory plugin (ChatGPT / Codex)

The package submitted to the OpenAI plugin directory: the remote MCP server with OAuth (`mcp.json`) and, from
1.1.0, a skills bundle (`skills/<name>/SKILL.md`, discovered from the package root).

## 1.3.1: the same experience as the Claude plugin

1.3.1 matches the Claude plugin (`../thunderphone-claude`, 1.3.1): the same skills, and on the server the same
1.3 experience (setup questions with tap answers, the talk-to-your-agent card, two-step calls and texts, a number
bought, connected and put live with one yes, free voice samples, simple pages for links). ChatGPT keeps the campaign
tools and `test_integration` that OpenAI approved; Claude's profile drops them at Anthropic's request.

The server side is `api/orgs/mcp_profiles.py` `CHATGPT` (ChatGPT's connector, redirecting to chatgpt.com, and
Codex). Off, those connections get the 1.1 surface OpenAI approved, byte for byte. Two switches turn it on:

- `CHATGPT_PLUGIN_V13_ORG_IDS`: listed organizations only. Set it to OpenAI's review sandbox for the resubmission,
  so OpenAI's scan and reviewers see 1.3 while every live ChatGPT user keeps the approved surface. Calls and texts
  become two-step in 1.3, so turning it on for everyone before approval would leave ChatGPT calling with the old,
  held schemas.
- `CHATGPT_PLUGIN_V13`: every organization. Turn it on once OpenAI approves 1.3.1.

`test_mcp_chatgpt_profile` pins the 1.3 tool list by hash. It is built from Claude's 1.3 surface, so a Claude-side
edit changes it: update the hash only with a ChatGPT resubmission. The demo recording
(`review.demo_recording_url`) still shows 1.1; record a new one in ChatGPT against the sandbox before submitting.
Alex owns the submission.

## Try asking

- "Set up something to answer my business phone."
- "Build an agent that calls me, and let me hear it first."
- "Move my receptionist over from Vapi."

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

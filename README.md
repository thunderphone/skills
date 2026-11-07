# ThunderPhone Agent Skills

Procedures and plugin packaging for building, connecting, testing, and operating
ThunderPhone voice agents. The skills work with Claude Code, Codex, Cursor, VS
Code, and other clients that implement the [Agent Skills specification](https://agentskills.io).

## Install

Install the portable skills:

```bash
npx skills add thunderphone/skills
```

Install the Claude Code plugin:

```text
/plugin marketplace add thunderphone/skills
/plugin install thunderphone@thunderphone-skills
```

Install the Codex plugin:

```bash
codex plugin marketplace add thunderphone/skills
codex plugin add thunderphone@thunderphone-skills
```

For Cursor or VS Code, clone the repository and copy the skill directories into
the agent-skills directory supported by your client. Do not copy `plugins/`,
which is a generated Codex mirror.

## Connect the MCP server

The plugin connects to ThunderPhone's MCP server,
`https://api.thunderphone.com/v1/mcp`, and signs in with OAuth: the first tool
call opens a browser where you approve one ThunderPhone organization, and the
client keeps the token. No config in this repository carries a credential, and
the plugin never reads one from your machine.

```bash
# Claude Code (the plugin adds this for you)
claude mcp add --transport http --scope project thunderphone https://api.thunderphone.com/v1/mcp

# Codex
codex mcp add thunderphone --url https://api.thunderphone.com/v1/mcp
codex mcp login thunderphone

# Cursor: copy the project-scoped config from this repository.
mkdir -p /path/to/your-project/.cursor
cp .cursor/mcp.json /path/to/your-project/.cursor/mcp.json
```

VS Code can use `.vscode/mcp.json`. See the
[`thunderphone-mcp-setup`](./thunderphone-mcp-setup/SKILL.md) skill for all
supported clients.

## What the plugin runs and sends

- **MCP server:** the plugin's only server is the remote ThunderPhone MCP
  server above. Tool calls go to ThunderPhone with your OAuth token and act only
  in the organization you approved. Deletes always ask for your confirmation
  first; in Claude, so does every call and text.
- **Skills:** Markdown procedures. Their REST examples are code for your own
  application, which authenticates to ThunderPhone's API with your own
  organization key; the plugin itself never reads or sends that key.
- No hooks, no local servers, no package installs.

Your MCP client stores the OAuth token; ThunderPhone keeps only a hashed copy
to check it. To disconnect, open **Organization → API keys → Authorized apps**
in the ThunderPhone dashboard and choose **Revoke**
([OAuth guide](https://thunderphone.com/docs/guides/oauth.md)). What ThunderPhone
collects and how it is used is in the [privacy policy](https://thunderphone.com/privacy).

The server is listed in the official MCP Registry as
`io.github.thunderphone/thunderphone` (`server.json` in this repo). After changing that file,
an org owner republishes it with `mcp-publisher login github && mcp-publisher publish` from
this directory.

## Skills

- `setup-api-key` — create, store, verify, and troubleshoot an organization API key.
- `create-agent` — choose a model tier and create, edit, deploy, or discard an agent draft.
- `thunderphone-prompt-builder` — write and validate a production voice-agent prompt.
- `get-phone-number` — provision a ThunderPhone number or connect a carrier through SIP.
- `handle-inbound-calls` — attach an inbound agent and pass dynamic call context safely.
- `place-outbound-calls` — clear the consent gate, place calls, and retrieve results.
- `build-tool-integration` — connect HTTP functions, API connections, and remote MCP tools.
- `setup-webhooks` — subscribe to events and verify signed webhook deliveries.
- `add-knowledge` — import documents and URLs, search them, and attach knowledge to agents.
- `test-agent` — generate scenarios, run simulations, inspect evidence, and iterate.
- `iterate-on-agent` — review and edit a prompt, replay real and simulated conversations on the draft, compare configurations, listen, and deploy with approval.
- `run-campaign` — create compliant outbound campaigns, load contacts, and monitor stats.
- `embed-web-widget` — ship the React, headless, or CDN web-call widget.
- `use-with-pipecat` — use ThunderPhone Realtime as a Pipecat model service.
- `use-with-livekit` — use the current ThunderPhone LiveKit plugin fork.
- `use-with-openai-realtime` — point an OpenAI Realtime client at ThunderPhone.
- `migrate-from-vapi` — import Vapi agents and close manual migration gaps.
- `migrate-from-retell` — import Retell agents and close manual migration gaps.
- `migrate-from-bland` — import Bland agents and close manual migration gaps.
- `migrate-from-elevenlabs` — import ElevenLabs agents and close manual migration gaps.
- `thunderphone-mcp-setup` — configure the MCP server for six coding-agent clients.

## Contributing

Treat the production OpenAPI document and the raw Markdown documentation as the
source of truth. Keep procedures concise, use real methods and fields, and do
not include credentials or fabricated resource identifiers.

After editing a canonical skill, refresh and validate the generated Codex tree
(the sync script lives in the ThunderPhone monorepo, outside this pack, as
`scripts/agent-skills-sync-plugin-tree.sh`).

Keep each root skill and its copy under `plugins/thunderphone/skills/`
byte-identical. Pull requests should include both sides of that generated tree.

## Maintainers

This repository is a generated public mirror of ThunderPhone's canonical skill
pack. Maintainers publish reviewed upstream changes; direct edits here may be
overwritten by the next mirror update.

## Sources

- Documentation index: https://thunderphone.com/docs/llms.txt
- API introduction: https://thunderphone.com/docs/api-reference/introduction.md
- MCP guide: https://thunderphone.com/docs/guides/thunderphone-mcp-server.md

## License

[MIT](./LICENSE) © Autophonix, LLC.

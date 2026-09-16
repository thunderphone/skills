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

Set `THUNDERPHONE_API_KEY` in your shell without printing it, then use the
client-specific command or checked-in config:

```bash
# Claude Code: keep the environment-variable reference in the project config.
claude mcp add --transport http --scope project --header 'Authorization: Bearer ${THUNDERPHONE_API_KEY}' thunderphone https://api.thunderphone.com/v1/mcp

# Codex: Codex reads the token from the named environment variable.
codex mcp add thunderphone --url https://api.thunderphone.com/v1/mcp --bearer-token-env-var THUNDERPHONE_API_KEY

# Cursor: copy the project-scoped config from this repository.
mkdir -p /path/to/your-project/.cursor
cp .cursor/mcp.json /path/to/your-project/.cursor/mcp.json
```

VS Code can use `.vscode/mcp.json`. The repository also includes root
`.mcp.json` and Codex `mcp.json` variants. See the
[`thunderphone-mcp-setup`](./thunderphone-mcp-setup/SKILL.md) skill for all
supported clients.

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

After editing a canonical skill, refresh and validate the generated Codex tree:

```bash
./scripts/sync-plugin-tree.sh
./scripts/sync-plugin-tree.sh --check
```

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

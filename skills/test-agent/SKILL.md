---
name: test-agent
description: Test a ThunderPhone agent and decide whether it is ready to deploy. Use when someone asks to test an agent, run test scenarios or simulated calls, check a change before deploying, or read test results.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Test an agent

Pick the check that fits the change and what it could break.

| Check | Tool | Cost | Good for |
|---|---|---|---|
| Text test | `test_in_text` | Free, about a minute | Wording, facts, which tools the agent calls |
| Saved scenarios | `test_my_agent` | Test credit first | A pass/fail run over the agent's scenarios |
| One simulated call | `run_simulation` | Test credit first | Timing, the voice, hearing the caller |
| Talk to it | `create_talk_link` | Billed like a test call | The user's own ear |

1. **Text first.** Run `test_in_text` on the draft with callers aimed at the
   change and one whose call should go as before. Read each transcript the way a
   caller would hear it. Tool results are simulated; say so.
2. **Billed runs need a yes.** Before `test_my_agent`, `run_agent_tests` or
   `run_simulation`, tell the user that test calls draw on the free test credit
   first, and set `consent_to_charge` only after they agree.
3. **One call does the loop.** `test_my_agent` runs the saved scenarios, or
   generates some when there are none, and waits for the verdicts. If it returns
   before they are in, check again with `get_test_run` and the `batch_id`.
4. **Report evidence.** For each failure, quote the turn that failed and propose
   one change. Make it on the draft with `update_agent` and test again.
5. **Deploy only after a yes** with `deploy_agent`.

Docs: https://thunderphone.com/docs/guides/test-agents

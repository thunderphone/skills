---
name: thunderphone-prompt-builder
description: Draft, review, translate, or validate a production ThunderPhone voice-agent prompt. Use when someone asks for prompt engineering, a bilingual phone prompt, TTS-friendly instructions, a prompt language check, or a safe prompt template for a ThunderPhone agent.
license: MIT
compatibility: Prompt drafting works offline; API validation requires THUNDERPHONE_API_KEY.
metadata:
  author: thunderphone
  version: "1.0"
---

# Build a production prompt

Write the prompt the way a person would brief a new receptionist. The
[prompt style guide](https://thunderphone.com/docs/guides/prompt-style.md)
has every guideline with its id; MCP clients can read it as the resource
`thunderphone://guides/prompt-style`.

1. **Collect facts, not dialogue.** Record the business identity, supported
   tasks, boundaries, escalation path and transfer numbers, hours,
   policies, languages, and data the agent may use. Mark uncertain facts
   for confirmation.
2. **Write the call in the order it happens.** A short opening says who
   the agent is and, in a few words, how it talks. Then the call: how it
   opens, what to find out, what to confirm, how it ends. Each rule goes in
   the step where it applies, with no separate list of rules. Use the
   template in [references/prompt-template.md](references/prompt-template.md).
3. **Describe principles and facts, not lines.** Say what the agent is
   trying to achieve and what it may offer. Leave out `if the caller says
   X, say Y` branches and canned answers. The opening greeting is the one
   line written out word for word. When an example of wording helps, give
   a few varied, full spoken sentences and introduce them as examples; the
   agent copies example wording closely.
4. **Say it plainly, once.** State each behavior as an instruction in
   ordinary words where it applies. Leave out emphasis: capitals, labels
   such as IMPORTANT, exclamation marks, and "never", "always" or "must"
   used for force. When the agent ignores an instruction, make it clearer
   or move it, rather than louder.
5. **Make speech listenable.** One question per turn, with the question
   last. Short turns. No symbols the voice will misread (slashes,
   ampersands, "@", ".com", phone numbers written without spaces). Say
   what to confirm (names, numbers, emails, addresses, codes) in the form
   they were given; the platform paces the read-back.
6. **Leave settings to the settings.** What is said while a tool runs,
   filler phrases, silence check-ins, read-back pacing, the
   language-switching style, the recording notice, and who speaks first are
   agent settings. Set them on the agent and keep the prompt on the
   outcome.
7. **Define language behavior.** State the supported languages and how
   the agent follows the caller's language. Do not paste parallel
   translated scripts.
8. **Check the prompt language** before attaching it to an agent.

```json request POST /v1/agents/translate-prompt
{
  "prompt": "${AGENT_PROMPT}",
  "target_locale": "${TARGET_LOCALE}"
}
```

```bash
curl --fail-with-body -X POST https://api.thunderphone.com/v1/agents/prompt-language-check \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/thunderphone-prompt-builder@1.0" \
  --data-binary "$(jq -n --arg prompt "$AGENT_PROMPT" '{prompt:$prompt}')"
```

```python
import os, requests

r = requests.post("https://api.thunderphone.com/v1/agents/prompt-language-check",
    json={"prompt": os.environ["AGENT_PROMPT"]},
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/thunderphone-prompt-builder@1.0"}, timeout=30)
r.raise_for_status()
print(r.json())
```

```ts
const response = await fetch("https://api.thunderphone.com/v1/agents/translate-prompt", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json",
    "X-ThunderPhone-Client": "skills/thunderphone-prompt-builder@1.0" },
  body: JSON.stringify({ prompt: process.env.AGENT_PROMPT, target_locale: process.env.TARGET_LOCALE }),
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

9. **Translate only when needed.** Use `POST /v1/agents/translate-prompt`
   with `prompt` and a supported `target_locale`; then have a competent
   speaker review domain meaning and spoken phrasing.
10. **Review it against the guide.** For an agent in an organization with
    the agent iteration toolkit, `POST /v1/agents/{agent_id}/prompt-review`
    (MCP `review_prompt`) returns findings with guideline ids and
    find-and-replace edits; apply them to the draft with `update_agent`.
11. **Verify in calls.** Use the `iterate-on-agent` skill to replay real
    and simulated conversations against the draft, or `test-agent` for
    scenario runs.

## Prompt review checklist

- The call reads in order, and each rule sits in the step it governs.
- Headings are plain ("Who you are", "The call", "Facts", "Handing off");
  there is no rules manual, numbered rule list or "see section X".
- No caller-response branches or canned lines beyond the greeting.
- No emphasis: no capitals for force, IMPORTANT labels, exclamation marks,
  or "never" and "always" used for force.
- Facts sit apart from behavior, or in a knowledge base, and have a source.
- One question per turn; costly details are confirmed in the form given.
- Settings (tool-start line, check-ins, read-back pacing, who speaks
  first) are set on the agent, not described in the prompt.
- Transfers name the agent's transfer numbers; tool failures and handoff
  have a safe outcome.
- The prompt sounds natural when read aloud.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Agent sounds scripted | Prompt contains branches or canned replies | Replace them with the goal, what the agent may offer, and the facts it needs. |
| Agent ignores a rule | The rule sits far from its step, or competes with emphasis elsewhere | Move it to the step it governs and say it plainly; remove the emphasis. |
| Agent invents business facts | Facts are missing or mixed into vague prose | Add a short facts section or attach a knowledge base. |
| Translation reads unnaturally | Literal translation was accepted without review | Review it for speech, domain terms, locale, and intent. |
| Language check rejects text | Prompt and configured language conflict | Inspect the result, correct the prompt or choose the intended locale. |

## Source and safety rules

- Follow the [prompting guide](https://thunderphone.com/docs/guides/prompting.md) and the [prompt style guide](https://thunderphone.com/docs/guides/prompt-style.md).
- Confirm locales in [supported languages](https://thunderphone.com/docs/guides/supported-languages.md).
- Do not put secrets, regulated records, real callers' details, or invented facts in a prompt.
- A synthetic text pass does not prove audio quality, latency, or legal compliance.

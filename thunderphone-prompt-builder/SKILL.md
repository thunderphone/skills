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

1. **Collect facts, not dialogue.** Record the business identity, supported
   tasks, boundaries, escalation path, hours, policies, languages, and data the
   agent may use. Keep uncertain facts marked for confirmation.
2. **Write general principles.** Describe goals and decision criteria. Do not
   add `if the caller says X, say Y` branches, canned responses, or scripts.
   The opening greeting is the only acceptable scripted line.
3. **Separate stable sections.** Use the template in
   [references/prompt-template.md](references/prompt-template.md): role,
   responsibilities, conversation behavior, facts, boundaries, tools,
   handoff, languages, and opening greeting.
4. **Make speech listenable.** Prefer short sentences, common punctuation,
   pronounceable words, and one question at a time. Do not depend on Markdown
   formatting being spoken. Tell the agent to read numbers, dates, and names
   naturally when the domain requires it.
5. **Define language behavior.** State the supported languages and the rule for
   switching based on the caller. Do not paste parallel translated scripts.
6. **Check the prompt language** before attaching it to an agent.

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

7. **Translate only when needed.** Use `POST /v1/agents/translate-prompt` with
   `prompt` and a supported `target_locale`; then have a competent speaker
   review domain meaning and spoken phrasing.
8. **Verify in calls.** Run adversarial scenarios, interruptions, language
   switches, tool failures, and escalation cases with the `test-agent` skill.

## Prompt review checklist

- Every instruction is a principle, fact, boundary, or tool rule.
- No caller-response decision tree or canned line exists beyond the greeting.
- Facts are isolated from behavior instructions and have a named source.
- The agent asks one question at a time and confirms high-impact details.
- Language switching and unsupported-language behavior are explicit.
- Tool failures and human handoff have safe outcomes.
- The prompt sounds natural when read aloud.

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Agent sounds scripted | Prompt contains branches or canned replies | Replace examples with the governing principle and relevant facts. |
| Agent invents business facts | Facts are missing or mixed into vague prose | Add a concise facts section or attach a knowledge base. |
| Translation reads unnaturally | Literal translation was accepted without review | Review it for speech, domain terms, locale, and intent. |
| Language check rejects text | Prompt and configured language conflict | Inspect the result, correct the prompt or choose the intended locale. |

## Source and safety rules

- Follow the [prompting guide](https://thunderphone.com/docs/guides/prompting.md) and the repository's prompt-content policy.
- Confirm locales in [supported languages](https://thunderphone.com/docs/guides/supported-languages.md).
- Do not put secrets, regulated records, or invented facts in a prompt.
- A synthetic text pass does not prove audio quality, latency, or legal compliance.

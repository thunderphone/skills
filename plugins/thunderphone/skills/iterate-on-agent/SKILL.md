---
name: iterate-on-agent
description: Improve an existing ThunderPhone voice agent in a measured loop. Review and edit its prompt against the prompt style guide, build dev and test conversation sets from real or simulated calls, replay them on the draft, compare configurations, listen to the result, and deploy only with the person's OK. Use when someone asks to fix, tune, improve, refactor or regression-test an agent's prompt or configuration, to find out why calls go wrong, or to check a change before it goes live.
license: MIT
compatibility: Requires the ThunderPhone MCP server or THUNDERPHONE_API_KEY, and the agent iteration toolkit, which is enabled per organization during its beta. Prompt review, conversation jobs, replays and simulated calls spend credits.
metadata:
  author: thunderphone
  version: "1.0"
---

# Iterate on an agent

This is the loop for changing an agent that already exists: measure it,
change one thing, measure again, listen, and hand the decision to deploy
to the person. Tools are named by their MCP names; the REST equivalent of
each, and what it returns, is in [references/tools.md](references/tools.md).

Most of these tools belong to the agent iteration toolkit. If the first
toolkit call answers `feature_not_enabled`, tell the person that
ThunderPhone support enables it per organization, and use the `test-agent`
skill in the meantime.

## The loop

1. **Read the agent and the guide.**
   - `get_agent`: the draft prompt is `draft_prompt`, or `prompt` when
     `draft_prompt` is null. Note the settings that shape a call: `product`,
     voice, languages, tool-start line, silence check-ins.
   - `list_prompt_revisions`: what changed recently, from which surface,
     with a diff for each change.
   - The style guide: the MCP resource `thunderphone://guides/prompt-style`,
     or the [public copy](https://thunderphone.com/docs/guides/prompt-style.md).
     Review findings cite its ids (P1, C4, W2 and so on).
   - Ask the person what goes wrong, in their words, and for example calls.
   - A call whose caller is in one of the agent's test splits is held
     out, over REST and MCP alike. To an API key, an OAuth token (so every
     MCP tool) or a legacy token, `list_calls`, `get_call`,
     `get_call_transcript`, `get_call_audio_url`, `get_call_grade`,
     `export_calls` and their REST endpoints return it as its `call_id`,
     its start time and `held_out: true` only, without its transcript,
     recording, history, grade or report. A write on it (grading,
     promoting it to a test scenario, regenerating a turn) is refused with
     403 `held_out_call`. Views across many calls (report summaries, issue
     clusters, investigations, pipeline reports) leave held-out calls out
     of their counts and samples and withhold any text a model wrote from
     them. A test scenario someone promoted from a held-out call comes back
     as its id and `held_out: true`, and the simulated calls run from it are
     held out too; test runs still run it. A dev conversation or example
     copied from a held-out caller's call reads like a test-split one.
     People see everything in the dashboard, and an admin can give one API
     key `include_held_out_calls` (off by default, set only in the
     dashboard) for an integration that needs every call; MCP never uses
     it. Leave held-out calls out when you look for failures to fix: the
     test split measures your change, and tuning on its callers spoils the
     measurement.

2. **Build the test sets.** Start with `list_conversations`; the agent may
   already have some.
   - An agent with calls: `import_conversations` turns recent calls into
     conversations, at most two per caller, and their hard moments into
     examples with answer keys.
   - A new agent: `generate_conversations` writes conversations with
     invented callers.
   - Weak spots: `generate_conversations` with `style: "adversarial"` aims
     difficult callers at passages of the prompt. After a prompt edit,
     `target: "changed_behaviors"` aims them at what changed. Adversarial
     conversations always go to the dev split: they are written with the
     change in view, so they are tuning material, never a measurement.
   - Quote each job first: `dry_run: true` returns the estimate and a
     `quote_id`. The real run sends that `quote_id` back with the same
     arguments, within 15 minutes, plus `max_cost_cents`; a quote pays for
     one run (see Cost).
   - Each job runs in the background; poll `get_conversation_job`. Read a
     few dev conversations end to end with `get_conversation` before you
     trust the set.
   - An agent runs one conversation job or replay run at a time. Starting
     either while the other runs is refused with `409` and the id to wait
     for (see Errors); the refused start leaves its quote usable.

3. **Take a baseline.** `run_replays` with `split: "dev"` on the current
   draft: a dry run first, then the real run with its `quote_id` and
   `sample_seed` (see Cost). Keep the run id and its `sample_seed`. Poll `get_replay_run` and
   read every failing example: the original reply, the replayed reply, and
   the judge's issues with the instruction they cite. Pass rates are per
   engine: `summary.by_engine` has the exact and the text pass rate, and
   the top-level `pass_rate` is null when both ran. Compare exact with
   exact and text with text. A dev run with `degraded: true` fell back to
   text where it meant to replay exactly (Core lacked the exact replay or
   did not confirm its budget), or judged nothing; do not read its numbers
   as a measurement.

4. **Edit the draft prompt.**
   - `review_prompt` on the draft: quote it with `dry_run: true` first,
     then run it once with that `quote_id` and `max_cost_cents` (a cached
     review costs nothing and needs no quote). Pick the findings that
     explain the failures you read, not every finding. The prompt tools,
     dry runs included, need the `agents:write` scope on an OAuth token;
     an API key has it.
   - `update_agent` with `prompt_edits` (find and replace pairs, each find
     an exact passage that appears once) and `expected_prompt_sha256` set
     to the review's `prompt_sha256`. This changes the draft only; callers
     keep the deployed agent.
   - `review_prompt` again with `previous_prompt` set to the text before
     your edit. Its findings then focus on the changed passages,
     `inventory_changes` lists behaviors added, removed, changed and added
     back, and `conversations` says whether the test conversations need a
     refresh.
   - When a review reports `refactor_suggested`, run `refactor_prompt` the
     same way: its dry run's `quote_id`, and `max_cost_cents` from its
     `worst_case_cost_cents`. When the prompt has no rule inventory yet (no
     review of that text on record), the refactor's quote counts the
     longest inventory a review can return, so its worst case is far above
     the estimate; run `review_prompt` on that text first for a closer
     quote.
     Check `behavior_preserved`, read `behavior_changes` and
     `dropped_behaviors`, and apply the new text only when every change is
     one you meant: `update_agent` with `prompt` and
     `expected_prompt_sha256` set to `source_prompt_sha256`.
   - Write each fix the guide's way: the general principle or the missing
     fact, not a patch for one call; change or remove the rule that led the
     agent astray before adding a counter-rule; make an ignored instruction
     clearer or better placed, not louder; no names, numbers or words from
     a real caller.

5. **Refresh the conversations when behaviors change.** A conversation
   written for the old prompt can have the agent doing something the new
   prompt dropped, and a replay on it fails for the wrong reason.
   - When to: the review of your edit (step 4) reports
     `conversations.refresh_suggested: true`, or its `inventory_changes`
     lists behaviors `added`, `removed`, `changed` or `added_back`. A change
     in wording only needs no refresh.
   - Run `refresh_conversations` with `dry_run: true`; its
     `estimate.conversations` says how many are current, unchanged in
     behavior, or behind. Then run it with the dry run's `quote_id` and
     `max_cost_cents`, and poll `get_conversation_job`. `conversation_ids`
     or `from_prompt_revision_id` narrows it to some conversations.
   - What it does to each conversation, as a new revision: re-points it
     when nothing it contains is out of date; restores an earlier revision
     written for a prompt with these behaviors (a rule removed and added
     back gets its old conversation, real caller audio included); and
     otherwise rewrites the agent turns from the first out-of-date one to
     the last example, keeping the caller's recorded lines that still fit.
     Examples move with it and get new answer keys where their moment
     changed. An example whose caller turn is gone is retired with a
     reason, and comes back if a later refresh restores the turn.
   - Read the job's `outcome_counts`. For a conversation that was
     `rewritten`, or whose examples were `retired`, read its revisions with
     `get_conversation_revisions`: the behaviors involved, the out-of-date
     turns, the restore source, the examples moved, and the row diff. Check
     that the rewritten turns read like the call, and say in your report
     which examples were retired and why. Nothing is deleted; every
     earlier revision stays readable.
   - Take a new baseline after a refresh: replay the previous draft on the
     refreshed set (`overrides.prompt`), so the comparison in step 6 is on
     the same conversations.

6. **Verify on the dev split.**
   - `run_replays` on dev with `baseline_run_id` set to the baseline and
     the same `sample_seed`. Read `flips.by_engine`: per engine, the
     `fixed` and `broken` examples. An example the two runs judged on
     different engines is only counted in `not_comparable`.
   - Read each failure the way a caller would hear it: a question asked
     twice, two questions in one turn, a reply that talks past the
     caller's answer, a long silence before the reply. Anything a caller
     would notice is a failure, not a detail.
   - Before changing product, audio tier, feedback mode, voice,
     endpointing or intelligence tier, run `compare_configs` with the current configuration as
     the first entry. Comparisons run on dev only; measure the one you pick
     on the test split in step 7. Check the configuration before blaming the prompt:
     misheard spelled letters point at the audio tier (or Storm), a slow
     first reply (or one that cuts the caller off) at the endpointing tier,
     a reply that misses an instruction on an Express or Lite agent at the
     intelligence tier, and a caller left in silence at
     the feedback mode.
   - Repeat steps 4 to 6 until the dev split holds.

7. **Measure on the test split once.** When the change is ready,
   `run_replays` with `split: "test"`. A test result spends its examples:
   - The test split is divided into cohorts. A test run replays one whole
     cohort, the oldest unused one with examples to replay (`sample_size`
     and `sample_seed` are ignored), and returns totals only. It measures
     one configuration: a comparison on the test split is refused. The dry
     run's `test_cohort` names it and `test_cohorts_left` counts the unused
     ones.
   - Each example's engine is set before the run, from the configuration
     and the example's data: an example with recorded caller audio replays
     exactly, a text-only (simulated) one as text. Leave `engine` out or
     send `auto` (`exact` or `text` is refused, `test_engine_per_example`).
     Results come per
     engine; report the exact and the text pass rate apart.
   - A test run never spends recorded caller audio on text. Exact replay
     exists for Bolt v2 only, so when the cohort holds an example with
     recorded audio and the configuration is anything else, the run is
     refused (`test_needs_exact_replay`) before anything runs and the
     cohort stays unused. Measure that configuration on the dev split,
     where its text replays of audio examples are marked degraded.
   - Its first result spends that cohort, whatever the prompt. The next test
     run, for any prompt, takes another cohort, so start a test run only for
     a change you mean to ship.
   - With no unused cohort left the run is refused (`no_test_cohort`).
     Import more calls or generate conversations: new test conversations
     fill new cohorts, and a cohort is ready once it is full. Keep working
     on dev meanwhile.
   - A test run never falls back to text. Where its examples replay
     exactly, Core must run them under a confirmed budget; when it cannot,
     the run ends `failed` with `stop_reason: "exact_replay_unavailable"`
     before anything is judged, and its cohort stays unused. When Core's
     replay capacity stays busy it ends with `stop_reason: "core_busy"`,
     also unused. Run it again later.
   - Report the pass rate and failure counts as they are, next to the dev
     result, and do not change the prompt to move them. A change made after
     reading them is measured on a fresh cohort.

8. **Listen.** Transcripts do not show how a reply sounds.
   - `run_simulation` places a simulated call between an AI caller and the
     draft. Write `scenario_prompt` from a dev conversation's `persona` to
     hear one of its hard moments in audio. Poll `get_simulation`, then
     give the person `recording_url`, the transcript and the grade.
   - `create_talk_link` gives the person a URL to talk to the draft
     themselves. It works once and expires after 30 minutes by default;
     send it only to that person.

9. **Deploy with the person's explicit OK.** Show them the prompt diff,
   the dev result against the baseline, the test result, and what you
   listened to. Run `deploy_agent` only after they say yes to that
   change.

## Cost

- Quote first. `generate_conversations`, `import_conversations`,
  `refresh_conversations`, `run_replays`, `compare_configs`,
  `review_prompt` and `refactor_prompt` take `dry_run: true` and return an
  estimate without running anything. Tell the person the estimate before a
  run that costs more than a few dollars.
- Every paid tool needs its dry run's `quote_id` on the real run:
  conversation jobs (generate, import, refresh), replay runs
  (`run_replays`, `compare_configs`), and `review_prompt` and
  `refactor_prompt` (unless the answer comes from the cache). A quote is
  good for 15 minutes, only for the same arguments, and for one run: it is
  used up once, durably, as the run starts (a job or replay run when its
  rows are created; a prompt tool just before its first model call), and a
  second run with it is refused (`quote_used`). A start that is refused or
  fails before that point (a busy agent, a database error) leaves it
  usable: retry with the same `quote_id`. Once a run has used its quote,
  a failure after that (a model error, a cap, a rejected refactor) says
  so: dry-run again for a new `quote_id` before you repeat it. It is also
  refused when the run
  would now cost more than it quoted. A replay run also sends back the dry
  run's `sample_seed` (a test run: the same test cohort), so it replays the
  quoted sample. A refresh's quote also binds the prompt and the
  conversations it priced. Quote again for each run and after any change.
- Every cap is hard. A real run needs `max_cost_cents` (prompt review and
  refactor too, unless the answer comes from the cache). Before each
  request the run sets aside the most that request can cost and stops
  instead of sending one that does not fit, so it can stop with part of
  the cap unspent. You are charged what the requests really cost, not
  what was set aside. Leave headroom: for a conversation job, about
  `total_cents` plus twice `estimate.largest_reservation_cents`; for a
  replay run, the dry run's `suggested_max_cost_cents`; for a prompt
  tool, its `worst_case_cost_cents`. A job that reaches the cap stops with status
  `stopped`, and a replay run with `stop_reason: "cost_cap"`; what they
  finished is kept.
- Exact replays set aside their worst case. Core holds each replayed turn
  to a budget sized for a normal turn plus one re-run of the kind
  production takes (the reply race again and a watchdog retry), and the
  run sets aside that budget at the configuration's prices: about 85 cents
  to $1.25 per exact replay in flight for a typical turn, against a real
  cost of a few cents. A set-aside is released when its replay ends, so a
  cap only needs the expected spend plus one set-aside per concurrent
  worker: `estimated_cost_cents` plus `concurrent_workers` times
  `largest_reservation_cents`, which the dry run returns as
  `suggested_max_cost_cents`. A larger cap is not needed, and a cap below
  that can stop the run early. A turn that needs more than its budget is an error,
  `replay_budget_exhausted`: never judged, counted apart
  (`budget_exhausted`) and outside the pass rate, and on the test split it
  keeps nothing and spends no cohort, so a test run whose only results are
  such turns leaves its cohort unused.
- Iterate on small samples (20 to 30 examples) with a fixed
  `sample_seed`, and use a larger sample to verify.
- Each agent runs one conversation job or one replay run at a time, not
  both: a refresh must not rewrite the examples a replay is running on.
- `run_simulation` and talk-link conversations bill like test calls, from
  the free test budget first. `run_simulation` needs
  `consent_to_charge: true`.

## Data lifecycle

When a call's recording is turned off, or the call is deleted, everything
derived from it goes too: the test conversations imported from it, their
examples, the examples promoted straight from it, their pinned caller
audio, their replay results and Core's replay cache for that call. A purge that fails is retried until it
finishes, so derived content never outlives the call. An example or
conversation you saw can therefore disappear between two reads.

## Replay request

The dry run of step 3, as a REST call:

```json request POST /v1/agents/{agent_id}/replay-runs
{
  "split": "dev",
  "sample_size": 30,
  "dry_run": true
}
```

```bash
curl --fail-with-body -X POST "https://api.thunderphone.com/v1/agents/$AGENT_ID/replay-runs" \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-ThunderPhone-Client: skills/iterate-on-agent@1.0" \
  --data-binary @replay-run.json
```

```python
import json, os, requests

with open("replay-run.json", encoding="utf-8") as f:
    payload = json.load(f)
url = f"https://api.thunderphone.com/v1/agents/{os.environ['AGENT_ID']}/replay-runs"
r = requests.post(url, json=payload,
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/iterate-on-agent@1.0"}, timeout=30)
r.raise_for_status()
quote = r.json()
print(quote["estimated_cost_cents"], quote["sample_seed"], quote["quote_id"])
```

```ts
import { readFile } from "node:fs/promises";
const body = await readFile("replay-run.json", "utf8");
const response = await fetch(`https://api.thunderphone.com/v1/agents/${process.env.AGENT_ID}/replay-runs`, {
  method: "POST", headers: { Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
    "Content-Type": "application/json", "X-ThunderPhone-Client": "skills/iterate-on-agent@1.0" }, body,
});
if (!response.ok) throw new Error(await response.text());
console.log(await response.json());
```

For the real run, send the same request without `dry_run`, with the
`quote_id` and `sample_seed` the dry run returned and `max_cost_cents`.
Over MCP, the same request is `run_replays` with `agent_id`.

An edit over MCP, with `update_agent`:

```json
{
  "agent_id": 123,
  "expected_prompt_sha256": "<prompt_sha256 from review_prompt>",
  "prompt_edits": [
    {
      "find": "Ask for their name and their phone number.",
      "replace": "Ask for their name. Once they answer, ask for their phone number."
    }
  ]
}
```

The REST API takes the whole prompt instead: read the agent, apply the
edits yourself, and `PATCH /v1/agents/{agent_id}` with `prompt` and
`if_updated_at` from your read.

## Errors

| Code | Cause | Fix |
|---|---|---|
| `feature_not_enabled` | The organization does not have the toolkit. | Tell the person; ThunderPhone support enables it. Use `test-agent` meanwhile. |
| `prompt_edit_not_found` | An edit's `find` is not in the current draft prompt. | Read the agent again and copy the passage exactly, including punctuation and line breaks. |
| `prompt_edit_ambiguous` | An edit's `find` appears more than once. | Add surrounding text until it appears once. |
| `stale_prompt` | The draft changed after the text your edits were written against. | Read the agent again, rewrite the edits against the current text, and send its sha. |
| `conflict` | Another write landed while yours was applied. | Read the agent again and retry. |
| `max_cost_required` | A real run without `max_cost_cents`. | Run with `dry_run: true`, then set the cap. |
| `max_cost_below_minimum` | A replay run's `max_cost_cents` below the dry run's `min_max_cost_cents`. | Run again with the same `quote_id` and the dry run's `suggested_max_cost_cents` (`estimated_cost_cents` plus one `largest_reservation_cents` per concurrent worker). |
| `quote_required`, `quote_expired`, `quote_invalid`, `quote_mismatch`, `quote_outdated`, `quote_used` | A paid run without a fresh, unused `quote_id` for these exact arguments (a replay's `sample_seed` or test cohort included), or one that would now cost more than quoted. | Run the same request with `dry_run: true` and send its `quote_id` (and a replay's `sample_seed`) within 15 minutes, once. |
| `quote_unverifiable` (503) | The quote could not be used up right now, so nothing ran. | Retry in a minute with the same `quote_id`. |
| `configuration_refused` | A configuration a PHI replay cannot run (an ElevenLabs voice, an experimental product, a tier without a BAA). | Drop that configuration or pick a BAA-covered one. |
| `no_examples` | The split has no examples yet. | Import or generate conversations first. |
| `job_active`, `replay_run_active`, `conversation_job_active` (409) | The agent already has a conversation job (`existing_job_id`) or replay run (`existing_run_id`) going; it runs one at a time. | Poll the id in the error until it ends, then retry with the same `quote_id`. |
| `insufficient_scope` (403) | An OAuth token without the route's scope: the prompt tools need `agents:write`, conversation jobs and replay runs `testing:write`. | Reconnect with the scope, or use an API key. |
| `test_engine_per_example` | `engine` `exact` or `text` on the test split. | Leave `engine` out or send `auto`; each example's engine is set from its data. |
| `test_needs_exact_replay` (409) | The test cohort holds recorded caller audio and the configuration has no exact path (anything but Bolt v2). Nothing ran; the cohort stays unused. | Measure that configuration on the dev split. |
| `held_out_call` (403) | A write on a held-out call (grading, promoting it to a scenario, regenerating a turn), or on a test scenario promoted from one. | Leave it out; work with calls and conversations in the dev split. |
| `no_test_cohort` (409) | No unused test cohort: earlier test runs spent them, or none is full yet. | Import calls or generate conversations to fill a new cohort; keep working on dev. |
| `comparison_dev_only` | `compare_configs` (or `configs`) on the test split. | Compare on dev, then run the test split once for the configuration you pick. |
| `test_cohort_changed` (409) | Another test run claimed the quoted cohort first. | Dry-run again for a quote on the next cohort. |
| `test_cohort_empty` (409) | The next cohort's conversations have no examples yet. | Wait for their job to finish, or import or generate more. |
| `test_split_hidden` | Test-split content is hidden from API keys. | Work on the dev split; people review the test split in the dashboard. |
| `replay_run_limit` (429) | The organization already has 8 replay runs going. | Wait for one to finish. |
| `insufficient_balance` | A simulated call or talk link cannot be paid for. | Ask the person to add funds; check `get_billing_summary`. |

A dev result with `engine_fallback: "core_has_no_replay_endpoint"` or
`"core_did_not_enforce_replay_limits"` was replayed as text, not as audio,
and its run is `degraded`: report latency and wait-cover numbers only from
exact replays. A result with `error_code: "replay_budget_exhausted"` is an
error, not a verdict: the turn needed more requests than its budget and
Core refused the extra one, so the reply may not be what a call would say;
the summary counts it as `budget_exhausted`, outside the pass rate, and on
the test split it spends no cohort. A
result skipped with `skipped_reason: "core_busy"` was not run (Core's
replay capacity stayed busy) and cost nothing. A replay run that stopped
with `stop_reason: "cost_over_bound"` or `"core_limits_unsupported"` hit a
cost safeguard, not your cap, and a test run that ended `failed` with
`"exact_replay_unavailable"` or `"core_busy"` could not replay: report
either to the person instead of raising the cap.

## Source and safety rules

- Follow the [prompt style guide](https://thunderphone.com/docs/guides/prompt-style.md) and the [prompting guide](https://thunderphone.com/docs/guides/prompting.md).
- Confirm behavior in [replay runs](https://thunderphone.com/docs/api-reference/replay-runs.md), [test conversations](https://thunderphone.com/docs/api-reference/conversations.md), [prompt revisions](https://thunderphone.com/docs/api-reference/prompt-revisions.md) and the [MCP guide](https://thunderphone.com/docs/guides/thunderphone-mcp-server.md).
- Keep callers' names, numbers and words out of prompts, persona text and reports; describe a failing moment in general terms.
- Edits go to the draft. Deploying, placing calls and spending above the agreed estimate wait for the person's yes.

See [references/tools.md](references/tools.md).

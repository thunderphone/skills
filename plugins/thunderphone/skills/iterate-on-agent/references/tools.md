# Tools for the iteration loop

Each row names the MCP tool, its REST equivalent, and what comes back.
Toolkit tools answer `feature_not_enabled` when the organization does not
have the agent iteration toolkit.

## Reading

| MCP tool | REST | Returns |
|---|---|---|
| `get_agent` | `GET /v1/agents/{agent_id}` | The agent: deployed fields, `draft_*` fields (null when unchanged), and `updated_at` for `if_updated_at`. |
| `list_prompt_revisions` | `GET /v1/agents/{agent_id}/prompt-revisions` | Every change to the prompt text, newest first: `sha256`, `source` (draft, deploy, variant, import, backfill, candidate, historical: a prompt past calls ran before the agent held it), `actor`, and a unified `diff`. `GET /v1/agents/{agent_id}/prompt-revisions/{revision_id}` adds the full `text`. |
| `list_calls`, `get_call`, `get_call_transcript` | `GET /v1/calls`, `GET /v1/calls/{call_id}`, `GET /v1/calls/{call_id}/transcript` | Calls. In toolkit organizations a call whose caller is in one of the agent's test splits is held out: to an API key or OAuth token, on these tools, `get_call_audio_url`, `get_call_grade`, `export_calls` and their REST endpoints alike, it comes back as `call_id`, its start time and `held_out: true` only, and writes on it are refused (403 `held_out_call`). People see it in full in the dashboard; an API key an admin gave `include_held_out_calls` (off by default) does too, never over MCP. Leave held-out calls out when tuning. |
| resource `thunderphone://guides/prompt-style` | [public page](https://thunderphone.com/docs/guides/prompt-style.md) | The style guide, with the guideline ids review findings cite. |

## Prompt

| MCP tool | REST | Returns |
|---|---|---|
| `review_prompt` | `POST /v1/agents/{agent_id}/prompt-review` | Needs the `agents:write` scope on an OAuth token, dry run included. Unless cached, needs its dry run's `quote_id` (one run, used up just before the model call) and `max_cost_cents`. `findings` (guideline id, exact quote, problem, severity, `suggested_edit`), `prompt_edits` that apply together, `rule_inventory` with stable ids, `inventory_changes` (added, removed, changed, added back) when a previous prompt or inventory is sent, `refactor_suggested` with reasons, for the agent's own prompt `conversations.refresh_suggested`, `prompt_sha256` of the reviewed text, `cost_cents`. Never changes the draft or deployed prompt; it saves the rule inventory (on the prompt revision, or in a cache) and the behaviors' lineage, which later reviews, refactors and refreshes build on. |
| `refactor_prompt` | `POST /v1/agents/{agent_id}/prompt-refactor` | Needs `agents:write` like `review_prompt`, its dry run's `quote_id` (one run) and `max_cost_cents`. Without a rule inventory for the text, the quote counts the longest one a review can return; review first for a closer quote. The rewritten `prompt`, a `diff`, `behavior_map` (kept, merged, reworded, dropped), `dropped_behaviors`, and from its second read `behavior_preserved`, `behavior_changes` and `new_findings`. `source_prompt_sha256` is the text it started from. Never changes the draft or deployed prompt (apply the result with `update_agent`); a verified refactor saves the new text's rule inventory. |
| `update_agent` | `PATCH /v1/agents/{agent_id}` | The agent with its new draft. With `prompt_edits` or `prompt`, also `prompt_sha256` of the new text, `previous_prompt_sha256` when the draft was read first, and a `next_step`. `prompt_edits` and `expected_prompt_sha256` are MCP arguments; over REST send the whole `prompt` with `if_updated_at`. |

## Conversations

| MCP tool | REST | Returns |
|---|---|---|
| `list_conversations` | `GET /v1/agents/{agent_id}/conversations` | A page of conversations with `split`, `source`, `status` and counts. Test-split ones come back as ids and counts only. |
| `get_conversation` | `GET /v1/conversations/{conversation_id}` | One conversation with its current `rows` and, for generated ones, the caller's `persona`. A test-split conversation, or one copied from a held-out call, comes back to a coding agent as `id`, `agent_id`, `split`, `source`, `status`, `row_count`, `revision_count`, `cohort_number` and `hidden: true` only, plus `held_out: true` on a dev conversation copied from a held-out call (not on test-split ones): no rows and no persona. |
| `generate_conversations` | `POST /v1/agents/{agent_id}/conversations/generate` | With `dry_run`, the estimate by step, its `largest_reservation_cents`, and a `quote_id` (15 minutes). Otherwise, with that `quote_id` and `max_cost_cents`, a job (`202`) to poll; `409 job_active` or `replay_run_active` while the agent runs another job or a replay run. |
| `import_conversations` | `POST /v1/agents/{agent_id}/conversations/import` | The same; the dry run's estimate also says how many calls it would import (`calls_selected`). |
| `get_conversation_job` | `GET /v1/conversation-jobs/{job_id}` | `status` (pending, running, completed, stopped, failed), `cost_cents` against `max_cost_cents`, and the conversations and example ids it wrote or refreshed. Test-split rows, and rows copied from held-out calls, are ids and counts only, and their errors a count (`hidden_error_count`). |
| `get_conversation_revisions` | `GET /v1/conversations/{conversation_id}/revisions` | Every revision, newest first: `change_kind` (created, refreshed, restored, manual), the `behaviors` added, removed and changed, `restored_from`, and for a refresh the out-of-date turns, the rewrite, and the examples moved, retired or brought back; plus the row `diff`. A test-split conversation returns its revision count only. |
| `refresh_conversations` | `POST /v1/agents/{agent_id}/conversations/refresh` | With `dry_run`, the estimate, `estimate.conversations` (`selected`, `current`, `no_behavior_change`, `behavior_changes`, `unknown`, and `unrefreshable`: conversations whose prompt revision is not known, such as ones imported from calls made before calls recorded their prompt revision, quoted at 0 and listed with the reason in `unrefreshable_conversations`) and a `quote_id`. Otherwise, with that `quote_id` and `max_cost_cents`, a refresh job (`202`); its result gives each conversation's `outcome` (current, repointed, restored, rewritten, retired, skipped, failed), with a `reason` for a skip, and `outcome_counts`. A coding agent's refresh leaves test-split conversations and conversations copied from held-out calls out of its selection, quote and job; naming one in `conversation_ids` is `403 test_conversation`. An `active` example the refresh rewrites goes back to `pending_review` (label `refreshed_needs_review`). |

## Replays

| MCP tool | REST | Returns |
|---|---|---|
| `run_replays` | `POST /v1/agents/{agent_id}/replay-runs` | With `dry_run`, the estimate (`estimated_cost_cents`, `upper_bound_cents`, `largest_reservation_cents`, `concurrent_workers`, and `suggested_max_cost_cents`, the cap that lets the run finish: the estimate plus one reservation per concurrent worker), the example count, the engines it would use, the `sample_seed` and a `quote_id` (one run); on the test split, the `test_cohort` it would spend and `test_cohorts_left`. Otherwise, with that `quote_id`, `sample_seed` and `max_cost_cents`, the run (`201`) to poll; `409 replay_run_active` or `conversation_job_active` while the agent runs another. A test run replays one whole test cohort, each example on the engine its data allows (no `engine`), and its first result that stores a replay spends it (`409 no_test_cohort` when none is left; `409 test_needs_exact_replay`, cohort unused, when it holds recorded caller audio and the configuration is not Bolt v2). |
| `compare_configs` | `POST /v1/agents/{agent_id}/replay-runs` with `configs` | The comparison: one run per configuration on the same examples, the first as baseline. Quoted like `run_replays`. Dev split only (`comparison_dev_only` on test). |
| `get_replay_run` | `GET /v1/replay-runs/{run_id}` | `summary` (verdicts and pass rate per engine in `by_engine`, `budget_exhausted` apart from them, `degraded`, failures by severity and kind, latency to first audio p50 and p90, wait-cover shares, cost per turn), `flips.by_engine` against the baseline (`fixed`, `broken`), `stop_reason`, and per example the original and replayed reply, the judge's verdict and a trace summary; an example copied from a held-out caller's call is its `example_id` and `held_out: true` only, outside the summary and flips (`held_out_example_count`). A run that is part of a comparison also returns the `group`. Test-split runs return the summary and `test_cohort` only. |

## Listening and deploying

| MCP tool | REST | Returns |
|---|---|---|
| `run_simulation` | `POST /v1/simulations` with `target_type: "agent"` | The simulated call's run (`201`), status `in_progress` once the call starts. |
| `get_simulation` | `GET /v1/simulations/{simulation_id}` | `status` (`queued`, `in_progress`, `completed`, `failed`), and once the call ends what it produced: `recording_url` (short-lived; `null` when the agent does not record calls), `transcript` (empty then too) and `grade` (`null` until grading finishes). |
| `create_talk_link` | `POST /v1/agents/{agent_id}/talk-links` | A single-use `url` to the draft and its `expires_at`. |
| `deploy_agent` | `POST /v1/agents/{agent_id}/deploy` | The agent with the draft promoted to production. Run it only after the person agrees. |

Sources: [MCP guide](https://thunderphone.com/docs/guides/thunderphone-mcp-server.md),
[agents](https://thunderphone.com/docs/api-reference/agents.md),
[replay runs](https://thunderphone.com/docs/api-reference/replay-runs.md),
[test conversations](https://thunderphone.com/docs/api-reference/conversations.md),
[simulations](https://thunderphone.com/docs/api-reference/test-calls.md),
[talk links](https://thunderphone.com/docs/api-reference/talk-links.md).

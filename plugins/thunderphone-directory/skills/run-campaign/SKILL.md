---
name: run-campaign
description: Run a consent-based ThunderPhone outbound campaign to people who agreed to be called (appointment reminders, callbacks, follow-ups) - create it, load contacts, start, pause, stop, monitor, or troubleshoot. Use when someone asks about campaign setup, contact lists, calling windows, consent, campaign actions, or why a campaign is not calling.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Run an outbound campaign

1. **Establish consent first.** Confirm every contact agreed to be called, for
   this purpose. Do not infer consent from a list. Ask how opt-outs are handled.
2. **Check the agent and number.** Use a tested, deployed agent and a number the
   organization owns that can call out. Check `get_billing_summary`.
3. **Create the campaign** with `create_campaign`: name, agent, `from_number`, a
   time zone and a daily window inside 08:00-21:00 local time. Nothing dials yet.
4. **Load contacts** with `add_campaign_contacts`. Keep variables to what the
   call needs; no sensitive data.
5. **Review with the user**: window, agent, number, contact count and who can
   pause it.
6. **Start only after an explicit yes.** `campaign_action` `start` is two-step:
   the first call returns a `confirmation_token`. Restate the consent basis and
   the calling window, and send the token back only after the user confirms.
7. **Monitor** with `get_campaign_stats`; pause with `campaign_action` `pause`
   on anything unexpected. For "why isn't it calling", run `check_campaign` first:
   a closed calling window is the usual answer.

Never call a list with repeated `place_call`; a list is a campaign.

Docs: https://thunderphone.com/docs/guides/outbound-campaigns

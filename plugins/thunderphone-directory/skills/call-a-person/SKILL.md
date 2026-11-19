---
name: call-a-person
description: Have a ThunderPhone agent call the user's own phone (a morning briefing, a reminder, "call me") or one person or business who agreed to it. Use when someone asks a ThunderPhone agent to call them or one other person or business, or asks why a ThunderPhone call did not go out.
license: MIT
compatibility: Requires the ThunderPhone MCP server, connected with OAuth. No step asks for a password, API key or other secret.
metadata:
  author: thunderphone
  version: "1.0"
---

# Have an agent call someone

1. **Check who may be called.** Only a person who agreed to get this call, or a
   business's public line for a non-sales errand the user would make themselves
   (a quote, a booking). The user asking for a call to their own phone is their
   agreement. For anyone else, ask whether they agreed to get this call; if not,
   don't place it until they have.
2. **Check the number can call out** before you show a call. Read the number in
   `list_phone_numbers`: a new ThunderPhone number takes calls but cannot call
   out until an organization admin requests outbound calling and ThunderPhone
   approves it. If it cannot call out, say so instead of showing a preview the
   user would approve for nothing, and give the `outbound_request_url` from the
   result (or from `get_account_limits`) as the place to ask for it; without
   that link, the Phone numbers page. Where this chat has
   `request_outbound_access`, ask its questions and file the request here
   instead. With no number at all, say so in the
   first answer: the user gets one first (the get-phone-number skill), and give
   the `outbound_request_url` right away so the request starts at once.
3. **Use an agent written for the call.** A receptionist opens with "Thanks for
   calling", which is wrong when it calls someone. Make a small agent (or
   `duplicate_agent` and edit it) whose opening says who is calling and why,
   with `voicemail_action` `message` and a `voicemail_message` that says the
   same and how to call back. When `place_call` takes `variables`, details for
   this one call (a name, a time) go there; otherwise what the agent should say
   goes in its prompt. Test it with `test_in_text` and deploy after a yes.
4. **One call, one yes.** Show the user the call (agent, from, to) and place it
   only after their yes. `place_call` first returns a preview and a
   `confirmation_token`: show the preview, and send the token only after that
   yes; it expires in 10 minutes, so place the call
   right away.
5. **Calls later or every day.** `place_call` places one call, now. The plugin
   does not schedule or repeat calls: for a call every morning, the user triggers
   each call from whatever they already use to run things on a schedule (a
   scheduled task in Claude, or their own automation calling the ThunderPhone
   API). Build and test the agent here.
6. **After the call,** read it with `get_call` and `get_call_transcript` and tell
   the user how it went, including when it reached voicemail. To show them the
   call, give its `view_url` when the result has one, not a recording URL
   (those expire).

Several people are a campaign, which the user creates in Campaigns in
ThunderPhone; do not call a list one by one.

Docs for the user: https://thunderphone.com/docs/guides/place-outbound-calls

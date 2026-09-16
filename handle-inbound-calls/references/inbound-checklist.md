# Inbound verification checklist

- The phone number reports the intended `inbound_agent_id`.
- The agent has no unintended draft, or the intended draft is deployed.
- Call variables have documented types, defaults, and sensitivity.
- Dynamic configuration has authentication, a bounded timeout, and a safe fallback.
- The opening, language switch, tool use, transfer, and end-of-call behavior work in audio.
- Required disclosure and recording-consent rules are handled for the caller's jurisdiction.
- Signed incoming and completion events are accepted once and deduplicated.

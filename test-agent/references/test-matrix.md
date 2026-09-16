# Minimum test matrix

| Area | Cases | Evidence |
|---|---|---|
| Task | happy path, correction, missing data | transcript + criterion |
| Facts | exact, paraphrased, absent, conflicting | retrieval + transcript |
| Language | each locale, switch, unsupported language | audio + transcript |
| Tools | success, validation, timeout, upstream failure | tool trace |
| Conversation | interruption, silence, repetition, goodbye | audio + timing |
| Safety | escalation, prohibited action, sensitive data | transcript + handoff trace |
| Telephony | answer, voicemail, hangup, carrier failure | call status + events |

Retain the agent revision, scenario version, batch ID, and timestamps with every
readiness claim.

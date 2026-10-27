# Campaign gates

Before start:

- documented audience and calling authority;
- suppression and opt-out lists applied;
- reliable recipient numbers and time zones;
- tested deployed agent and outbound-capable source number, or a pool of local
  numbers sized so each stays under its daily limit;
- approved daily calling window;
- with text-then-call on: text consent, a customer Twilio or Telnyx sender
  registered for messaging (A2P 10DLC for US local numbers), no
  `pre_call_sms_sender_not_ready` warning;
- balance and TCPA confirmation ready;
- contact variables contain no unnecessary sensitive data;
- pause/cancel owner and failure threshold named;
- controlled first batch selected;
- operator explicitly accepts the charge action.

Pause on unexpected behavior before attempting automatic recovery.

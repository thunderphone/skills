# ThunderPhone

Build an AI phone agent without leaving the chat.

- Answer your business's calls: questions, bookings, messages
- Call your customers, or make calls for you

Claude asks a few quick questions with answers to tap and builds your agent.
Then you talk to it: it calls your phone, or you talk in your browser, and the
conversation shows as it happens (where your Claude app shows cards). When it sounds right, get it a number
(from $0.99 a month, plus a one-time $0.99 setup fee) and it's live. Talking to your agent uses free test credit;
anything paid from your balance asks for your yes first.

## Try asking

- "Set up something to answer my business phone."
- "Have my agent call me now so I can hear it."
- "Have an agent call a restaurant to book a table."
- "Move my receptionist over from Vapi."

## What it connects to

ThunderPhone's MCP server only (https://api.thunderphone.com/v1/mcp). You sign
in to ThunderPhone once, and Claude acts only in your organization. Skills are
instructions only: no scripts, and nothing that needs a key is ever entered in
chat. Real calls, texts, number purchases and other charges to your balance ask
for your yes first. Calls are placed one at a time; nothing is scheduled or
repeated. Call transcripts and caller numbers you ask about are shown in the
chat, except calls your account holds back (for example where health
information may be involved). To disconnect, go to Settings → Security in ThunderPhone and revoke
Claude.

ThunderPhone makes phone agents. Claude can't create voice clones or produce
audio files of your text: voices speak only inside calls with your agent, and
test calls are yours. The only audio links are fixed voice samples and
recordings of calls.

People your agent talks to are told. By default, every phone call your agent
makes or answers opens with a spoken notice: "This call is with an AI
assistant and will be recorded and transcribed." When recording is off, the
notice says only that the caller is talking to an AI. Claude can't turn this
notice off or reword it; it can be turned off only in ThunderPhone, by the
account confirming that it tells callers itself.

## Troubleshooting

- A number doesn't ring through: ask Claude to check the number.
- Calls don't go out: a new number takes calls, but calling out needs
  ThunderPhone's approval first. Claude gives you the link to ask for it.
- The talk page can't hear you: allow the microphone in your browser, or ask
  Claude to call your phone instead.
- Anything else: ask Claude to contact ThunderPhone support.

Support: support@thunderphone.com · Privacy: https://thunderphone.com/privacy ·
Docs: https://thunderphone.com/docs/guides/thunderphone-mcp-server

# LiveKit integration checklist

- `livekit-agents` is 1.8 or newer.
- The documented plugin fork is installed and pinned for production.
- LiveKit and ThunderPhone credentials stay server-side.
- The intended ThunderPhone agent revision is deployed.
- Room, participant, realtime model, and audio resources share one lifecycle.
- Shutdown and worker-restart paths release every resource.
- A real room test covers interruption, tools, language, and leave behavior.

# Endpoint-swap checklist

- Replace the WebSocket URL with `wss://api.thunderphone.com/v1/realtime`.
- Send the ThunderPhone bearer key in the server-side handshake.
- Choose either a saved `agent_id` or intentional inline configuration.
- Keep documented OpenAI Realtime events; remove unsupported extensions.
- Verify session confirmation before audio.
- Handle response completion, cancellation, errors, reconnect, and clean close.
- Test real audio and tools before declaring parity.

Source: [Realtime API](https://thunderphone.com/docs/api-reference/realtime.md).

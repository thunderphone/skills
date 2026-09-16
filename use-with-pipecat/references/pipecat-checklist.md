# Pipecat integration checklist

- `pipecat-ai` is 1.8 or newer.
- `pipecat-thunderphone` is installed in the runtime environment.
- `THUNDERPHONE_API_KEY` stays server-side.
- The saved agent ID exists and its intended revision is deployed.
- One pipeline owns the input, model, and output lifecycle.
- Connection errors close transports and release audio resources.
- Real audio verifies interruption, tool, language, and teardown behavior.

Source: [Pipecat guide](https://thunderphone.com/docs/guides/use-with-pipecat.md).

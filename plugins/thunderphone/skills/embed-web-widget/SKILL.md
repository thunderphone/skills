---
name: embed-web-widget
description: Add, configure, style, or debug the ThunderPhone web voice widget. Use when someone asks about @thunderphone/widget, ThunderPhoneWidget, useThunderPhone, the CDN script, pk_live_ publishable keys, allowed domains, widget sessions, React integration, or a headless call UI.
license: MIT
compatibility: Requires a browser with microphone access, a deployed agent, and a domain-scoped ThunderPhone publishable key.
metadata:
  author: thunderphone
  version: "1.0"
---

# Embed the web widget

1. **Create a publishable key.** In **Web Widgets**, choose the deployed agent
   and allow only the intended production and development domains. A `pk_live_`
   key is designed for browsers; an `sk_live_` organization key is not.
   Publishable keys are available through `POST /v1/publishable-key` when an
   authorized backend manages them.
2. **Choose the surface.** Use the React component for the quickest product UI,
   `useThunderPhone` for a custom React experience, or the CDN build for a
   framework-free page.

```json request POST /v1/publishable-key
{
  "name": "Marketing site",
  "mode": "agent",
  "agent_id": 12,
  "allowed_domains": ["example.com"]
}
```

3. **Install the React package.** Run `npm install @thunderphone/widget`, import
   its stylesheet, and render the component.

```tsx
import { ThunderPhoneWidget } from "@thunderphone/widget";
import "@thunderphone/widget/style.css";

export function VoiceWidget() {
  return <ThunderPhoneWidget publishableKey={import.meta.env.VITE_THUNDERPHONE_PUBLISHABLE_KEY} />;
}
```

4. **Or mount the CDN build.** Use the documented latest path while prototyping;
   pin a tested version for controlled releases.

```html
<div id="thunderphone"></div>
<link rel="stylesheet" href="https://cdn.thunderphone.com/widget/latest/style.css" />
<script src="https://cdn.thunderphone.com/widget/latest/widget.js"></script>
<script>
  ThunderPhone.mount({
    element: '#thunderphone',
    publishableKey: window.THUNDERPHONE_PUBLISHABLE_KEY,
  });
</script>
```

5. **Use headless mode for custom UI.** Keep call initiation behind a clear user
   gesture, show connecting/connected/error state, expose mute and end controls,
   and clean up the session on unmount.
6. **Create sessions only through the widget flow.** The browser exchanges the
   publishable key at `POST /v1/widget/session`; never send an organization API
   key to the browser. The SDK handles this exchange.
7. **Verify.** Test an allowed and disallowed domain, microphone allow/deny,
   connect, mute, interrupt, end, reconnect, mobile layout, keyboard operation,
   and the deployed agent's behavior. Confirm widget calls appear in call logs.

API-key management example for an authorized backend:

```bash
curl --fail-with-body https://api.thunderphone.com/v1/publishable-key \
  -H "Authorization: Bearer $THUNDERPHONE_API_KEY" \
  -H "X-ThunderPhone-Client: skills/embed-web-widget@1.0"
```

```python
import os, requests
r = requests.get("https://api.thunderphone.com/v1/publishable-key",
    headers={"Authorization": f"Bearer {os.environ['THUNDERPHONE_API_KEY']}",
             "X-ThunderPhone-Client": "skills/embed-web-widget@1.0"}, timeout=30)
r.raise_for_status(); print(r.json())
```

```ts
const r = await fetch("https://api.thunderphone.com/v1/publishable-key", { headers: {
  Authorization: `Bearer ${process.env.THUNDERPHONE_API_KEY}`,
  "X-ThunderPhone-Client": "skills/embed-web-widget@1.0" } });
if (!r.ok) throw new Error(await r.text()); console.log(await r.json());
```

## Errors

| Symptom | Cause | Fix |
|---|---|---|
| Widget rejects the site | Current origin is not allowlisted | Add the exact approved origin; do not use an unrestricted wildcard. |
| Microphone never starts | Browser permission or secure-context requirement failed | Use HTTPS or localhost and handle the denied state visibly. |
| Browser contains `sk_live_` | Server credential was bundled into frontend code | Revoke it, remove it from artifacts, and use a domain-scoped publishable key. |
| UI connects to old behavior | Publishable key targets another agent or draft is undeployed | Read widget configuration and deploy the intended agent revision. |

## Source and safety rules

- Start with the [widget overview](https://thunderphone.com/docs/widget/overview.md), [React component](https://thunderphone.com/docs/widget/react.md), and [headless hook](https://thunderphone.com/docs/widget/headless-hook.md).
- For script tags, use the [CDN guide](https://thunderphone.com/docs/widget/cdn-script-tag.md).
- Never expose an organization API key or silently start microphone capture.
- Treat `context` as caller-visible conversation data, not a secret channel.

See [references/widget-options.md](references/widget-options.md).

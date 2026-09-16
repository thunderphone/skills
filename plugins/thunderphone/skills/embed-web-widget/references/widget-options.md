# Widget options

| Surface | Choose when |
|---|---|
| `ThunderPhoneWidget` | A production-ready React control fits the UI. |
| `useThunderPhone` | The product needs a fully custom React interface. |
| CDN `ThunderPhone.mount()` | The site has no build step or framework integration. |

Security invariants:

- Browser code receives only a domain-scoped `pk_live_` key.
- The selected agent is deployed and configured through the widget/publishable key.
- Microphone access follows an explicit user gesture.
- Allowed origins are specific and reviewed.

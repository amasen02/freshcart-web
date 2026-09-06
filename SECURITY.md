# Security policy

## Controls in force

This is a browser single-page application. Its security posture is deliberately conservative:

| Control | Implementation |
|---|---|
| Authentication | HttpOnly + Secure + SameSite session cookie issued by the Identity service through the gateway's cookie-to-JWT exchange. **No access tokens are ever stored in JavaScript, `localStorage`, or `sessionStorage`.** |
| CSRF | Double-submit: a readable `XSRF-TOKEN` cookie is echoed in the `X-XSRF-TOKEN` header on every state-changing request (`credentials.interceptor`). |
| Content Security Policy | `default-src 'self'`; `script-src 'self'` — no inline and no third-party scripts; `connect-src 'self'` — XHR and WebSocket to this origin only (the SignalR hubs are same-origin). One third-party origin ships: `picsum.photos` / `fastly.picsum.photos` in `img-src`, the fallback product photography. Sent as an nginx response header ([`nginx.conf`](nginx.conf)) and repeated directive-for-directive in the app shell ([`src/index.html`](src/index.html)), which is the only policy under `ng serve` or on a static host. The one directive the shell cannot repeat is `frame-ancestors 'none'` — a `<meta>` policy may not set it — so clickjacking protection comes from the header (plus `X-Frame-Options: DENY`). |
| Output encoding | Angular's built-in sanitiser on all interpolated content; `innerHTML` assignment is prohibited. |
| Transport security | HTTPS everywhere behind the gateway/ingress; the SPA never talks to a service directly. |
| Build integrity | Multi-stage Docker build to a hardened, non-root nginx image; image scanned by Trivy in CI (fails on HIGH/CRITICAL). |
| Dependency hygiene | Dependabot weekly; `npm ci` against a committed lockfile; Trivy library scan in CI. |
| Secrets | None in the bundle or the image. Runtime configuration is injected by the gateway/ingress, never baked into the build. |

## Reporting a vulnerability

Email `amabandarasp@gmail.com` with the subject prefix `[SECURITY]`, or open a private
[GitHub security advisory](https://github.com/amasen02/freshcart-web/security/advisories/new).
**Do not open a public issue.** Expect acknowledgement within 72 hours.

## Coordinated disclosure window

90 days from acknowledgement, unless mutually extended.

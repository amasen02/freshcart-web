# Security policy

## Controls in force

This is a browser single-page application. Its security posture is deliberately conservative:

| Control | Implementation |
|---|---|
| Authentication | HttpOnly + Secure + SameSite session cookie issued by the Identity service through the gateway's cookie-to-JWT exchange. **No access tokens are ever stored in JavaScript, `localStorage`, or `sessionStorage`.** |
| CSRF | Double-submit: a readable `XSRF-TOKEN` cookie is echoed in the `X-XSRF-TOKEN` header on every state-changing request (`credentials.interceptor`). |
| Content Security Policy | Strict CSP served by nginx (`default-src 'self'`); no inline scripts, no third-party origins. |
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
